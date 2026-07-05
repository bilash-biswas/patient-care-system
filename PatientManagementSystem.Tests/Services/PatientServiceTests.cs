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
    public class PatientServiceTests
    {
        private readonly IMapper _mapper;

        public PatientServiceTests()
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
        public async Task GetPatientsAsync_NoSearch_ReturnsPaginatedPatients()
        {
            // Arrange
            using var context = GetDbContext();
            var patients = new List<Patient>
            {
                new Patient { Id = Guid.NewGuid(), FirstName = "Alice", LastName = "Smith", Gender = "Female", UserId = Guid.NewGuid() },
                new Patient { Id = Guid.NewGuid(), FirstName = "Bob", LastName = "Jones", Gender = "Male", UserId = Guid.NewGuid() },
                new Patient { Id = Guid.NewGuid(), FirstName = "Charlie", LastName = "Brown", Gender = "Male", UserId = Guid.NewGuid() }
            };
            context.Patients.AddRange(patients);
            await context.SaveChangesAsync();

            var service = new PatientService(context, _mapper);

            // Act
            var (result, totalCount) = await service.GetPatientsAsync(null, 1, 2);

            // Assert
            Assert.Equal(3, totalCount);
            Assert.Equal(2, result.Count());
            // Ordered by LastName, then FirstName: Brown, Jones, Smith
            Assert.Equal("Brown", result.ElementAt(0).LastName);
            Assert.Equal("Jones", result.ElementAt(1).LastName);
        }

        [Fact]
        public async Task GetPatientsAsync_WithSearch_ReturnsMatchingPatients()
        {
            // Arrange
            using var context = GetDbContext();
            var patients = new List<Patient>
            {
                new Patient { Id = Guid.NewGuid(), FirstName = "Alice", LastName = "Smith", EmergencyContactName = "John Smith", UserId = Guid.NewGuid() },
                new Patient { Id = Guid.NewGuid(), FirstName = "Bob", LastName = "Jones", EmergencyContactPhone = "555-1234", UserId = Guid.NewGuid() },
                new Patient { Id = Guid.NewGuid(), FirstName = "Charlie", LastName = "Brown", UserId = Guid.NewGuid() }
            };
            context.Patients.AddRange(patients);
            await context.SaveChangesAsync();

            var service = new PatientService(context, _mapper);

            // Act
            var (result1, count1) = await service.GetPatientsAsync("Smith", 1, 10);
            var (result2, count2) = await service.GetPatientsAsync("555", 1, 10);

            // Assert
            Assert.Equal(1, count1);
            Assert.Equal("Alice", result1.First().FirstName);

            Assert.Equal(1, count2);
            Assert.Equal("Bob", result2.First().FirstName);
        }

        [Fact]
        public async Task GetPatientByIdAsync_ExistingId_ReturnsPatient()
        {
            // Arrange
            using var context = GetDbContext();
            var patientId = Guid.NewGuid();
            var patient = new Patient { Id = patientId, FirstName = "Alice", LastName = "Smith", UserId = Guid.NewGuid() };
            context.Patients.Add(patient);
            await context.SaveChangesAsync();

            var service = new PatientService(context, _mapper);

            // Act
            var result = await service.GetPatientByIdAsync(patientId);

            // Assert
            Assert.NotNull(result);
            Assert.Equal("Alice", result.FirstName);
        }

        [Fact]
        public async Task GetPatientByIdAsync_NonExistentId_ReturnsNull()
        {
            // Arrange
            using var context = GetDbContext();
            var service = new PatientService(context, _mapper);

            // Act
            var result = await service.GetPatientByIdAsync(Guid.NewGuid());

            // Assert
            Assert.Null(result);
        }

        [Fact]
        public async Task CreatePatientAsync_ValidData_CreatesAndReturnsPatient()
        {
            // Arrange
            using var context = GetDbContext();
            var userId = Guid.NewGuid();
            var service = new PatientService(context, _mapper);

            var createPatientDto = new CreatePatientDto
            {
                FirstName = "Alice",
                LastName = "Smith",
                Gender = "Female",
                DateOfBirth = new DateTime(1990, 5, 10),
                BloodGroup = "O+",
                Address = "123 Main St"
            };

            // Act
            var result = await service.CreatePatientAsync(createPatientDto, userId);

            // Assert
            Assert.NotNull(result);
            Assert.Equal("Alice", result.FirstName);
            Assert.Equal(userId, result.UserId);
            Assert.Equal(DateTimeKind.Utc, result.DateOfBirth.Kind);

            var savedPatient = await context.Patients.FindAsync(result.Id);
            Assert.NotNull(savedPatient);
            Assert.Equal("Alice", savedPatient.FirstName);
        }

        [Fact]
        public async Task UpdatePatientAsync_ExistingPatient_UpdatesAndReturnsPatient()
        {
            // Arrange
            using var context = GetDbContext();
            var patientId = Guid.NewGuid();
            var patient = new Patient
            {
                Id = patientId,
                FirstName = "Alice",
                LastName = "Smith",
                Gender = "Female",
                DateOfBirth = new DateTime(1990, 5, 10, 0, 0, 0, DateTimeKind.Utc),
                UserId = Guid.NewGuid(),
                CreatedAt = DateTime.UtcNow
            };
            context.Patients.Add(patient);
            await context.SaveChangesAsync();

            var service = new PatientService(context, _mapper);

            var updateDto = new UpdatePatientDto
            {
                FirstName = "Alicia",
                LastName = null, // Should not overwrite existing LastName
                Address = "456 Oak Rd"
            };

            // Act
            var result = await service.UpdatePatientAsync(patientId, updateDto);

            // Assert
            Assert.NotNull(result);
            Assert.Equal("Alicia", result.FirstName);
            Assert.Equal("Smith", result.LastName); // remains unchanged because updateDto.LastName is null
            Assert.Equal("456 Oak Rd", result.Address);

            var updatedPatient = await context.Patients.FindAsync(patientId);
            Assert.Equal("Alicia", updatedPatient!.FirstName);
        }

        [Fact]
        public async Task UpdatePatientAsync_NonExistentPatient_ReturnsNull()
        {
            // Arrange
            using var context = GetDbContext();
            var service = new PatientService(context, _mapper);
            var updateDto = new UpdatePatientDto { FirstName = "New Name" };

            // Act
            var result = await service.UpdatePatientAsync(Guid.NewGuid(), updateDto);

            // Assert
            Assert.Null(result);
        }

        [Fact]
        public async Task DeletePatientAsync_ExistingPatient_ReturnsTrueAndDeletes()
        {
            // Arrange
            using var context = GetDbContext();
            var patientId = Guid.NewGuid();
            var patient = new Patient { Id = patientId, FirstName = "Alice", LastName = "Smith", UserId = Guid.NewGuid() };
            context.Patients.Add(patient);
            await context.SaveChangesAsync();

            var service = new PatientService(context, _mapper);

            // Act
            var result = await service.DeletePatientAsync(patientId);

            // Assert
            Assert.True(result);
            var deletedPatient = await context.Patients.FindAsync(patientId);
            Assert.Null(deletedPatient);
        }

        [Fact]
        public async Task DeletePatientAsync_NonExistentPatient_ReturnsFalse()
        {
            // Arrange
            using var context = GetDbContext();
            var service = new PatientService(context, _mapper);

            // Act
            var result = await service.DeletePatientAsync(Guid.NewGuid());

            // Assert
            Assert.False(result);
        }

        [Fact]
        public async Task GetPatientAppointmentsAsync_ReturnsSortedAppointments()
        {
            // Arrange
            using var context = GetDbContext();
            var patientId = Guid.NewGuid();
            var doctor = new User { Id = Guid.NewGuid(), FirstName = "Dr. John", LastName = "Doe", Role = "Doctor" };
            var appointments = new List<Appointment>
            {
                new Appointment
                {
                    Id = Guid.NewGuid(),
                    PatientId = patientId,
                    DoctorId = doctor.Id,
                    Doctor = doctor,
                    AppointmentDate = DateTime.UtcNow.AddDays(2).Date,
                    StartTime = new TimeSpan(10, 0, 0),
                    Status = "Scheduled"
                },
                new Appointment
                {
                    Id = Guid.NewGuid(),
                    PatientId = patientId,
                    DoctorId = doctor.Id,
                    Doctor = doctor,
                    AppointmentDate = DateTime.UtcNow.AddDays(1).Date,
                    StartTime = new TimeSpan(14, 0, 0),
                    Status = "Scheduled"
                },
                new Appointment
                {
                    Id = Guid.NewGuid(),
                    PatientId = patientId,
                    DoctorId = doctor.Id,
                    Doctor = doctor,
                    AppointmentDate = DateTime.UtcNow.AddDays(2).Date,
                    StartTime = new TimeSpan(11, 0, 0),
                    Status = "Scheduled"
                }
            };
            context.Appointments.AddRange(appointments);
            await context.SaveChangesAsync();

            var service = new PatientService(context, _mapper);

            // Act
            var result = await service.GetPatientAppointmentsAsync(patientId);

            // Assert
            Assert.Equal(3, result.Count());
            // Sorted by AppointmentDate DESC, then StartTime DESC
            Assert.Equal(new TimeSpan(11, 0, 0), result.ElementAt(0).StartTime);
            Assert.Equal(new TimeSpan(10, 0, 0), result.ElementAt(1).StartTime);
            Assert.Equal(new TimeSpan(14, 0, 0), result.ElementAt(2).StartTime);
        }

        [Fact]
        public async Task GetPatientMedicalRecordsAsync_ReturnsSortedRecords()
        {
            // Arrange
            using var context = GetDbContext();
            var patientId = Guid.NewGuid();
            var doctor = new User { Id = Guid.NewGuid(), FirstName = "Dr. John", LastName = "Doe", Role = "Doctor" };
            var records = new List<MedicalRecord>
            {
                new MedicalRecord { Id = Guid.NewGuid(), PatientId = patientId, DoctorId = doctor.Id, Doctor = doctor, VisitDate = DateTime.UtcNow.AddDays(1) },
                new MedicalRecord { Id = Guid.NewGuid(), PatientId = patientId, DoctorId = doctor.Id, Doctor = doctor, VisitDate = DateTime.UtcNow.AddDays(3) },
                new MedicalRecord { Id = Guid.NewGuid(), PatientId = patientId, DoctorId = doctor.Id, Doctor = doctor, VisitDate = DateTime.UtcNow.AddDays(2) }
            };
            context.MedicalRecords.AddRange(records);
            await context.SaveChangesAsync();

            var service = new PatientService(context, _mapper);

            // Act
            var result = await service.GetPatientMedicalRecordsAsync(patientId);

            // Assert
            Assert.Equal(3, result.Count());
            // Sorted by VisitDate DESC
            Assert.Equal(records[1].Id, result.ElementAt(0).Id);
            Assert.Equal(records[2].Id, result.ElementAt(1).Id);
            Assert.Equal(records[0].Id, result.ElementAt(2).Id);
        }

        [Fact]
        public async Task GetPatientByUserIdAsync_ReturnsPatient()
        {
            // Arrange
            using var context = GetDbContext();
            var userId = Guid.NewGuid();
            var patient = new Patient { Id = Guid.NewGuid(), UserId = userId, FirstName = "Alice", LastName = "Smith" };
            context.Patients.Add(patient);
            await context.SaveChangesAsync();

            var service = new PatientService(context, _mapper);

            // Act
            var result = await service.GetPatientByUserIdAsync(userId);

            // Assert
            Assert.NotNull(result);
            Assert.Equal(userId, result.UserId);
        }

        [Fact]
        public async Task GetPatientByUserIdAsync_NonExistentPatient_CreatesDefaultPatientProfile()
        {
            // Arrange
            using var context = GetDbContext();
            var userId = Guid.NewGuid();
            var user = new User
            {
                Id = userId,
                FirstName = "Bob",
                LastName = "Jones",
                Email = "bob@hospital.com",
                Username = "bobjones",
                Role = "Patient",
                PhoneNumber = "123-456",
                PasswordHash = "hashed"
            };
            context.Users.Add(user);
            await context.SaveChangesAsync();

            var service = new PatientService(context, _mapper);

            // Act
            var result = await service.GetPatientByUserIdAsync(userId);

            // Assert
            Assert.NotNull(result);
            Assert.Equal(userId, result.UserId);
            Assert.Equal("Bob", result.FirstName);
            Assert.Equal("Jones", result.LastName);
            Assert.Equal("Not Specified", result.Gender);

            var dbPatient = await context.Patients.FirstOrDefaultAsync(p => p.UserId == userId);
            Assert.NotNull(dbPatient);
            Assert.Equal("Bob", dbPatient.FirstName);
        }

        [Fact]
        public async Task GetPatientByUserIdAsync_NonExistentUser_ReturnsNull()
        {
            // Arrange
            using var context = GetDbContext();
            var service = new PatientService(context, _mapper);

            // Act
            var result = await service.GetPatientByUserIdAsync(Guid.NewGuid());

            // Assert
            Assert.Null(result);
        }
    }
}
