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
    public class AppointmentServiceTests
    {
        private readonly IMapper _mapper;

        public AppointmentServiceTests()
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
        public async Task GetAppointmentsAsync_DoctorRole_FiltersByDoctorId()
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

            var appointments = new List<Appointment>
            {
                new Appointment { Id = Guid.NewGuid(), DoctorId = doctorId1, Doctor = doctor1, PatientId = patient.Id, Patient = patient, Status = "Scheduled" },
                new Appointment { Id = Guid.NewGuid(), DoctorId = doctorId2, Doctor = doctor2, PatientId = patient.Id, Patient = patient, Status = "Scheduled" }
            };
            context.Appointments.AddRange(appointments);
            await context.SaveChangesAsync();

            var service = new AppointmentService(context, _mapper);

            // Act
            var (result, totalCount) = await service.GetAppointmentsAsync(null, null, null, null, null, doctorId1, "Doctor", 1, 10);

            // Assert
            Assert.Equal(1, totalCount);
            Assert.Equal(doctorId1, result.First().DoctorId);
        }

        [Fact]
        public async Task CreateAppointmentAsync_ValidRequest_CreatesAppointment()
        {
            // Arrange
            using var context = GetDbContext();
            var doctorId = Guid.NewGuid();
            var patientUserId = Guid.NewGuid();

            var doctor = new User { Id = doctorId, FirstName = "Jane", LastName = "Smith", Role = "Doctor" };
            var patient = new Patient { Id = Guid.NewGuid(), UserId = patientUserId, FirstName = "John", LastName = "Doe" };
            
            context.Users.Add(doctor);
            context.Patients.Add(patient);

            // Set up Doctor Availability for Monday (Date 2026-06-22 is a Monday)
            var availability = new DoctorAvailability
            {
                Id = Guid.NewGuid(),
                DoctorId = doctorId,
                DayOfWeek = DayOfWeek.Monday,
                StartTime = new TimeSpan(9, 0, 0),
                EndTime = new TimeSpan(17, 0, 0),
                IsAvailable = true
            };
            context.DoctorAvailabilities.Add(availability);
            await context.SaveChangesAsync();

            var service = new AppointmentService(context, _mapper);
            var createDto = new CreateAppointmentDto
            {
                DoctorId = doctorId,
                PatientId = patient.Id,
                AppointmentDate = new DateTime(2026, 6, 22), // Monday
                StartTime = new TimeSpan(10, 0, 0),
                EndTime = new TimeSpan(10, 30, 0),
                Reason = "Checkup"
            };

            // Act
            var result = await service.CreateAppointmentAsync(createDto, patientUserId, "Patient");

            // Assert
            Assert.NotNull(result);
            Assert.Equal("Scheduled", result.Status);
            Assert.Equal(patient.Id, result.PatientId);

            var dbAppointment = await context.Appointments.FindAsync(result.Id);
            Assert.NotNull(dbAppointment);
        }

        [Fact]
        public async Task CreateAppointmentAsync_DoctorNotAvailable_ThrowsApplicationException()
        {
            // Arrange
            using var context = GetDbContext();
            var doctorId = Guid.NewGuid();
            var patientUserId = Guid.NewGuid();

            var doctor = new User { Id = doctorId, FirstName = "Jane", LastName = "Smith", Role = "Doctor" };
            var patient = new Patient { Id = Guid.NewGuid(), UserId = patientUserId, FirstName = "John", LastName = "Doe" };
            
            context.Users.Add(doctor);
            context.Patients.Add(patient);

            // Set up Doctor Availability as unavailable for Monday
            var availability = new DoctorAvailability
            {
                Id = Guid.NewGuid(),
                DoctorId = doctorId,
                DayOfWeek = DayOfWeek.Monday,
                IsAvailable = false
            };
            context.DoctorAvailabilities.Add(availability);
            await context.SaveChangesAsync();

            var service = new AppointmentService(context, _mapper);
            var createDto = new CreateAppointmentDto
            {
                DoctorId = doctorId,
                PatientId = patient.Id,
                AppointmentDate = new DateTime(2026, 6, 22), // Monday
                StartTime = new TimeSpan(10, 0, 0),
                EndTime = new TimeSpan(10, 30, 0),
                Reason = "Checkup"
            };

            // Act & Assert
            var ex = await Assert.ThrowsAsync<ApplicationException>(() => service.CreateAppointmentAsync(createDto, patientUserId, "Patient"));
            Assert.Equal("Doctor is not available at this time", ex.Message);
        }

        [Fact]
        public async Task CreateAppointmentAsync_TimeConflict_ThrowsApplicationException()
        {
            // Arrange
            using var context = GetDbContext();
            var doctorId = Guid.NewGuid();
            var patientUserId = Guid.NewGuid();

            var doctor = new User { Id = doctorId, FirstName = "Jane", LastName = "Smith", Role = "Doctor" };
            var patient = new Patient { Id = Guid.NewGuid(), UserId = patientUserId, FirstName = "John", LastName = "Doe" };
            
            context.Users.Add(doctor);
            context.Patients.Add(patient);

            // 1. Existing appointment
            var existingAppt = new Appointment
            {
                Id = Guid.NewGuid(),
                DoctorId = doctorId,
                PatientId = patient.Id,
                AppointmentDate = new DateTime(2026, 6, 22),
                StartTime = new TimeSpan(10, 0, 0),
                EndTime = new TimeSpan(10, 30, 0),
                Status = "Scheduled"
            };
            context.Appointments.Add(existingAppt);

            // Set up Doctor Availability to be open
            var availability = new DoctorAvailability
            {
                Id = Guid.NewGuid(),
                DoctorId = doctorId,
                DayOfWeek = DayOfWeek.Monday,
                StartTime = new TimeSpan(9, 0, 0),
                EndTime = new TimeSpan(17, 0, 0),
                IsAvailable = true
            };
            context.DoctorAvailabilities.Add(availability);
            await context.SaveChangesAsync();

            var service = new AppointmentService(context, _mapper);
            
            // Conflicting appointment request (overlapping time)
            var createDto = new CreateAppointmentDto
            {
                DoctorId = doctorId,
                PatientId = patient.Id,
                AppointmentDate = new DateTime(2026, 6, 22),
                StartTime = new TimeSpan(10, 15, 0),
                EndTime = new TimeSpan(10, 45, 0),
                Reason = "Checkup overlapping"
            };

            // Act & Assert
            var ex = await Assert.ThrowsAsync<ApplicationException>(() => service.CreateAppointmentAsync(createDto, patientUserId, "Patient"));
            Assert.Equal("Appointment time conflicts with existing appointment", ex.Message);
        }

        [Fact]
        public async Task GetAppointmentByIdAsync_UnauthorizedUser_ThrowsUnauthorizedAccessException()
        {
            // Arrange
            using var context = GetDbContext();
            var doctorId1 = Guid.NewGuid();
            var doctorId2 = Guid.NewGuid(); // different doctor

            var doctor1 = new User { Id = doctorId1, FirstName = "Jane", LastName = "Smith", Role = "Doctor" };
            var patient = new Patient { Id = Guid.NewGuid(), UserId = Guid.NewGuid(), FirstName = "John", LastName = "Doe" };
            context.Users.Add(doctor1);
            context.Patients.Add(patient);

            var appointment = new Appointment
            {
                Id = Guid.NewGuid(),
                DoctorId = doctorId1,
                Doctor = doctor1,
                PatientId = patient.Id,
                Patient = patient,
                Status = "Scheduled"
            };
            context.Appointments.Add(appointment);
            await context.SaveChangesAsync();

            var service = new AppointmentService(context, _mapper);

            // Act & Assert
            await Assert.ThrowsAsync<UnauthorizedAccessException>(() => 
                service.GetAppointmentByIdAsync(appointment.Id, doctorId2, "Doctor"));
        }

        [Fact]
        public async Task UpdateAppointmentStatusAsync_ValidStatus_UpdatesStatus()
        {
            // Arrange
            using var context = GetDbContext();
            var doctorId = Guid.NewGuid();

            var doctor = new User { Id = doctorId, FirstName = "Jane", LastName = "Smith", Role = "Doctor" };
            var patient = new Patient { Id = Guid.NewGuid(), UserId = Guid.NewGuid(), FirstName = "John", LastName = "Doe" };
            context.Users.Add(doctor);
            context.Patients.Add(patient);

            var appointment = new Appointment
            {
                Id = Guid.NewGuid(),
                DoctorId = doctorId,
                Doctor = doctor,
                PatientId = patient.Id,
                Patient = patient,
                Status = "Scheduled"
            };
            context.Appointments.Add(appointment);
            await context.SaveChangesAsync();

            var service = new AppointmentService(context, _mapper);

            // Act
            var result = await service.UpdateAppointmentStatusAsync(appointment.Id, "Completed", doctorId, "Doctor");

            // Assert
            Assert.NotNull(result);
            Assert.Equal("Completed", result.Status);
        }

        [Fact]
        public async Task DeleteAppointmentAsync_AuthorizedDoctor_DeletesAppointment()
        {
            // Arrange
            using var context = GetDbContext();
            var doctorId = Guid.NewGuid();
            
            var doctor = new User { Id = doctorId, FirstName = "Jane", LastName = "Smith", Role = "Doctor" };
            var patient = new Patient { Id = Guid.NewGuid(), UserId = Guid.NewGuid(), FirstName = "John", LastName = "Doe" };
            context.Users.Add(doctor);
            context.Patients.Add(patient);

            var appointment = new Appointment
            {
                Id = Guid.NewGuid(),
                DoctorId = doctorId,
                Doctor = doctor,
                PatientId = patient.Id,
                Patient = patient,
                Status = "Scheduled"
            };
            context.Appointments.Add(appointment);
            await context.SaveChangesAsync();

            var service = new AppointmentService(context, _mapper);

            // Act
            var result = await service.DeleteAppointmentAsync(appointment.Id, doctorId, "Doctor");

            // Assert
            Assert.True(result);
            var dbAppointment = await context.Appointments.FindAsync(appointment.Id);
            Assert.Null(dbAppointment);
        }
    }
}
