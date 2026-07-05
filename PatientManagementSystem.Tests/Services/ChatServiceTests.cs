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
    public class ChatServiceTests
    {
        private ApplicationDbContext GetDbContext()
        {
            var options = new DbContextOptionsBuilder<ApplicationDbContext>()
                .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
                .Options;
            return new ApplicationDbContext(options);
        }

        [Fact]
        public async Task GetDirectoryAsync_PatientRole_ReturnsOnlyActiveDoctors()
        {
            // Arrange
            using var context = GetDbContext();
            var patientId = Guid.NewGuid();
            
            var doctor1 = new User { Id = Guid.NewGuid(), FirstName = "Dr1", LastName = "D", Role = "Doctor", IsActive = true };
            var doctor2 = new User { Id = Guid.NewGuid(), FirstName = "Dr2", LastName = "D", Role = "Doctor", IsActive = false }; // inactive
            var nurse = new User { Id = Guid.NewGuid(), FirstName = "Nurse1", LastName = "N", Role = "Nurse", IsActive = true };
            var patient = new User { Id = patientId, FirstName = "Pat1", LastName = "P", Role = "Patient", IsActive = true };

            context.Users.AddRange(doctor1, doctor2, nurse, patient);
            await context.SaveChangesAsync();

            var service = new ChatService(context);

            // Act
            var (result, totalCount) = await service.GetDirectoryAsync(null, null, true, 1, 10, patientId, "Patient");

            // Assert
            Assert.Equal(1, totalCount);
            Assert.Single(result);
            Assert.Equal(doctor1.Id, result.First().Id);
        }

        [Fact]
        public async Task GetDirectoryAsync_DoctorRole_ReturnsNursesAndPatients()
        {
            // Arrange
            using var context = GetDbContext();
            var doctorId = Guid.NewGuid();
            
            var doctor = new User { Id = doctorId, FirstName = "Dr", LastName = "D", Role = "Doctor", IsActive = true };
            var nurse = new User { Id = Guid.NewGuid(), FirstName = "Nurse1", LastName = "N", Role = "Nurse", IsActive = true };
            var patient = new User { Id = Guid.NewGuid(), FirstName = "Pat1", LastName = "P", Role = "Patient", IsActive = true };
            var admin = new User { Id = Guid.NewGuid(), FirstName = "Admin1", LastName = "A", Role = "Admin", IsActive = true };

            context.Users.AddRange(doctor, nurse, patient, admin);
            await context.SaveChangesAsync();

            var service = new ChatService(context);

            // Act
            var (result, totalCount) = await service.GetDirectoryAsync(null, null, true, 1, 10, doctorId, "Doctor");

            // Assert
            Assert.Equal(2, totalCount);
            Assert.Equal(2, result.Count());
            Assert.Contains(result, u => u.Role == "Nurse");
            Assert.Contains(result, u => u.Role == "Patient");
            Assert.DoesNotContain(result, u => u.Role == "Admin");
        }

        [Fact]
        public async Task GetMessagesAsync_AllowedChat_ReturnsMessages()
        {
            // Arrange
            using var context = GetDbContext();
            var docId = Guid.NewGuid();
            var patId = Guid.NewGuid();

            var doctor = new User { Id = docId, FirstName = "Dr", LastName = "D", Role = "Doctor", IsActive = true };
            var patient = new User { Id = patId, FirstName = "Pat", LastName = "P", Role = "Patient", IsActive = true };
            context.Users.AddRange(doctor, patient);

            var m1 = new Message { Id = Guid.NewGuid(), SenderId = docId, ReceiverId = patId, Content = "Hello Patient", SentAt = DateTime.UtcNow.AddMinutes(-5) };
            var m2 = new Message { Id = Guid.NewGuid(), SenderId = patId, ReceiverId = docId, Content = "Hello Doctor", SentAt = DateTime.UtcNow };
            context.Messages.AddRange(m1, m2);
            await context.SaveChangesAsync();

            var service = new ChatService(context);

            // Act
            var (result, totalCount) = await service.GetMessagesAsync(docId, patId, 1, 10);

            // Assert
            Assert.Equal(2, totalCount);
            Assert.Equal(2, result.Count());
            Assert.Equal("Hello Patient", result.ElementAt(0).Content);
            Assert.Equal("Hello Doctor", result.ElementAt(1).Content);
        }

        [Fact]
        public async Task GetMessagesAsync_UnallowedChat_ThrowsUnauthorizedAccessException()
        {
            // Arrange
            using var context = GetDbContext();
            var pat1Id = Guid.NewGuid();
            var pat2Id = Guid.NewGuid();

            var patient1 = new User { Id = pat1Id, FirstName = "Pat1", LastName = "P", Role = "Patient", IsActive = true };
            var patient2 = new User { Id = pat2Id, FirstName = "Pat2", LastName = "P", Role = "Patient", IsActive = true };
            context.Users.AddRange(patient1, patient2);
            await context.SaveChangesAsync();

            var service = new ChatService(context);

            // Act & Assert
            await Assert.ThrowsAsync<UnauthorizedAccessException>(() =>
                service.GetMessagesAsync(pat1Id, pat2Id, 1, 10));
        }

        [Fact]
        public async Task GetConversationsAsync_ReturnsActiveConversations()
        {
            // Arrange
            using var context = GetDbContext();
            var currentUserId = Guid.NewGuid();
            var otherUserId = Guid.NewGuid();

            var currentUser = new User { Id = currentUserId, FirstName = "Current", LastName = "C", Role = "Doctor", IsActive = true };
            var otherUser = new User { Id = otherUserId, FirstName = "Other", LastName = "O", Role = "Patient", IsActive = true };
            context.Users.AddRange(currentUser, otherUser);

            var message = new Message { Id = Guid.NewGuid(), SenderId = currentUserId, ReceiverId = otherUserId, Content = "Hi", SentAt = DateTime.UtcNow };
            context.Messages.Add(message);
            await context.SaveChangesAsync();

            var service = new ChatService(context);

            // Act
            var result = await service.GetConversationsAsync(currentUserId);

            // Assert
            Assert.Single(result);
            Assert.Equal(otherUserId, result.First().Id);
        }

        [Fact]
        public async Task SaveMessageAsync_AllowedChat_SavesMessage()
        {
            // Arrange
            using var context = GetDbContext();
            var senderId = Guid.NewGuid();
            var receiverId = Guid.NewGuid();

            var sender = new User { Id = senderId, FirstName = "Sender", LastName = "S", Role = "Doctor", IsActive = true };
            var receiver = new User { Id = receiverId, FirstName = "Receiver", LastName = "R", Role = "Patient", IsActive = true };
            context.Users.AddRange(sender, receiver);
            await context.SaveChangesAsync();

            var service = new ChatService(context);

            // Act
            var result = await service.SaveMessageAsync(senderId, receiverId, "Test Message");

            // Assert
            Assert.NotNull(result);
            Assert.Equal("Test Message", result.Content);
            Assert.Equal(senderId, result.SenderId);
            Assert.Equal(receiverId, result.ReceiverId);

            var dbMessage = await context.Messages.FirstOrDefaultAsync(m => m.Id == result.Id);
            Assert.NotNull(dbMessage);
            Assert.Equal("Test Message", dbMessage.Content);
        }

        [Fact]
        public async Task SaveMessageAsync_UnallowedChat_ThrowsUnauthorizedAccessException()
        {
            // Arrange
            using var context = GetDbContext();
            var senderId = Guid.NewGuid();
            var receiverId = Guid.NewGuid();

            var sender = new User { Id = senderId, FirstName = "Sender", LastName = "S", Role = "Patient", IsActive = true };
            var receiver = new User { Id = receiverId, FirstName = "Receiver", LastName = "R", Role = "Patient", IsActive = true }; // Patient to Patient is not allowed
            context.Users.AddRange(sender, receiver);
            await context.SaveChangesAsync();

            var service = new ChatService(context);

            // Act & Assert
            await Assert.ThrowsAsync<UnauthorizedAccessException>(() =>
                service.SaveMessageAsync(senderId, receiverId, "Invalid Message"));
        }
    }
}
