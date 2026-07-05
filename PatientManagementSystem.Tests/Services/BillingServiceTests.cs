using System;
using System.Collections.Generic;
using System.Linq;
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
    public class BillingServiceTests
    {
        private ApplicationDbContext GetDbContext()
        {
            var options = new DbContextOptionsBuilder<ApplicationDbContext>()
                .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
                .Options;
            return new ApplicationDbContext(options);
        }

        [Fact]
        public async Task GetInvoicesAsync_PatientRole_ReturnsOwnInvoices()
        {
            // Arrange
            using var context = GetDbContext();
            var patientUserId = Guid.NewGuid();
            var patient = new Patient { Id = Guid.NewGuid(), UserId = patientUserId, FirstName = "John", LastName = "Doe" };
            context.Patients.Add(patient);

            var invoice1 = new Invoice { Id = Guid.NewGuid(), PatientId = patient.Id, Amount = 100.00m, Status = "Unpaid" };
            var invoice2 = new Invoice { Id = Guid.NewGuid(), PatientId = Guid.NewGuid(), Amount = 150.00m, Status = "Unpaid" }; // other patient's invoice
            context.Invoices.AddRange(invoice1, invoice2);
            await context.SaveChangesAsync();

            var mockPayment = new Mock<IPaymentService>();
            var mockLogger = new Mock<ILogger<BillingService>>();
            var service = new BillingService(context, mockPayment.Object, mockLogger.Object);

            // Act
            var result = await service.GetInvoicesAsync(null, patientUserId, "Patient");

            // Assert
            Assert.Single(result);
            Assert.Equal(invoice1.Id, result.First().Id);
        }

        [Fact]
        public async Task GetInvoicesAsync_PatientRole_RequestingOtherPatientId_ThrowsUnauthorizedAccessException()
        {
            // Arrange
            using var context = GetDbContext();
            var patientUserId1 = Guid.NewGuid();
            var patient1 = new Patient { Id = Guid.NewGuid(), UserId = patientUserId1, FirstName = "John", LastName = "Doe" };
            var patient2 = new Patient { Id = Guid.NewGuid(), UserId = Guid.NewGuid(), FirstName = "Jane", LastName = "Doe" };
            context.Patients.AddRange(patient1, patient2);
            await context.SaveChangesAsync();

            var mockPayment = new Mock<IPaymentService>();
            var mockLogger = new Mock<ILogger<BillingService>>();
            var service = new BillingService(context, mockPayment.Object, mockLogger.Object);

            // Act & Assert
            await Assert.ThrowsAsync<UnauthorizedAccessException>(() =>
                service.GetInvoicesAsync(patient2.Id, patientUserId1, "Patient"));
        }

        [Fact]
        public async Task GetInvoicesAsync_StaffRole_CanFilterByPatientId()
        {
            // Arrange
            using var context = GetDbContext();
            var patient1 = new Patient { Id = Guid.NewGuid(), UserId = Guid.NewGuid(), FirstName = "John", LastName = "Doe" };
            var patient2 = new Patient { Id = Guid.NewGuid(), UserId = Guid.NewGuid(), FirstName = "Jane", LastName = "Doe" };
            context.Patients.AddRange(patient1, patient2);

            var invoice1 = new Invoice { Id = Guid.NewGuid(), PatientId = patient1.Id, Amount = 100.00m, Status = "Unpaid" };
            var invoice2 = new Invoice { Id = Guid.NewGuid(), PatientId = patient2.Id, Amount = 150.00m, Status = "Unpaid" };
            context.Invoices.AddRange(invoice1, invoice2);
            await context.SaveChangesAsync();

            var mockPayment = new Mock<IPaymentService>();
            var mockLogger = new Mock<ILogger<BillingService>>();
            var service = new BillingService(context, mockPayment.Object, mockLogger.Object);

            // Act
            var result = await service.GetInvoicesAsync(patient1.Id, Guid.NewGuid(), "Doctor");

            // Assert
            Assert.Single(result);
            Assert.Equal(invoice1.Id, result.First().Id);
        }

        [Fact]
        public async Task GetInvoiceByIdAsync_PatientRole_OwnInvoice_ReturnsInvoice()
        {
            // Arrange
            using var context = GetDbContext();
            var patientUserId = Guid.NewGuid();
            var patient = new Patient { Id = Guid.NewGuid(), UserId = patientUserId, FirstName = "John", LastName = "Doe" };
            context.Patients.Add(patient);

            var invoice = new Invoice { Id = Guid.NewGuid(), PatientId = patient.Id, Amount = 100.00m, Status = "Unpaid" };
            context.Invoices.Add(invoice);
            await context.SaveChangesAsync();

            var mockPayment = new Mock<IPaymentService>();
            var mockLogger = new Mock<ILogger<BillingService>>();
            var service = new BillingService(context, mockPayment.Object, mockLogger.Object);

            // Act
            var result = await service.GetInvoiceByIdAsync(invoice.Id, patientUserId, "Patient");

            // Assert
            Assert.NotNull(result);
            Assert.Equal(invoice.Id, result.Id);
        }

        [Fact]
        public async Task GetInvoiceByIdAsync_PatientRole_OtherInvoice_ThrowsUnauthorizedAccessException()
        {
            // Arrange
            using var context = GetDbContext();
            var patientUserId1 = Guid.NewGuid();
            var patient1 = new Patient { Id = Guid.NewGuid(), UserId = patientUserId1, FirstName = "John", LastName = "Doe" };
            var patient2 = new Patient { Id = Guid.NewGuid(), UserId = Guid.NewGuid(), FirstName = "Jane", LastName = "Doe" };
            context.Patients.AddRange(patient1, patient2);

            var invoice = new Invoice { Id = Guid.NewGuid(), PatientId = patient2.Id, Amount = 100.00m, Status = "Unpaid" };
            context.Invoices.Add(invoice);
            await context.SaveChangesAsync();

            var mockPayment = new Mock<IPaymentService>();
            var mockLogger = new Mock<ILogger<BillingService>>();
            var service = new BillingService(context, mockPayment.Object, mockLogger.Object);

            // Act & Assert
            await Assert.ThrowsAsync<UnauthorizedAccessException>(() =>
                service.GetInvoiceByIdAsync(invoice.Id, patientUserId1, "Patient"));
        }

        [Fact]
        public async Task PayInvoiceAsync_PatientRole_OwnInvoice_ProcessesPayment()
        {
            // Arrange
            using var context = GetDbContext();
            var patientUserId = Guid.NewGuid();
            var patient = new Patient { Id = Guid.NewGuid(), UserId = patientUserId, FirstName = "John", LastName = "Doe" };
            context.Patients.Add(patient);

            var invoice = new Invoice { Id = Guid.NewGuid(), PatientId = patient.Id, Amount = 100.00m, Status = "Unpaid" };
            context.Invoices.Add(invoice);
            await context.SaveChangesAsync();

            var mockPayment = new Mock<IPaymentService>();
            mockPayment.Setup(p => p.CreatePaymentIntentAsync(invoice.Id))
                .ReturnsAsync("stripe_client_secret_xyz");

            var mockLogger = new Mock<ILogger<BillingService>>();
            var service = new BillingService(context, mockPayment.Object, mockLogger.Object);

            // Act
            var clientSecret = await service.PayInvoiceAsync(invoice.Id, patientUserId, "Patient");

            // Assert
            Assert.Equal("stripe_client_secret_xyz", clientSecret);
            var dbInvoice = await context.Invoices.FindAsync(invoice.Id);
            Assert.NotNull(dbInvoice);
            Assert.Equal("Paid", dbInvoice.Status);
            Assert.NotNull(dbInvoice.PaidAt);
        }

        [Fact]
        public async Task PayInvoiceAsync_StripeFails_FallsBackToMockSecret()
        {
            // Arrange
            using var context = GetDbContext();
            var patientUserId = Guid.NewGuid();
            var patient = new Patient { Id = Guid.NewGuid(), UserId = patientUserId, FirstName = "John", LastName = "Doe" };
            context.Patients.Add(patient);

            var invoice = new Invoice { Id = Guid.NewGuid(), PatientId = patient.Id, Amount = 100.00m, Status = "Unpaid" };
            context.Invoices.Add(invoice);
            await context.SaveChangesAsync();

            var mockPayment = new Mock<IPaymentService>();
            mockPayment.Setup(p => p.CreatePaymentIntentAsync(invoice.Id))
                .ThrowsAsync(new Exception("Stripe connection error")); // Force Stripe failure

            var mockLogger = new Mock<ILogger<BillingService>>();
            var service = new BillingService(context, mockPayment.Object, mockLogger.Object);

            // Act
            var clientSecret = await service.PayInvoiceAsync(invoice.Id, patientUserId, "Patient");

            // Assert
            Assert.StartsWith("pi_mock_secret_", clientSecret);
            var dbInvoice = await context.Invoices.FindAsync(invoice.Id);
            Assert.NotNull(dbInvoice);
            Assert.Equal("Paid", dbInvoice.Status);
            Assert.NotNull(dbInvoice.PaidAt);
        }

        [Fact]
        public async Task PayInvoiceAsync_PatientRole_OtherInvoice_ThrowsUnauthorizedAccessException()
        {
            // Arrange
            using var context = GetDbContext();
            var patientUserId1 = Guid.NewGuid();
            var patient1 = new Patient { Id = Guid.NewGuid(), UserId = patientUserId1, FirstName = "John", LastName = "Doe" };
            var patient2 = new Patient { Id = Guid.NewGuid(), UserId = Guid.NewGuid(), FirstName = "Jane", LastName = "Doe" };
            context.Patients.AddRange(patient1, patient2);

            var invoice = new Invoice { Id = Guid.NewGuid(), PatientId = patient2.Id, Amount = 100.00m, Status = "Unpaid" };
            context.Invoices.Add(invoice);
            await context.SaveChangesAsync();

            var mockPayment = new Mock<IPaymentService>();
            var mockLogger = new Mock<ILogger<BillingService>>();
            var service = new BillingService(context, mockPayment.Object, mockLogger.Object);

            // Act & Assert
            await Assert.ThrowsAsync<UnauthorizedAccessException>(() =>
                service.PayInvoiceAsync(invoice.Id, patientUserId1, "Patient"));
        }
    }
}
