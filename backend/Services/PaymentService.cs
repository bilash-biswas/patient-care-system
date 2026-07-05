using Stripe;
using PatientManagementSystem.Models;
using PatientManagementSystem.Data;
using Microsoft.EntityFrameworkCore;

namespace PatientManagementSystem.Services
{
    public interface IPaymentService
    {
        Task<string> CreatePaymentIntentAsync(Guid invoiceId);
        Task<bool> ProcessPaymentWebhookAsync(string json, string stripeSignature);
    }

    public class PaymentService : IPaymentService
    {
        private readonly IConfiguration _configuration;
        private readonly ApplicationDbContext _context;
        private readonly ILogger<PaymentService> _logger;

        public PaymentService(IConfiguration configuration, ApplicationDbContext context, ILogger<PaymentService> logger)
        {
            _configuration = configuration;
            _context = context;
            _logger = logger;
            StripeConfiguration.ApiKey = _configuration["Stripe:SecretKey"];
        }

        public async Task<string> CreatePaymentIntentAsync(Guid invoiceId)
        {
            var invoice = await _context.Invoices.FindAsync(invoiceId);
            if (invoice == null) throw new Exception("Invoice not found");

            var options = new PaymentIntentCreateOptions
            {
                Amount = (long)(invoice.Amount * 100), // Convert to cents
                Currency = invoice.Currency,
                PaymentMethodTypes = new List<string> { "card" },
                Metadata = new Dictionary<string, string> { { "invoiceId", invoice.Id.ToString() } }
            };

            var service = new PaymentIntentService();
            var intent = await service.CreateAsync(options);

            invoice.StripePaymentIntentId = intent.Id;
            await _context.SaveChangesAsync();

            return intent.ClientSecret;
        }

        public async Task<bool> ProcessPaymentWebhookAsync(string json, string stripeSignature)
        {
            try
            {
                var stripeEvent = EventUtility.ConstructEvent(json, stripeSignature, _configuration["Stripe:WebhookSecret"]);

                if (stripeEvent.Type == Stripe.EventTypes.PaymentIntentSucceeded)
                {
                    var paymentIntent = stripeEvent.Data.Object as PaymentIntent;
                    if (paymentIntent != null && 
                        paymentIntent.Metadata != null && 
                        paymentIntent.Metadata.TryGetValue("invoiceId", out var invoiceIdStr) && 
                        Guid.TryParse(invoiceIdStr, out var invoiceId))
                    {
                        var invoice = await _context.Invoices.FirstOrDefaultAsync(i => i.Id == invoiceId);
                        if (invoice != null)
                        {
                            invoice.Status = "Paid";
                            invoice.PaidAt = DateTime.UtcNow;

                            if (invoice.AppointmentId != null)
                            {
                                var appointment = await _context.Appointments.FindAsync(invoice.AppointmentId);
                                if (appointment != null && appointment.Status == "PendingPayment")
                                {
                                    appointment.Status = "Scheduled";
                                    appointment.UpdatedAt = DateTime.UtcNow;
                                    _context.Appointments.Update(appointment);
                                }
                            }

                            await _context.SaveChangesAsync();
                        }
                    }
                }

                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Stripe webhook error");
                return false;
            }
        }
    }
}
