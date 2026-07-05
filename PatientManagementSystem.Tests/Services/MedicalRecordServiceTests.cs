using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using Microsoft.EntityFrameworkCore;
using PatientManagementSystem.Data;
using PatientManagementSystem.DTOs;
using PatientManagementSystem.Helpers;
using PatientManagementSystem.Models;
using PatientManagementSystem.Services;
using Xunit;

namespace PatientManagementSystem.Tests.Services
{
    public class MedicalRecordServiceTests
    {
        private readonly IMapper _mapper;

        public MedicalRecordServiceTests()
        {
            var config = new MapperConfiguration(cfg =>
            {
                cfg.AddProfile<AutoMapperProfile>();
            });
            _mapper = config.CreateMapper();
        }

        private ApplicationDbContext GetDbContext()
        {
            var options = new DbContextOptionsBuilder<ApplicationDbContext>()
                .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
                .Options;
            return new ApplicationDbContext(options);
        }

        [Fact]
        public async Task GetMedicalRecordsAsync_DoctorRole_FiltersByDoctorId()
        {
            // Arrange
            using var context = GetDbContext();
            var doctorId1 = Guid.NewGuid();
            var doctorId2 = Guid.NewGuid();

            var doctor1 = new User { Id = doctorId1, FirstName = "Jane", LastName = "Smith", Role = "Doctor" };
            var doctor2 = new User { Id = doctorId2, FirstName = "John", LastName = "Smith", Role = "Doctor" };
            var patient = new Patient { Id = Guid.NewGuid(), UserId = Guid.NewGuid(), FirstName = "John", LastName = "Doe" };
            
            context.Users.AddRange(doctor1, doctor2);
            context.Patients.Add(patient);

            var records = new List<MedicalRecord>
            {
                new MedicalRecord { Id = Guid.NewGuid(), DoctorId = doctorId1, Doctor = doctor1, PatientId = patient.Id, Patient = patient, VisitDate = DateTime.UtcNow, Diagnosis = "Checkup 1" },
                new MedicalRecord { Id = Guid.NewGuid(), DoctorId = doctorId2, Doctor = doctor2, PatientId = patient.Id, Patient = patient, VisitDate = DateTime.UtcNow, Diagnosis = "Checkup 2" }
            };
            context.MedicalRecords.AddRange(records);
            await context.SaveChangesAsync();

            var service = new MedicalRecordService(context, _mapper);

            // Act
            var (result, totalCount) = await service.GetMedicalRecordsAsync(null, null, null, null, null, doctorId1, "Doctor", 1, 10);

            // Assert
            Assert.Equal(1, totalCount);
            Assert.Equal(doctorId1, result.First().DoctorId);
        }

        [Fact]
        public async Task CreateMedicalRecordAsync_ValidData_CreatesRecord()
        {
            // Arrange
            using var context = GetDbContext();
            var doctorId = Guid.NewGuid();
            var patientId = Guid.NewGuid();

            var doctor = new User { Id = doctorId, FirstName = "Jane", LastName = "Smith", Role = "Doctor" };
            var patient = new Patient { Id = patientId, UserId = Guid.NewGuid(), FirstName = "John", LastName = "Doe" };
            
            context.Users.Add(doctor);
            context.Patients.Add(patient);
            await context.SaveChangesAsync();

            var service = new MedicalRecordService(context, _mapper);
            var createDto = new CreateMedicalRecordDto
            {
                PatientId = patientId,
                DoctorId = doctorId,
                VisitDate = DateTime.UtcNow,
                Diagnosis = "Flu",
                Treatment = "Rest",
                Notes = "Drink water"
            };

            // Act
            var result = await service.CreateMedicalRecordAsync(createDto, doctorId);

            // Assert
            Assert.NotNull(result);
            Assert.Equal("Flu", result.Diagnosis);
            Assert.Equal(doctorId, result.DoctorId);

            var dbRecord = await context.MedicalRecords.FindAsync(result.Id);
            Assert.NotNull(dbRecord);
        }

        [Fact]
        public async Task GetMedicalRecordByIdAsync_UnauthorizedDoctor_ThrowsUnauthorizedAccessException()
        {
            // Arrange
            using var context = GetDbContext();
            var doctorId1 = Guid.NewGuid();
            var doctorId2 = Guid.NewGuid();

            var doctor1 = new User { Id = doctorId1, FirstName = "Jane", LastName = "Smith", Role = "Doctor" };
            var patient = new Patient { Id = Guid.NewGuid(), UserId = Guid.NewGuid(), FirstName = "John", LastName = "Doe" };
            context.Users.Add(doctor1);
            context.Patients.Add(patient);

            var record = new MedicalRecord
            {
                Id = Guid.NewGuid(),
                DoctorId = doctorId1,
                Doctor = doctor1,
                PatientId = patient.Id,
                Patient = patient,
                VisitDate = DateTime.UtcNow,
                Diagnosis = "Cold"
            };
            context.MedicalRecords.Add(record);
            await context.SaveChangesAsync();

            var service = new MedicalRecordService(context, _mapper);

            // Act & Assert
            await Assert.ThrowsAsync<UnauthorizedAccessException>(() => 
                service.GetMedicalRecordByIdAsync(record.Id, doctorId2, "Doctor"));
        }

        [Fact]
        public async Task UpdateMedicalRecordAsync_ValidData_UpdatesRecord()
        {
            // Arrange
            using var context = GetDbContext();
            var doctorId = Guid.NewGuid();

            var doctor = new User { Id = doctorId, FirstName = "Jane", LastName = "Smith", Role = "Doctor" };
            var patient = new Patient { Id = Guid.NewGuid(), UserId = Guid.NewGuid(), FirstName = "John", LastName = "Doe" };
            context.Users.Add(doctor);
            context.Patients.Add(patient);

            var record = new MedicalRecord
            {
                Id = Guid.NewGuid(),
                DoctorId = doctorId,
                Doctor = doctor,
                PatientId = patient.Id,
                Patient = patient,
                VisitDate = DateTime.UtcNow,
                Diagnosis = "Cold"
            };
            context.MedicalRecords.Add(record);
            await context.SaveChangesAsync();

            var service = new MedicalRecordService(context, _mapper);
            var updateDto = new CreateMedicalRecordDto
            {
                PatientId = patient.Id,
                DoctorId = doctorId,
                VisitDate = DateTime.UtcNow,
                Diagnosis = "Flu",
                Treatment = "Meds"
            };

            // Act
            var result = await service.UpdateMedicalRecordAsync(record.Id, updateDto, doctorId, "Doctor");

            // Assert
            Assert.NotNull(result);
            Assert.Equal("Flu", result.Diagnosis);
            Assert.Equal("Meds", result.Treatment);
        }

        [Fact]
        public async Task DeleteMedicalRecordAsync_ExistingRecord_DeletesRecord()
        {
            // Arrange
            using var context = GetDbContext();
            var record = new MedicalRecord
            {
                Id = Guid.NewGuid(),
                PatientId = Guid.NewGuid(),
                DoctorId = Guid.NewGuid(),
                VisitDate = DateTime.UtcNow,
                Diagnosis = "Cold"
            };
            context.MedicalRecords.Add(record);
            await context.SaveChangesAsync();

            var service = new MedicalRecordService(context, _mapper);

            // Act
            var result = await service.DeleteMedicalRecordAsync(record.Id);

            // Assert
            Assert.True(result);
            var dbRecord = await context.MedicalRecords.FindAsync(record.Id);
            Assert.Null(dbRecord);
        }

        [Fact]
        public async Task GetMedicalRecordsAsync_PatientRole_FiltersByPatientUserId()
        {
            // Arrange
            using var context = GetDbContext();
            var patientUserId1 = Guid.NewGuid();
            var patientUserId2 = Guid.NewGuid();
            var doctorId = Guid.NewGuid();

            var doctor = new User { Id = doctorId, FirstName = "Jane", LastName = "Smith", Role = "Doctor" };
            var patient1 = new Patient { Id = Guid.NewGuid(), UserId = patientUserId1, FirstName = "John", LastName = "Doe" };
            var patient2 = new Patient { Id = Guid.NewGuid(), UserId = patientUserId2, FirstName = "Billy", LastName = "Bob" };
            
            context.Users.Add(doctor);
            context.Patients.AddRange(patient1, patient2);

            var records = new List<MedicalRecord>
            {
                new MedicalRecord { Id = Guid.NewGuid(), DoctorId = doctorId, Doctor = doctor, PatientId = patient1.Id, Patient = patient1, VisitDate = DateTime.UtcNow, Diagnosis = "Checkup 1" },
                new MedicalRecord { Id = Guid.NewGuid(), DoctorId = doctorId, Doctor = doctor, PatientId = patient2.Id, Patient = patient2, VisitDate = DateTime.UtcNow, Diagnosis = "Checkup 2" }
            };
            context.MedicalRecords.AddRange(records);
            await context.SaveChangesAsync();

            var service = new MedicalRecordService(context, _mapper);

            // Act
            var (result, totalCount) = await service.GetMedicalRecordsAsync(null, null, null, null, null, patientUserId1, "Patient", 1, 10);

            // Assert
            Assert.Equal(1, totalCount);
            Assert.Equal(patient1.Id, result.First().PatientId);
        }

        [Fact]
        public async Task GetMedicalRecordByIdAsync_UnauthorizedPatient_ThrowsUnauthorizedAccessException()
        {
            // Arrange
            using var context = GetDbContext();
            var patientUserId1 = Guid.NewGuid();
            var patientUserId2 = Guid.NewGuid();
            var doctorId = Guid.NewGuid();

            var doctor = new User { Id = doctorId, FirstName = "Jane", LastName = "Smith", Role = "Doctor" };
            var patient1 = new Patient { Id = Guid.NewGuid(), UserId = patientUserId1, FirstName = "John", LastName = "Doe" };
            context.Users.Add(doctor);
            context.Patients.Add(patient1);

            var record = new MedicalRecord
            {
                Id = Guid.NewGuid(),
                DoctorId = doctorId,
                Doctor = doctor,
                PatientId = patient1.Id,
                Patient = patient1,
                VisitDate = DateTime.UtcNow,
                Diagnosis = "Cold"
            };
            context.MedicalRecords.Add(record);
            await context.SaveChangesAsync();

            var service = new MedicalRecordService(context, _mapper);

            // Act & Assert
            await Assert.ThrowsAsync<UnauthorizedAccessException>(() => 
                service.GetMedicalRecordByIdAsync(record.Id, patientUserId2, "Patient"));
        }
    }
}
