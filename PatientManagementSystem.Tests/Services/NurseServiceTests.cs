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
    public class NurseServiceTests
    {
        private ApplicationDbContext GetDbContext()
        {
            var options = new DbContextOptionsBuilder<ApplicationDbContext>()
                .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
                .Options;
            return new ApplicationDbContext(options);
        }

        [Fact]
        public async Task GetNursesAsync_NoSearchOrFilter_ReturnsSortedNurses()
        {
            // Arrange
            using var context = GetDbContext();
            var users = new List<User>
            {
                new User { Id = Guid.NewGuid(), FirstName = "Alice", LastName = "Smith", Role = "Nurse", IsActive = true },
                new User { Id = Guid.NewGuid(), FirstName = "Bob", LastName = "Jones", Role = "Nurse", IsActive = true },
                new User { Id = Guid.NewGuid(), FirstName = "Charlie", LastName = "Brown", Role = "Doctor", IsActive = true } // Should be skipped
            };
            context.Users.AddRange(users);
            await context.SaveChangesAsync();

            var service = new NurseService(context);

            // Act
            var (result, totalCount) = await service.GetNursesAsync(null, null, 1, 10);

            // Assert
            Assert.Equal(2, totalCount);
            Assert.Equal(2, result.Count());
            // Ordered by LastName, then FirstName: Jones, Smith
            Assert.Equal("Jones", result.ElementAt(0).LastName);
            Assert.Equal("Smith", result.ElementAt(1).LastName);
        }

        [Fact]
        public async Task GetNursesAsync_WithSearch_ReturnsMatchingNurses()
        {
            // Arrange
            using var context = GetDbContext();
            var users = new List<User>
            {
                new User { Id = Guid.NewGuid(), FirstName = "Alice", LastName = "Smith", Email = "alice@hospital.com", Role = "Nurse" },
                new User { Id = Guid.NewGuid(), FirstName = "Bob", LastName = "Jones", Email = "bob@hospital.com", Role = "Nurse" }
            };
            context.Users.AddRange(users);
            await context.SaveChangesAsync();

            var service = new NurseService(context);

            // Act
            var (result, totalCount) = await service.GetNursesAsync("smith", null, 1, 10);

            // Assert
            Assert.Equal(1, totalCount);
            Assert.Equal("Alice", result.First().FirstName);
        }

        [Fact]
        public async Task GetNursesAsync_WithIsActiveFilter_ReturnsFilteredNurses()
        {
            // Arrange
            using var context = GetDbContext();
            var users = new List<User>
            {
                new User { Id = Guid.NewGuid(), FirstName = "Alice", LastName = "Smith", Role = "Nurse", IsActive = true },
                new User { Id = Guid.NewGuid(), FirstName = "Bob", LastName = "Jones", Role = "Nurse", IsActive = false }
            };
            context.Users.AddRange(users);
            await context.SaveChangesAsync();

            var service = new NurseService(context);

            // Act
            var (resultActive, countActive) = await service.GetNursesAsync(null, true, 1, 10);
            var (resultInactive, countInactive) = await service.GetNursesAsync(null, false, 1, 10);

            // Assert
            Assert.Equal(1, countActive);
            Assert.True(resultActive.First().IsActive);

            Assert.Equal(1, countInactive);
            Assert.False(resultInactive.First().IsActive);
        }

        [Fact]
        public async Task GetNurseByIdAsync_ExistingId_ReturnsNurse()
        {
            // Arrange
            using var context = GetDbContext();
            var id = Guid.NewGuid();
            var user = new User { Id = id, FirstName = "Alice", LastName = "Smith", Role = "Nurse" };
            context.Users.Add(user);
            await context.SaveChangesAsync();

            var service = new NurseService(context);

            // Act
            var result = await service.GetNurseByIdAsync(id);

            // Assert
            Assert.NotNull(result);
            Assert.Equal("Alice", result.FirstName);
        }

        [Fact]
        public async Task GetNurseByIdAsync_NonNurseOrNonExistent_ReturnsNull()
        {
            // Arrange
            using var context = GetDbContext();
            var doctorId = Guid.NewGuid();
            var doctor = new User { Id = doctorId, FirstName = "Dr. John", LastName = "Doe", Role = "Doctor" };
            context.Users.Add(doctor);
            await context.SaveChangesAsync();

            var service = new NurseService(context);

            // Act
            var resultNonExistent = await service.GetNurseByIdAsync(Guid.NewGuid());
            var resultDoctor = await service.GetNurseByIdAsync(doctorId);

            // Assert
            Assert.Null(resultNonExistent);
            Assert.Null(resultDoctor); // Should return null because it's a Doctor, not a Nurse
        }
    }
}
