using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Moq;
using PatientManagementSystem.Data;
using PatientManagementSystem.DTOs;
using PatientManagementSystem.Helpers;
using PatientManagementSystem.Models;
using PatientManagementSystem.Services;
using Xunit;

namespace PatientManagementSystem.Tests.Services
{
    public class AuthServiceTests
    {
        private readonly Mock<IJwtHelper> _mockJwtHelper;
        private readonly Mock<ILogger<AuthService>> _mockLogger;
        private readonly JwtSettings _jwtSettings;

        public AuthServiceTests()
        {
            _mockJwtHelper = new Mock<IJwtHelper>();
            _mockLogger = new Mock<ILogger<AuthService>>();
            _jwtSettings = new JwtSettings
            {
                Secret = "SuperSecretKeyForTesting1234567890!",
                Issuer = "TestIssuer",
                Audience = "TestAudience",
                TokenExpirationInMinutes = 60,
                RefreshTokenExpirationInDays = 7
            };
        }

        private ApplicationDbContext GetDbContext()
        {
            var options = new DbContextOptionsBuilder<ApplicationDbContext>()
                .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
                .Options;
            return new ApplicationDbContext(options);
        }

        [Fact]
        public async Task Register_Successful_ReturnsAuthResponseDto()
        {
            // Arrange
            using var context = GetDbContext();
            var service = new AuthService(context, _mockJwtHelper.Object, _mockLogger.Object, _jwtSettings);

            var registerDto = new RegisterDto
            {
                Email = "test@example.com",
                Username = "testuser",
                Password = "Password123!",
                FirstName = "Test",
                LastName = "User",
                PhoneNumber = "1234567890",
                Role = "Patient"
            };

            var user = new User { Id = Guid.NewGuid(), Email = registerDto.Email, Username = registerDto.Username };
            _mockJwtHelper.Setup(h => h.GenerateToken(It.IsAny<User>())).Returns("mock-access-token");
            _mockJwtHelper.Setup(h => h.GenerateRefreshToken(It.IsAny<string>())).Returns(new RefreshToken
            {
                Token = "mock-refresh-token",
                Expires = DateTime.UtcNow.AddDays(7),
                Created = DateTime.UtcNow
            });

            // Act
            var result = await service.Register(registerDto, "127.0.0.1");

            // Assert
            Assert.NotNull(result);
            Assert.Equal(registerDto.Email, result.Email);
            Assert.Equal(registerDto.Username, result.Username);
            Assert.Equal("mock-access-token", result.Token);
            Assert.Equal("mock-refresh-token", result.RefreshToken);

            var savedUser = await context.Users.Include(u => u.RefreshTokens).FirstOrDefaultAsync(u => u.Email == registerDto.Email);
            Assert.NotNull(savedUser);
            Assert.True(BCrypt.Net.BCrypt.Verify(registerDto.Password, savedUser.PasswordHash));
            Assert.Single(savedUser.RefreshTokens);
        }

        [Fact]
        public async Task Register_ExistingEmail_ThrowsApplicationException()
        {
            // Arrange
            using var context = GetDbContext();
            var existingUser = new User
            {
                Id = Guid.NewGuid(),
                Email = "duplicate@example.com",
                Username = "uniqueuser",
                PasswordHash = "hash"
            };
            context.Users.Add(existingUser);
            await context.SaveChangesAsync();

            var service = new AuthService(context, _mockJwtHelper.Object, _mockLogger.Object, _jwtSettings);
            var registerDto = new RegisterDto
            {
                Email = "duplicate@example.com",
                Username = "newuser",
                Password = "Password123!",
                FirstName = "New",
                LastName = "User",
                Role = "Patient"
            };

            // Act & Assert
            var ex = await Assert.ThrowsAsync<ApplicationException>(() => service.Register(registerDto, "127.0.0.1"));
            Assert.Equal("Email is already registered", ex.Message);
        }

        [Fact]
        public async Task Register_ExistingUsername_ThrowsApplicationException()
        {
            // Arrange
            using var context = GetDbContext();
            var existingUser = new User
            {
                Id = Guid.NewGuid(),
                Email = "unique@example.com",
                Username = "duplicateuser",
                PasswordHash = "hash"
            };
            context.Users.Add(existingUser);
            await context.SaveChangesAsync();

            var service = new AuthService(context, _mockJwtHelper.Object, _mockLogger.Object, _jwtSettings);
            var registerDto = new RegisterDto
            {
                Email = "new@example.com",
                Username = "duplicateuser",
                Password = "Password123!",
                FirstName = "New",
                LastName = "User",
                Role = "Patient"
            };

            // Act & Assert
            var ex = await Assert.ThrowsAsync<ApplicationException>(() => service.Register(registerDto, "127.0.0.1"));
            Assert.Equal("Username is already taken", ex.Message);
        }

        [Fact]
        public async Task Register_InvalidRole_ThrowsApplicationException()
        {
            // Arrange
            using var context = GetDbContext();
            var service = new AuthService(context, _mockJwtHelper.Object, _mockLogger.Object, _jwtSettings);
            var registerDto = new RegisterDto
            {
                Email = "new@example.com",
                Username = "newuser",
                Password = "Password123!",
                FirstName = "New",
                LastName = "User",
                Role = "SuperAdmin" // Invalid role
            };

            // Act & Assert
            var ex = await Assert.ThrowsAsync<ApplicationException>(() => service.Register(registerDto, "127.0.0.1"));
            Assert.Equal("Invalid Role", ex.Message);
        }

        [Fact]
        public async Task Login_Successful_ReturnsAuthResponseDto()
        {
            // Arrange
            using var context = GetDbContext();
            var userId = Guid.NewGuid();
            var hashedPassword = BCrypt.Net.BCrypt.HashPassword("Password123!");
            var existingUser = new User
            {
                Id = userId,
                Email = "test@example.com",
                Username = "testuser",
                PasswordHash = hashedPassword,
                IsActive = true,
                FirstName = "Test",
                LastName = "User",
                Role = "Patient"
            };
            context.Users.Add(existingUser);
            await context.SaveChangesAsync();

            var service = new AuthService(context, _mockJwtHelper.Object, _mockLogger.Object, _jwtSettings);
            var loginDto = new LoginDto
            {
                Email = "test@example.com",
                Password = "Password123!"
            };

            _mockJwtHelper.Setup(h => h.GenerateToken(It.IsAny<User>())).Returns("mock-access-token");
            _mockJwtHelper.Setup(h => h.GenerateRefreshToken(It.IsAny<string>())).Returns(new RefreshToken
            {
                Token = "mock-refresh-token",
                Expires = DateTime.UtcNow.AddDays(7),
                Created = DateTime.UtcNow
            });

            // Act
            var result = await service.Login(loginDto, "127.0.0.1");

            // Assert
            Assert.NotNull(result);
            Assert.Equal("test@example.com", result.Email);
            Assert.Equal("mock-access-token", result.Token);
            Assert.Equal("mock-refresh-token", result.RefreshToken);

            var updatedUser = await context.Users.FindAsync(userId);
            Assert.NotNull(updatedUser!.LastLogin);
        }

        [Fact]
        public async Task Login_InvalidPassword_ThrowsApplicationException()
        {
            // Arrange
            using var context = GetDbContext();
            var existingUser = new User
            {
                Id = Guid.NewGuid(),
                Email = "test@example.com",
                Username = "testuser",
                PasswordHash = BCrypt.Net.BCrypt.HashPassword("CorrectPassword"),
                IsActive = true
            };
            context.Users.Add(existingUser);
            await context.SaveChangesAsync();

            var service = new AuthService(context, _mockJwtHelper.Object, _mockLogger.Object, _jwtSettings);
            var loginDto = new LoginDto
            {
                Email = "test@example.com",
                Password = "WrongPassword"
            };

            // Act & Assert
            var ex = await Assert.ThrowsAsync<ApplicationException>(() => service.Login(loginDto, "127.0.0.1"));
            Assert.Equal("Invalid email or password", ex.Message);
        }

        [Fact]
        public async Task Login_DeactivatedAccount_ThrowsApplicationException()
        {
            // Arrange
            using var context = GetDbContext();
            var existingUser = new User
            {
                Id = Guid.NewGuid(),
                Email = "inactive@example.com",
                Username = "inactiveuser",
                PasswordHash = BCrypt.Net.BCrypt.HashPassword("Password123!"),
                IsActive = false
            };
            context.Users.Add(existingUser);
            await context.SaveChangesAsync();

            var service = new AuthService(context, _mockJwtHelper.Object, _mockLogger.Object, _jwtSettings);
            var loginDto = new LoginDto
            {
                Email = "inactive@example.com",
                Password = "Password123!"
            };

            // Act & Assert
            var ex = await Assert.ThrowsAsync<ApplicationException>(() => service.Login(loginDto, "127.0.0.1"));
            Assert.Equal("Account is deactivated", ex.Message);
        }

        [Fact]
        public async Task RefreshToken_Successful_ReturnsNewTokens()
        {
            // Arrange
            using var context = GetDbContext();
            var userId = Guid.NewGuid();
            var existingUser = new User
            {
                Id = userId,
                Email = "test@example.com",
                Username = "testuser",
                PasswordHash = "hash",
                IsActive = true,
                Role = "Patient"
            };
            var oldToken = new RefreshToken
            {
                Token = "old-refresh-token",
                Expires = DateTime.UtcNow.AddDays(1),
                Created = DateTime.UtcNow,
                UserId = userId
            };
            existingUser.RefreshTokens.Add(oldToken);
            context.Users.Add(existingUser);
            await context.SaveChangesAsync();

            var principal = new ClaimsPrincipal(new ClaimsIdentity(new[]
            {
                new Claim(ClaimTypes.NameIdentifier, userId.ToString())
            }));

            _mockJwtHelper.Setup(h => h.GetPrincipalFromExpiredToken("expired-access-token")).Returns(principal);
            _mockJwtHelper.Setup(h => h.GenerateToken(It.IsAny<User>())).Returns("new-access-token");
            _mockJwtHelper.Setup(h => h.GenerateRefreshToken(It.IsAny<string>())).Returns(new RefreshToken
            {
                Token = "new-refresh-token",
                Expires = DateTime.UtcNow.AddDays(7),
                Created = DateTime.UtcNow
            });

            var service = new AuthService(context, _mockJwtHelper.Object, _mockLogger.Object, _jwtSettings);

            // Act
            var result = await service.RefreshToken("expired-access-token", "old-refresh-token", "127.0.0.1");

            // Assert
            Assert.NotNull(result);
            Assert.Equal("new-access-token", result.Token);
            Assert.Equal("new-refresh-token", result.RefreshToken);

            var dbOldToken = await context.RefreshTokens.FirstOrDefaultAsync(t => t.Token == "old-refresh-token");
            Assert.NotNull(dbOldToken!.Revoked);
            Assert.Equal("new-refresh-token", dbOldToken.ReplacedByToken);
        }

        [Fact]
        public async Task RefreshToken_InvalidToken_ThrowsApplicationException()
        {
            // Arrange
            using var context = GetDbContext();
            var userId = Guid.NewGuid();
            var existingUser = new User
            {
                Id = userId,
                Email = "test@example.com",
                Username = "testuser",
                PasswordHash = "hash",
                IsActive = true,
                Role = "Patient"
            };
            context.Users.Add(existingUser);
            await context.SaveChangesAsync();

            var principal = new ClaimsPrincipal(new ClaimsIdentity(new[]
            {
                new Claim(ClaimTypes.NameIdentifier, userId.ToString())
            }));

            _mockJwtHelper.Setup(h => h.GetPrincipalFromExpiredToken("expired-access-token")).Returns(principal);

            var service = new AuthService(context, _mockJwtHelper.Object, _mockLogger.Object, _jwtSettings);

            // Act & Assert
            var ex = await Assert.ThrowsAsync<ApplicationException>(() =>
                service.RefreshToken("expired-access-token", "non-existent-refresh-token", "127.0.0.1"));
            Assert.Equal("Refresh token is invalid or already used", ex.Message);
        }

        [Fact]
        public async Task RevokeToken_Success_ReturnsTrue()
        {
            // Arrange
            using var context = GetDbContext();
            var userId = Guid.NewGuid();
            var existingUser = new User
            {
                Id = userId,
                Email = "test@example.com",
                Username = "testuser",
                PasswordHash = "hash",
                IsActive = true,
                Role = "Patient"
            };
            var oldToken = new RefreshToken
            {
                Token = "old-refresh-token",
                Expires = DateTime.UtcNow.AddDays(1),
                Created = DateTime.UtcNow,
                UserId = userId
            };
            existingUser.RefreshTokens.Add(oldToken);
            context.Users.Add(existingUser);
            await context.SaveChangesAsync();

            var principal = new ClaimsPrincipal(new ClaimsIdentity(new[]
            {
                new Claim(ClaimTypes.NameIdentifier, userId.ToString())
            }));

            _mockJwtHelper.Setup(h => h.GetPrincipalFromExpiredToken("access-token")).Returns(principal);

            var service = new AuthService(context, _mockJwtHelper.Object, _mockLogger.Object, _jwtSettings);

            // Act
            var result = await service.RevokeToken("access-token", "127.0.0.1");

            // Assert
            Assert.True(result);
            var dbOldToken = await context.RefreshTokens.FirstOrDefaultAsync(t => t.Token == "old-refresh-token");
            Assert.NotNull(dbOldToken!.Revoked);
            Assert.Equal("Revoked without replacement", dbOldToken.ReasonRevoked);
        }

        [Fact]
        public async Task GetUserById_ReturnsUser()
        {
            // Arrange
            using var context = GetDbContext();
            var userId = Guid.NewGuid();
            var user = new User { Id = userId, Email = "test@example.com", Username = "user1" };
            context.Users.Add(user);
            await context.SaveChangesAsync();

            var service = new AuthService(context, _mockJwtHelper.Object, _mockLogger.Object, _jwtSettings);

            // Act
            var result = await service.GetUserById(userId);

            // Assert
            Assert.NotNull(result);
            Assert.Equal(userId, result.Id);
        }

        [Fact]
        public async Task GetAllUsers_FilterByRole_ReturnsFilteredUsers()
        {
            // Arrange
            using var context = GetDbContext();
            var users = new List<User>
            {
                new User { Id = Guid.NewGuid(), Email = "admin@example.com", Username = "admin", Role = "Admin" },
                new User { Id = Guid.NewGuid(), Email = "doctor@example.com", Username = "doctor", Role = "Doctor" },
                new User { Id = Guid.NewGuid(), Email = "patient@example.com", Username = "patient", Role = "Patient" }
            };
            context.Users.AddRange(users);
            await context.SaveChangesAsync();

            var service = new AuthService(context, _mockJwtHelper.Object, _mockLogger.Object, _jwtSettings);

            // Act
            var resultWithFilter = await service.GetAllUsers("Doctor");
            var resultAll = await service.GetAllUsers();

            // Assert
            Assert.Single(resultWithFilter);
            Assert.Equal("Doctor", resultWithFilter.First().Role);
            Assert.Equal(3, resultAll.Count());
        }
    }
}
