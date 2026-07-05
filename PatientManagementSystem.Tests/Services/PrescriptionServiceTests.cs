using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using PatientManagementSystem.Data;
using PatientManagementSystem.Models;
using PatientManagementSystem.Services;
using Xunit;

namespace PatientManagementSystem.Tests.Services
{
    public class PrescriptionServiceTests
    {
        private ApplicationDbContext GetDbContext()
        {
            var options = new DbContextOptionsBuilder<ApplicationDbContext>()
                .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
                .Options;
            return new ApplicationDbContext(options);
        }

        [Fact]
        public async Task GetPrescriptionsAsync_FiltersByPatientId()
        {
            // Arrange
            using var context = GetDbContext();
            var patientId1 = Guid.NewGuid();
            var patientId2 = Guid.NewGuid();

            var patient1 = new Patient { Id = patientId1, UserId = Guid.NewGuid(), FirstName = "John", LastName = "Doe" };
            var patient2 = new Patient { Id = patientId2, UserId = Guid.NewGuid(), FirstName = "Jane", LastName = "Doe" };
            context.Patients.AddRange(patient1, patient2);

            var mr1 = new MedicalRecord { Id = Guid.NewGuid(), PatientId = patientId1, Patient = patient1, VisitDate = DateTime.UtcNow };
            var mr2 = new MedicalRecord { Id = Guid.NewGuid(), PatientId = patientId2, Patient = patient2, VisitDate = DateTime.UtcNow };
            context.MedicalRecords.AddRange(mr1, mr2);

            var p1 = new Prescription { Id = Guid.NewGuid(), MedicalRecordId = mr1.Id, MedicalRecord = mr1, MedicationName = "Med1" };
            var p2 = new Prescription { Id = Guid.NewGuid(), MedicalRecordId = mr2.Id, MedicalRecord = mr2, MedicationName = "Med2" };
            context.Prescriptions.AddRange(p1, p2);
            await context.SaveChangesAsync();

            var service = new PrescriptionService(context);

            // Act
            var result = await service.GetPrescriptionsAsync(null, patientId1, Guid.NewGuid(), "Doctor");

            // Assert
            Assert.Single(result);
            Assert.Equal("Med1", result.First().MedicationName);
        }

        [Fact]
        public async Task CreatePrescriptionAsync_SavesPrescription()
        {
            // Arrange
            using var context = GetDbContext();
            var patient = new Patient { Id = Guid.NewGuid(), FirstName = "John", LastName = "Doe" };
            context.Patients.Add(patient);
            
            var mr = new MedicalRecord { Id = Guid.NewGuid(), PatientId = patient.Id, Patient = patient, VisitDate = DateTime.UtcNow };
            context.MedicalRecords.Add(mr);
            await context.SaveChangesAsync();

            var service = new PrescriptionService(context);
            var prescription = new Prescription
            {
                Id = Guid.NewGuid(),
                MedicalRecordId = mr.Id,
                MedicationName = "Aspirin",
                Dosage = "100mg",
                Frequency = "Once daily",
                DurationDays = 30
            };

            // Act
            var result = await service.CreatePrescriptionAsync(prescription);

            // Assert
            Assert.NotNull(result);
            Assert.Equal("Aspirin", result.MedicationName);

            var dbPrescription = await context.Prescriptions.FindAsync(prescription.Id);
            Assert.NotNull(dbPrescription);
        }

        [Fact]
        public async Task RequestRefillAsync_ValidOwnership_CreatesRefill()
        {
            // Arrange
            using var context = GetDbContext();
            var patientUserId = Guid.NewGuid();
            var patient = new Patient { Id = Guid.NewGuid(), UserId = patientUserId, FirstName = "John", LastName = "Doe" };
            context.Patients.Add(patient);

            var mr = new MedicalRecord { Id = Guid.NewGuid(), PatientId = patient.Id, Patient = patient, VisitDate = DateTime.UtcNow };
            context.MedicalRecords.Add(mr);

            var p = new Prescription { Id = Guid.NewGuid(), MedicalRecordId = mr.Id, MedicalRecord = mr, MedicationName = "Aspirin" };
            context.Prescriptions.Add(p);
            await context.SaveChangesAsync();

            var service = new PrescriptionService(context);

            // Act
            var result = await service.RequestRefillAsync(p.Id, patientUserId);

            // Assert
            Assert.NotNull(result);
            Assert.Equal("Pending", result.Status);
            Assert.Equal(patient.Id, result.PatientId);

            var dbRequest = await context.RefillRequests.FindAsync(result.Id);
            Assert.NotNull(dbRequest);
        }

        [Fact]
        public async Task RequestRefillAsync_InvalidOwnership_ThrowsUnauthorizedAccessException()
        {
            // Arrange
            using var context = GetDbContext();
            var patientUserId1 = Guid.NewGuid();
            var patientUserId2 = Guid.NewGuid(); // different patient user

            var patient1 = new Patient { Id = Guid.NewGuid(), UserId = patientUserId1, FirstName = "John", LastName = "Doe" };
            var patient2 = new Patient { Id = Guid.NewGuid(), UserId = patientUserId2, FirstName = "Jane", LastName = "Doe" };
            context.Patients.AddRange(patient1, patient2);

            var mr = new MedicalRecord { Id = patient1.Id, PatientId = patient1.Id, Patient = patient1, VisitDate = DateTime.UtcNow };
            context.MedicalRecords.Add(mr);

            var p = new Prescription { Id = Guid.NewGuid(), MedicalRecordId = mr.Id, MedicalRecord = mr, MedicationName = "Aspirin" };
            context.Prescriptions.Add(p);
            await context.SaveChangesAsync();

            var service = new PrescriptionService(context);

            // Act & Assert
            await Assert.ThrowsAsync<UnauthorizedAccessException>(() => 
                service.RequestRefillAsync(p.Id, patientUserId2));
        }

        [Fact]
        public async Task RequestRefillAsync_PrescriptionNotFound_ThrowsKeyNotFoundException()
        {
            // Arrange
            using var context = GetDbContext();
            var patientUserId = Guid.NewGuid();
            var patient = new Patient { Id = Guid.NewGuid(), UserId = patientUserId, FirstName = "John", LastName = "Doe" };
            context.Patients.Add(patient);
            await context.SaveChangesAsync();

            var service = new PrescriptionService(context);

            // Act & Assert
            await Assert.ThrowsAsync<KeyNotFoundException>(() => 
                service.RequestRefillAsync(Guid.NewGuid(), patientUserId));
        }

        [Fact]
        public async Task GetPrescriptionsAsync_PatientRole_ReturnsOwnPrescriptions()
        {
            // Arrange
            using var context = GetDbContext();
            var patientUserId = Guid.NewGuid();
            var patient = new Patient { Id = Guid.NewGuid(), UserId = patientUserId, FirstName = "John", LastName = "Doe" };
            context.Patients.Add(patient);

            var mr = new MedicalRecord { Id = Guid.NewGuid(), PatientId = patient.Id, Patient = patient, VisitDate = DateTime.UtcNow };
            context.MedicalRecords.Add(mr);

            var p = new Prescription { Id = Guid.NewGuid(), MedicalRecordId = mr.Id, MedicalRecord = mr, MedicationName = "Aspirin" };
            context.Prescriptions.Add(p);
            await context.SaveChangesAsync();

            var service = new PrescriptionService(context);

            // Act
            var result = await service.GetPrescriptionsAsync(null, null, patientUserId, "Patient");

            // Assert
            Assert.Single(result);
            Assert.Equal("Aspirin", result.First().MedicationName);
        }

        [Fact]
        public async Task GetPrescriptionsAsync_PatientRole_RequestingOtherPatientId_ThrowsUnauthorizedAccessException()
        {
            // Arrange
            using var context = GetDbContext();
            var patientUserId1 = Guid.NewGuid();
            var patient1 = new Patient { Id = Guid.NewGuid(), UserId = patientUserId1, FirstName = "John", LastName = "Doe" };
            var patient2 = new Patient { Id = Guid.NewGuid(), UserId = Guid.NewGuid(), FirstName = "Jane", LastName = "Doe" };
            context.Patients.AddRange(patient1, patient2);
            await context.SaveChangesAsync();

            var service = new PrescriptionService(context);

            // Act & Assert
            await Assert.ThrowsAsync<UnauthorizedAccessException>(() =>
                service.GetPrescriptionsAsync(null, patient2.Id, patientUserId1, "Patient"));
        }

        [Fact]
        public async Task GetPrescriptionsAsync_PatientRole_RequestingOtherMedicalRecordId_ThrowsUnauthorizedAccessException()
        {
            // Arrange
            using var context = GetDbContext();
            var patientUserId1 = Guid.NewGuid();
            var patient1 = new Patient { Id = Guid.NewGuid(), UserId = patientUserId1, FirstName = "John", LastName = "Doe" };
            var patient2 = new Patient { Id = Guid.NewGuid(), UserId = Guid.NewGuid(), FirstName = "Jane", LastName = "Doe" };
            context.Patients.AddRange(patient1, patient2);

            var mr2 = new MedicalRecord { Id = Guid.NewGuid(), PatientId = patient2.Id, Patient = patient2, VisitDate = DateTime.UtcNow };
            context.MedicalRecords.Add(mr2);
            await context.SaveChangesAsync();

            var service = new PrescriptionService(context);

            // Act & Assert
            await Assert.ThrowsAsync<UnauthorizedAccessException>(() =>
                service.GetPrescriptionsAsync(mr2.Id, null, patientUserId1, "Patient"));
        }

        [Fact]
        public async Task CreatePrescriptionAsync_InvalidMedicalRecordId_ThrowsKeyNotFoundException()
        {
            // Arrange
            using var context = GetDbContext();
            var service = new PrescriptionService(context);
            var prescription = new Prescription
            {
                Id = Guid.NewGuid(),
                MedicalRecordId = Guid.NewGuid(), // Non-existent MedicalRecordId
                MedicationName = "Aspirin"
            };

            // Act & Assert
            await Assert.ThrowsAsync<KeyNotFoundException>(() =>
                service.CreatePrescriptionAsync(prescription));
        }

        [Fact]
        public async Task RequestRefillAsync_PendingRequestExists_ThrowsApplicationException()
        {
            // Arrange
            using var context = GetDbContext();
            var patientUserId = Guid.NewGuid();
            var patient = new Patient { Id = Guid.NewGuid(), UserId = patientUserId, FirstName = "John", LastName = "Doe" };
            context.Patients.Add(patient);

            var mr = new MedicalRecord { Id = Guid.NewGuid(), PatientId = patient.Id, Patient = patient, VisitDate = DateTime.UtcNow };
            context.MedicalRecords.Add(mr);

            var p = new Prescription { Id = Guid.NewGuid(), MedicalRecordId = mr.Id, MedicalRecord = mr, MedicationName = "Aspirin" };
            context.Prescriptions.Add(p);

            var existingRefill = new RefillRequest
            {
                Id = Guid.NewGuid(),
                PrescriptionId = p.Id,
                PatientId = patient.Id,
                Status = "Pending",
                RequestDate = DateTime.UtcNow
            };
            context.RefillRequests.Add(existingRefill);
            await context.SaveChangesAsync();

            var service = new PrescriptionService(context);

            // Act & Assert
            var ex = await Assert.ThrowsAsync<ApplicationException>(() =>
                service.RequestRefillAsync(p.Id, patientUserId));
            Assert.Equal("There is already a pending refill request for this prescription.", ex.Message);
        }
    }
}
