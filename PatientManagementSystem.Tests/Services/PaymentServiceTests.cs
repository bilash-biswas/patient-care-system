using System;
using System.Collections.Generic;
using System.Net;
using System.Net.Http;
using System.Security.Cryptography;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Moq;
using PatientManagementSystem.Data;
using PatientManagementSystem.Models;
using PatientManagementSystem.Services;
using Stripe;
using Xunit;

namespace PatientManagementSystem.Tests.Services
{
    public class PaymentServiceTests
    {
        private readonly Mock<ILogger<PaymentService>> _mockLogger;
        private readonly IConfiguration _configuration;
        private const string WebhookSecret = "whsec_test_secret_key_1234567890";

        public PaymentServiceTests()
        {
            _mockLogger = new Mock<ILogger<PaymentService>>();

            var configSettings = new Dictionary<string, string?>
            {
                { "Stripe:SecretKey", "sk_test_mock_key" },
                { "Stripe:WebhookSecret", WebhookSecret }
            };

            _configuration = new ConfigurationBuilder()
                .AddInMemoryCollection(configSettings)
                .Build();
        }

        private ApplicationDbContext GetDbContext()
        {
            var options = new DbContextOptionsBuilder<ApplicationDbContext>()
                .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
                .Options;
            return new ApplicationDbContext(options);
        }

        private string GenerateStripeSignature(string jsonPayload, string secret, long timestamp)
        {
            var message = $"{timestamp}.{jsonPayload}";
            var secretBytes = Encoding.UTF8.GetBytes(secret);
            var messageBytes = Encoding.UTF8.GetBytes(message);

            using var hmac = new HMACSHA256(secretBytes);
            var hashBytes = hmac.ComputeHash(messageBytes);
            var hashString = BitConverter.ToString(hashBytes).Replace("-", "").ToLower();

            return $"t={timestamp},v1={hashString}";
        }

        // A fake HTTP message handler to intercept calls made by Stripe.net client
        private class FakeHttpMessageHandler : HttpMessageHandler
        {
            private readonly string _responseJson;
            private readonly HttpStatusCode _statusCode;

            public FakeHttpMessageHandler(string responseJson, HttpStatusCode statusCode = HttpStatusCode.OK)
            {
                _responseJson = responseJson;
                _statusCode = statusCode;
            }

            protected override Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
            {
                var response = new HttpResponseMessage(_statusCode)
                {
                    Content = new StringContent(_responseJson, Encoding.UTF8, "application/json")
                };
                return Task.FromResult(response);
            }
        }

        [Fact]
        public async Task CreatePaymentIntentAsync_ValidInvoice_ReturnsClientSecretAndUpdatesInvoice()
        {
            // Arrange
            using var context = GetDbContext();
            var invoice = new PatientManagementSystem.Models.Invoice
            {
                Id = Guid.NewGuid(),
                Amount = 150.00m,
                Currency = "usd",
                Status = "Pending",
                PatientId = Guid.NewGuid()
            };
            context.Invoices.Add(invoice);
            await context.SaveChangesAsync();

            // Set up Stripe Mock client with fake handler
            var mockResponseJson = "{\"id\": \"pi_test_123\", \"client_secret\": \"pi_test_secret_123\"}";
            var fakeHandler = new FakeHttpMessageHandler(mockResponseJson);
            var fakeHttpClient = new HttpClient(fakeHandler);
            var stripeHttpClient = new SystemNetHttpClient(fakeHttpClient);
            var stripeClient = new StripeClient("sk_test_mock_key", httpClient: stripeHttpClient);
            
            // Set the static default stripe client
            StripeConfiguration.StripeClient = stripeClient;

            var service = new PaymentService(_configuration, context, _mockLogger.Object);

            // Act
            var clientSecret = await service.CreatePaymentIntentAsync(invoice.Id);

            // Assert
            Assert.Equal("pi_test_secret_123", clientSecret);

            var updatedInvoice = await context.Invoices.FindAsync(invoice.Id);
            Assert.NotNull(updatedInvoice);
            Assert.Equal("pi_test_123", updatedInvoice.StripePaymentIntentId);
        }

        [Fact]
        public async Task CreatePaymentIntentAsync_NonExistentInvoice_ThrowsException()
        {
            // Arrange
            using var context = GetDbContext();
            var service = new PaymentService(_configuration, context, _mockLogger.Object);

            // Act & Assert
            var ex = await Assert.ThrowsAsync<Exception>(() => service.CreatePaymentIntentAsync(Guid.NewGuid()));
            Assert.Equal("Invoice not found", ex.Message);
        }

        [Fact]
        public async Task ProcessPaymentWebhookAsync_ValidSignatureAndType_UpdatesInvoiceToPaid()
        {
            // Arrange
            using var context = GetDbContext();
            var invoiceId = Guid.NewGuid();
            var invoice = new PatientManagementSystem.Models.Invoice
            {
                Id = invoiceId,
                Amount = 150.00m,
                Currency = "usd",
                Status = "Pending",
                PatientId = Guid.NewGuid()
            };
            context.Invoices.Add(invoice);
            await context.SaveChangesAsync();

            var jsonPayload = "{" +
                "\"id\": \"evt_123\"," +
                "\"object\": \"event\"," +
                "\"api_version\": \"" + StripeConfiguration.ApiVersion + "\"," +
                "\"type\": \"payment_intent.succeeded\"," +
                "\"data\": {" +
                    "\"object\": {" +
                        "\"id\": \"pi_123\"," +
                        "\"object\": \"payment_intent\"," +
                        "\"metadata\": {" +
                            "\"invoiceId\": \"" + invoiceId.ToString() + "\"" +
                        "}" +
                    "}" +
                "}" +
            "}";

            var timestamp = DateTimeOffset.UtcNow.ToUnixTimeSeconds();
            var signature = GenerateStripeSignature(jsonPayload, WebhookSecret, timestamp);

            Exception? capturedException = null;
            _mockLogger.Setup(
                x => x.Log(
                    LogLevel.Error,
                    It.IsAny<EventId>(),
                    It.IsAny<It.IsAnyType>(),
                    It.IsAny<Exception>(),
                    It.IsAny<Func<It.IsAnyType, Exception?, string>>()))
                .Callback(new InvocationAction(invocation =>
                {
                    capturedException = invocation.Arguments[3] as Exception;
                }));

            var service = new PaymentService(_configuration, context, _mockLogger.Object);

            // Act
            var result = await service.ProcessPaymentWebhookAsync(jsonPayload, signature);

            // Assert
            if (capturedException != null)
            {
                throw new Exception($"Webhook processing failed with exception: {capturedException.Message}\nStacktrace: {capturedException.StackTrace}", capturedException);
            }
            Assert.True(result);

            var updatedInvoice = await context.Invoices.FindAsync(invoiceId);
            Assert.NotNull(updatedInvoice);
            Assert.Equal("Paid", updatedInvoice.Status);
            Assert.NotNull(updatedInvoice.PaidAt);
        }

        [Fact]
        public async Task ProcessPaymentWebhookAsync_InvalidSignature_ReturnsFalseAndLogsError()
        {
            // Arrange
            using var context = GetDbContext();
            var jsonPayload = "{\"id\": \"evt_123\"}";
            var invalidSignature = "t=123,v1=invalidhash";

            var service = new PaymentService(_configuration, context, _mockLogger.Object);

            // Act
            var result = await service.ProcessPaymentWebhookAsync(jsonPayload, invalidSignature);

            // Assert
            Assert.False(result);
            _mockLogger.Verify(
                x => x.Log(
                    LogLevel.Error,
                    It.IsAny<EventId>(),
                    It.Is<It.IsAnyType>((v, t) => v.ToString()!.Contains("Stripe webhook error")),
                    It.IsAny<Exception>(),
                    It.IsAny<Func<It.IsAnyType, Exception?, string>>()),
                Times.Once);
        }
    }
}
