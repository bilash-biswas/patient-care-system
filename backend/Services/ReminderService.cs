using System;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using PatientManagementSystem.Data;
using Microsoft.Extensions.Logging;
using System.Linq;

namespace PatientManagementSystem.Services
{
    public interface IReminderService
    {
        Task SendUpcomingAppointmentReminders();
    }

    public class ReminderService : IReminderService
    {
        private readonly ApplicationDbContext _context;
        private readonly ILogger<ReminderService> _logger;

        public ReminderService(ApplicationDbContext context, ILogger<ReminderService> logger)
        {
            _context = context;
            _logger = logger;
        }

        public async Task SendUpcomingAppointmentReminders()
        {
            _logger.LogInformation("Checking for upcoming appointments to send reminders...");

            // Find appointments happening exactly tomorrow
            var tomorrowStart = DateTime.UtcNow.Date.AddDays(1);
            var tomorrowEnd = tomorrowStart.AddDays(1);

            var upcomingAppointments = await _context.Appointments
                .Include(a => a.Patient)
                .ThenInclude(p => p.User)
                .Include(a => a.Doctor)
                .Where(a => a.Status == "Scheduled" 
                    && a.AppointmentDate >= tomorrowStart 
                    && a.AppointmentDate < tomorrowEnd)
                .ToListAsync();

            foreach (var appointment in upcomingAppointments)
            {
                // Simulate sending an email/SMS
                var patientEmail = appointment.Patient.User?.Email;
                var patientPhone = appointment.Patient.Phone;

                _logger.LogInformation(
                    "REMINDER SENT: Patient {PatientName} (Email: {Email}, Phone: {Phone}) for appointment with Dr. {DoctorName} on {Date} at {Time}.",
                    appointment.Patient.FirstName + " " + appointment.Patient.LastName,
                    patientEmail ?? "N/A",
                    patientPhone ?? "N/A",
                    appointment.Doctor.LastName,
                    appointment.AppointmentDate.ToShortDateString(),
                    appointment.StartTime.ToString(@"hh\:mm")
                );

                // Note: In a real app, integrate SendGrid or Twilio here.
            }

            _logger.LogInformation($"Reminder job completed. Sent {upcomingAppointments.Count} reminders.");
        }
    }
}
