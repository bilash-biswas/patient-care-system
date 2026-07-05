using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Moq;
using PatientManagementSystem.Data;
using PatientManagementSystem.Models;
using PatientManagementSystem.Services;
using Xunit;

namespace PatientManagementSystem.Tests.Services
{
    public class ReminderServiceTests
    {
        private readonly Mock<ILogger<ReminderService>> _mockLogger;

        public ReminderServiceTests()
        {
            _mockLogger = new Mock<ILogger<ReminderService>>();
        }

        private ApplicationDbContext GetDbContext()
        {
            var options = new DbContextOptionsBuilder<ApplicationDbContext>()
                .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
                .Options;
            return new ApplicationDbContext(options);
        }

        [Fact]
        public async Task SendUpcomingAppointmentReminders_SendsRemindersOnlyForScheduledTomorrowAppointments()
        {
            // Arrange
            using var context = GetDbContext();

            var patientUser = new User
            {
                Id = Guid.NewGuid(),
                Email = "patient@example.com",
                Username = "patient1",
                FirstName = "John",
                LastName = "Doe",
                Role = "Patient"
            };

            var doctorUser = new User
            {
                Id = Guid.NewGuid(),
                Email = "doctor@example.com",
                Username = "doctor1",
                FirstName = "Jane",
                LastName = "Smith",
                Role = "Doctor"
            };

            var patient = new Patient
            {
                Id = Guid.NewGuid(),
                UserId = patientUser.Id,
                User = patientUser,
                FirstName = "John",
                LastName = "Doe",
                Phone = "555-0199"
            };

            context.Users.AddRange(patientUser, doctorUser);
            context.Patients.Add(patient);

            var tomorrow = DateTime.UtcNow.Date.AddDays(1);
            var today = DateTime.UtcNow.Date;
            var dayAfterTomorrow = DateTime.UtcNow.Date.AddDays(2);

            var appointments = new List<Appointment>
            {
                // Should trigger reminder
                new Appointment
                {
                    Id = Guid.NewGuid(),
                    PatientId = patient.Id,
                    Patient = patient,
                    DoctorId = doctorUser.Id,
                    Doctor = doctorUser,
                    AppointmentDate = tomorrow,
                    StartTime = new TimeSpan(10, 30, 0),
                    Status = "Scheduled"
                },
                // Should NOT trigger (not tomorrow)
                new Appointment
                {
                    Id = Guid.NewGuid(),
                    PatientId = patient.Id,
                    Patient = patient,
                    DoctorId = doctorUser.Id,
                    Doctor = doctorUser,
                    AppointmentDate = today,
                    StartTime = new TimeSpan(11, 0, 0),
                    Status = "Scheduled"
                },
                // Should NOT trigger (not tomorrow)
                new Appointment
                {
                    Id = Guid.NewGuid(),
                    PatientId = patient.Id,
                    Patient = patient,
                    DoctorId = doctorUser.Id,
                    Doctor = doctorUser,
                    AppointmentDate = dayAfterTomorrow,
                    StartTime = new TimeSpan(12, 0, 0),
                    Status = "Scheduled"
                },
                // Should NOT trigger (cancelled status)
                new Appointment
                {
                    Id = Guid.NewGuid(),
                    PatientId = patient.Id,
                    Patient = patient,
                    DoctorId = doctorUser.Id,
                    Doctor = doctorUser,
                    AppointmentDate = tomorrow,
                    StartTime = new TimeSpan(14, 0, 0),
                    Status = "Cancelled"
                }
            };

            context.Appointments.AddRange(appointments);
            await context.SaveChangesAsync();

            var service = new ReminderService(context, _mockLogger.Object);

            // Act
            await service.SendUpcomingAppointmentReminders();

            // Assert
            // 1. Verify reminder log message was called once (for the valid tomorrow appointment)
            _mockLogger.Verify(
                x => x.Log(
                    LogLevel.Information,
                    It.IsAny<EventId>(),
                    It.Is<It.IsAnyType>((v, t) => v.ToString()!.Contains("REMINDER SENT: Patient John Doe")),
                    It.IsAny<Exception>(),
                    It.IsAny<Func<It.IsAnyType, Exception?, string>>()),
                Times.Once);

            // 2. Verify completion log specifies exactly 1 reminder sent
            _mockLogger.Verify(
                x => x.Log(
                    LogLevel.Information,
                    It.IsAny<EventId>(),
                    It.Is<It.IsAnyType>((v, t) => v.ToString()!.Contains("Reminder job completed. Sent 1 reminders.")),
                    It.IsAny<Exception>(),
                    It.IsAny<Func<It.IsAnyType, Exception?, string>>()),
                Times.Once);
        }
    }
}
