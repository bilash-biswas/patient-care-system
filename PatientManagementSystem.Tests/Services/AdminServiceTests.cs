using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Distributed;
using Microsoft.Extensions.Logging;
using Moq;
using PatientManagementSystem.Data;
using PatientManagementSystem.DTOs;
using PatientManagementSystem.Models;
using PatientManagementSystem.Services;
using Xunit;

namespace PatientManagementSystem.Tests.Services
{
    public class AdminServiceTests
    {
        private static readonly JsonSerializerOptions _jsonOptions = new JsonSerializerOptions
        {
            PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
            PropertyNameCaseInsensitive = true
        };

        private ApplicationDbContext GetDbContext()
        {
            var options = new DbContextOptionsBuilder<ApplicationDbContext>()
                .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
                .Options;
            return new ApplicationDbContext(options);
        }

        [Fact]
        public async Task GetAllUsersAsync_NoCache_FetchesFromAuthServiceAndCaches()
        {
            // Arrange
            using var context = GetDbContext();
            var mockAuth = new Mock<IAuthService>();
            var mockCache = new Mock<IDistributedCache>();
            var mockLogger = new Mock<ILogger<AdminService>>();

            var users = new List<User>
            {
                new User { Id = Guid.NewGuid(), Email = "user@test.com", Username = "user", FirstName = "F", LastName = "L", Role = "Doctor", IsActive = true }
            };
            mockAuth.Setup(a => a.GetAllUsers("Doctor")).ReturnsAsync(users);

            // Setup cache return null to simulate cache miss
            mockCache.Setup(c => c.GetAsync(It.IsAny<string>(), It.IsAny<CancellationToken>()))
                .ReturnsAsync((byte[]?)null);

            byte[]? savedBytes = null;
            mockCache.Setup(c => c.SetAsync(It.IsAny<string>(), It.IsAny<byte[]>(), It.IsAny<DistributedCacheEntryOptions>(), It.IsAny<CancellationToken>()))
                .Callback<string, byte[], DistributedCacheEntryOptions, CancellationToken>((key, value, options, token) =>
                {
                    savedBytes = value;
                })
                .Returns(Task.CompletedTask);

            var service = new AdminService(context, mockAuth.Object, mockCache.Object, mockLogger.Object);

            // Act
            var result = await service.GetAllUsersAsync("Doctor");

            // Assert
            Assert.Single(result);
            Assert.Equal("user", result.First().Username);
            mockAuth.Verify(a => a.GetAllUsers("Doctor"), Times.Once);
            mockCache.Verify(c => c.SetAsync(It.IsAny<string>(), It.IsAny<byte[]>(), It.IsAny<DistributedCacheEntryOptions>(), It.IsAny<CancellationToken>()), Times.Once);

            Assert.NotNull(savedBytes);
            var deserialized = JsonSerializer.Deserialize<IEnumerable<AdminUserDto>>(Encoding.UTF8.GetString(savedBytes), _jsonOptions);
            Assert.NotNull(deserialized);
            Assert.Single(deserialized);
            Assert.Equal("user", deserialized.First().Username);
        }

        [Fact]
        public async Task GetAllUsersAsync_WithCache_ReturnsCachedUsers()
        {
            // Arrange
            using var context = GetDbContext();
            var mockAuth = new Mock<IAuthService>();
            var mockCache = new Mock<IDistributedCache>();
            var mockLogger = new Mock<ILogger<AdminService>>();

            var cachedUsers = new List<AdminUserDto>
            {
                new AdminUserDto { Id = Guid.NewGuid(), Email = "cached@test.com", Username = "cached", FirstName = "F", LastName = "L", Role = "Doctor", IsActive = true }
            };
            var json = JsonSerializer.Serialize(cachedUsers, _jsonOptions);
            var bytes = Encoding.UTF8.GetBytes(json);

            mockCache.Setup(c => c.GetAsync(It.IsAny<string>(), It.IsAny<CancellationToken>()))
                .ReturnsAsync(bytes);

            var service = new AdminService(context, mockAuth.Object, mockCache.Object, mockLogger.Object);

            // Act
            var result = await service.GetAllUsersAsync("Doctor");

            // Assert
            Assert.Single(result);
            Assert.Equal("cached", result.First().Username);
            mockAuth.Verify(a => a.GetAllUsers(It.IsAny<string>()), Times.Never); // Should not hit DB
        }

        [Fact]
        public async Task GetAllUsersAsync_CacheReadThrows_ReturnsDatabaseUsers()
        {
            // Arrange
            using var context = GetDbContext();
            var mockAuth = new Mock<IAuthService>();
            var mockCache = new Mock<IDistributedCache>();
            var mockLogger = new Mock<ILogger<AdminService>>();

            var users = new List<User>
            {
                new User { Id = Guid.NewGuid(), Email = "user@test.com", Username = "user", FirstName = "F", LastName = "L", Role = "Doctor", IsActive = true }
            };
            mockAuth.Setup(a => a.GetAllUsers("Doctor")).ReturnsAsync(users);

            // Setup cache GET to throw connection exception
            mockCache.Setup(c => c.GetAsync(It.IsAny<string>(), It.IsAny<CancellationToken>()))
                .ThrowsAsync(new Exception("Redis connection refused"));

            var service = new AdminService(context, mockAuth.Object, mockCache.Object, mockLogger.Object);

            // Act
            var result = await service.GetAllUsersAsync("Doctor");

            // Assert
            Assert.Single(result);
            Assert.Equal("user", result.First().Username);
            mockAuth.Verify(a => a.GetAllUsers("Doctor"), Times.Once); // Correctly fallbacks to DB
        }

        [Fact]
        public async Task GetAllUsersAsync_CacheWriteThrows_Succeeds()
        {
            // Arrange
            using var context = GetDbContext();
            var mockAuth = new Mock<IAuthService>();
            var mockCache = new Mock<IDistributedCache>();
            var mockLogger = new Mock<ILogger<AdminService>>();

            var users = new List<User>
            {
                new User { Id = Guid.NewGuid(), Email = "user@test.com", Username = "user", FirstName = "F", LastName = "L", Role = "Doctor", IsActive = true }
            };
            mockAuth.Setup(a => a.GetAllUsers("Doctor")).ReturnsAsync(users);

            mockCache.Setup(c => c.GetAsync(It.IsAny<string>(), It.IsAny<CancellationToken>()))
                .ReturnsAsync((byte[]?)null);

            // Setup cache SET to throw exception
            mockCache.Setup(c => c.SetAsync(It.IsAny<string>(), It.IsAny<byte[]>(), It.IsAny<DistributedCacheEntryOptions>(), It.IsAny<CancellationToken>()))
                .ThrowsAsync(new Exception("Redis read-only replica error"));

            var service = new AdminService(context, mockAuth.Object, mockCache.Object, mockLogger.Object);

            // Act
            var result = await service.GetAllUsersAsync("Doctor");

            // Assert
            Assert.Single(result);
            Assert.Equal("user", result.First().Username);
            mockAuth.Verify(a => a.GetAllUsers("Doctor"), Times.Once);
            // Write fails gracefully without bubbling up the exception
        }

        [Fact]
        public async Task GetDashboardStatsAsync_ReturnsCorrectStatistics()
        {
            // Arrange
            using var context = GetDbContext();
            
            // Seed Users (Doctors & Nurses)
            var doc = new User { Id = Guid.NewGuid(), Email = "doc@test.com", Username = "doc", FirstName = "D", LastName = "D", Role = "Doctor", IsActive = true };
            var nurse = new User { Id = Guid.NewGuid(), Email = "nurse@test.com", Username = "nurse", FirstName = "N", LastName = "N", Role = "Nurse", IsActive = true };
            var inactive = new User { Id = Guid.NewGuid(), Email = "in@test.com", Username = "in", FirstName = "I", LastName = "I", Role = "Patient", IsActive = false };
            context.Users.AddRange(doc, nurse, inactive);

            // Seed Patient
            var patient = new Patient { Id = Guid.NewGuid(), FirstName = "John", LastName = "Doe" };
            context.Patients.Add(patient);

            // Seed Appointments
            var app1 = new Appointment { Id = Guid.NewGuid(), PatientId = patient.Id, DoctorId = doc.Id, AppointmentDate = DateTime.UtcNow.Date.AddDays(1), Status = "Scheduled" };
            var app2 = new Appointment { Id = Guid.NewGuid(), PatientId = patient.Id, DoctorId = doc.Id, AppointmentDate = DateTime.UtcNow.Date.AddDays(-1), Status = "Completed" };
            context.Appointments.AddRange(app1, app2);

            // Seed Invoices
            var inv1 = new Invoice { Id = Guid.NewGuid(), PatientId = patient.Id, Amount = 100.00m, Status = "Paid" };
            var inv2 = new Invoice { Id = Guid.NewGuid(), PatientId = patient.Id, Amount = 150.00m, Status = "Paid" };
            var inv3 = new Invoice { Id = Guid.NewGuid(), PatientId = patient.Id, Amount = 200.00m, Status = "Unpaid" };
            context.Invoices.AddRange(inv1, inv2, inv3);

            await context.SaveChangesAsync();

            var mockAuth = new Mock<IAuthService>();
            var mockCache = new Mock<IDistributedCache>();
            var mockLogger = new Mock<ILogger<AdminService>>();

            // Setup cache return null for cache miss
            mockCache.Setup(c => c.GetAsync(It.IsAny<string>(), It.IsAny<CancellationToken>()))
                .ReturnsAsync((byte[]?)null);

            var service = new AdminService(context, mockAuth.Object, mockCache.Object, mockLogger.Object);

            // Act
            var result = await service.GetDashboardStatsAsync();

            // Assert
            Assert.NotNull(result);
            Assert.Equal(3, result.TotalUsers); // doc, nurse, inactive
            Assert.Equal(2, result.ActiveUsers); // doc, nurse
            Assert.Equal(1, result.TotalPatients); // patient
            Assert.Equal(1, result.TotalDoctors); // doc
            Assert.Equal(1, result.TotalNurses); // nurse
            Assert.Equal(2, result.TotalAppointments); // app1, app2
            Assert.Equal(1, result.UpcomingAppointments); // app1
            Assert.Equal(250.00m, result.TotalRevenue); // inv1 + inv2 (100 + 150)
            Assert.Equal(2, result.PaidInvoicesCount); // inv1, inv2
            Assert.Equal(1, result.UnpaidInvoicesCount); // inv3
        }

        [Fact]
        public async Task ToggleUserStatusAsync_UpdatesUserStatusAndInvalidatesCache()
        {
            // Arrange
            using var context = GetDbContext();
            var user = new User { Id = Guid.NewGuid(), Email = "test@user.com", Username = "test", FirstName = "First", LastName = "Last", Role = "Patient", IsActive = true };
            context.Users.Add(user);
            await context.SaveChangesAsync();

            var mockAuth = new Mock<IAuthService>();
            var mockCache = new Mock<IDistributedCache>();
            var mockLogger = new Mock<ILogger<AdminService>>();

            var service = new AdminService(context, mockAuth.Object, mockCache.Object, mockLogger.Object);

            // Act
            var result = await service.ToggleUserStatusAsync(user.Id, false);

            // Assert
            Assert.True(result);
            var updatedUser = await context.Users.FindAsync(user.Id);
            Assert.NotNull(updatedUser);
            Assert.False(updatedUser.IsActive);

            // Verify cache eviction keys were called
            mockCache.Verify(c => c.RemoveAsync("admin_users_all", It.IsAny<CancellationToken>()), Times.Once);
            mockCache.Verify(c => c.RemoveAsync("admin_dashboard_stats", It.IsAny<CancellationToken>()), Times.Once);
        }

        [Fact]
        public async Task ToggleUserStatusAsync_UserNotFound_ReturnsFalse()
        {
            // Arrange
            using var context = GetDbContext();
            var mockAuth = new Mock<IAuthService>();
            var mockCache = new Mock<IDistributedCache>();
            var mockLogger = new Mock<ILogger<AdminService>>();

            var service = new AdminService(context, mockAuth.Object, mockCache.Object, mockLogger.Object);

            // Act
            var result = await service.ToggleUserStatusAsync(Guid.NewGuid(), false);

            // Assert
            Assert.False(result);
        }
    }
}
