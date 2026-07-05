using System.Security.Claims;
using Microsoft.EntityFrameworkCore;
using PatientManagementSystem.Data;
using PatientManagementSystem.DTOs;
using PatientManagementSystem.Helpers;
using PatientManagementSystem.Models;

namespace PatientManagementSystem.Services
{
    public interface IAuthService
    {
        Task<AuthResponseDto> Register(RegisterDto registerDto, string ipAddress);
        Task<AuthResponseDto> Login(LoginDto loginDto, string ipAddress);
        Task<AuthResponseDto> RefreshToken(string token, string refreshToken, string ipAddress);
        Task<bool> RevokeToken(string token, string ipAddress);
        Task<User?> GetUserById(Guid userId);
        Task<IEnumerable<User>> GetAllUsers(string? role = null);
    }

    public class AuthService : IAuthService
    {
        private readonly ApplicationDbContext _context;
        private readonly IJwtHelper _jwtHelper;
        private readonly ILogger<AuthService> _logger;
        private readonly JwtSettings _jwtSettings;

        public AuthService(ApplicationDbContext context, IJwtHelper jwtHelper, ILogger<AuthService> logger, JwtSettings jwtSettings)
        {
            _context = context;
            _jwtHelper = jwtHelper;
            _logger = logger;
            _jwtSettings = jwtSettings;
        }

        public async Task<AuthResponseDto> Register(RegisterDto registerDto, string ipAddress)
        {
            if (await _context.Users.AnyAsync(u => u.Email == registerDto.Email))
                throw new ApplicationException("Email is already registered");

            if (await _context.Users.AnyAsync(u => u.Username == registerDto.Username))
                throw new ApplicationException("Username is already taken");

            var validRoles = new[] { "Admin", "Doctor", "Nurse", "Patient" };

            if (!validRoles.Contains(registerDto.Role))
                throw new ApplicationException("Invalid Role");

            var user = new User
            {
                Email = registerDto.Email,
                Username = registerDto.Username,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(registerDto.Password),
                FirstName = registerDto.FirstName,
                LastName = registerDto.LastName,
                PhoneNumber = registerDto.PhoneNumber,
                Role = registerDto.Role,
                IsActive = true
            };

            _context.Users.Add(user);

            if (user.Role == "Patient")
            {
                var patient = new Patient
                {
                    User = user,
                    FirstName = user.FirstName,
                    LastName = user.LastName,
                    Gender = "Not Specified",
                    DateOfBirth = new DateTime(2000, 1, 1, 0, 0, 0, DateTimeKind.Utc),
                    Phone = user.PhoneNumber,
                    CreatedAt = DateTime.UtcNow
                };
                _context.Patients.Add(patient);
            }

            var token = _jwtHelper.GenerateToken(user);
            var refreshToken = _jwtHelper.GenerateRefreshToken(ipAddress);
            refreshToken.UserId = user.Id;

            user.RefreshTokens.Add(refreshToken);
            user.LastLogin = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            return new AuthResponseDto
            {
                Id = user.Id,
                Email = user.Email,
                Username = user.Username,
                FirstName = user.FirstName,
                LastName = user.LastName,
                Role = user.Role,
                Token = token,
                TokenExpires = DateTime.UtcNow.AddMinutes(_jwtSettings.TokenExpirationInMinutes),
                RefreshToken = refreshToken.Token,
                RefreshTokenExpires = refreshToken.Expires,
                IsActive = user.IsActive,
                CreatedAt = user.CreatedAt,
                UpdatedAt = user.UpdatedAt
            };
        }

        public async Task<AuthResponseDto> Login(LoginDto loginDto, string ipAddress)
        {
            var user = await _context.Users
                .Include(u => u.RefreshTokens)
                .FirstOrDefaultAsync(u => u.Email.ToLower() == loginDto.Email.ToLower());

            if (user == null || !BCrypt.Net.BCrypt.Verify(loginDto.Password, user.PasswordHash))
                throw new ApplicationException("Invalid email or password");

            if (!user.IsActive)
                throw new ApplicationException("Account is deactivated");

            var token = _jwtHelper.GenerateToken(user);
            var refreshToken = _jwtHelper.GenerateRefreshToken(ipAddress);

            refreshToken.UserId = user.Id;
            _context.RefreshTokens.Add(refreshToken);
            
            user.LastLogin = DateTime.UtcNow;
            _context.Entry(user).Property(u => u.LastLogin).IsModified = true;

            await _context.SaveChangesAsync();

            return new AuthResponseDto
            {
                Id = user.Id,
                Email = user.Email,
                Username = user.Username,
                FirstName = user.FirstName,
                LastName = user.LastName,
                Role = user.Role,
                Token = token,
                TokenExpires = DateTime.UtcNow.AddMinutes(_jwtSettings.TokenExpirationInMinutes),
                RefreshToken = refreshToken.Token,
                RefreshTokenExpires = refreshToken.Expires,
                IsActive = user.IsActive,
                CreatedAt = user.CreatedAt,
                UpdatedAt = user.UpdatedAt
            };
        }

        public async Task<AuthResponseDto> RefreshToken(string token, string refreshToken, string ipAddress)
        {
            var principal = _jwtHelper.GetPrincipalFromExpiredToken(token);
            if (principal == null)
                throw new ApplicationException("Invalid token");

            var nameIdentifierClaim = principal.FindFirst(ClaimTypes.NameIdentifier);
            if (nameIdentifierClaim == null || !Guid.TryParse(nameIdentifierClaim.Value, out var userId))
                throw new ApplicationException("Invalid token");

            var user = await _context.Users
                .Include(u => u.RefreshTokens)
                .FirstOrDefaultAsync(u => u.Id == userId);

            if (user == null || !user.IsActive)
                throw new ApplicationException("Invalid token");

            var oldRefreshToken = user.RefreshTokens.FirstOrDefault(rt => rt.Token == refreshToken);


            if (oldRefreshToken == null || !oldRefreshToken.IsActive)
                throw new ApplicationException("Refresh token is invalid or already used");

            oldRefreshToken.Revoked = DateTime.UtcNow;
            oldRefreshToken.RevokedByIp = ipAddress;

            var newRefreshToken = _jwtHelper.GenerateRefreshToken(ipAddress);
            newRefreshToken.UserId = user.Id;

            oldRefreshToken.ReplacedByToken = newRefreshToken.Token;

            _context.Entry(oldRefreshToken).State = EntityState.Modified;
            _context.RefreshTokens.Add(newRefreshToken);

            await _context.SaveChangesAsync();

            var newToken = _jwtHelper.GenerateToken(user);

            return new AuthResponseDto
            {
                Id = user.Id,
                Email = user.Email,
                Username = user.Username,
                FirstName = user.FirstName,
                LastName = user.LastName,
                Role = user.Role,
                Token = newToken,
                TokenExpires = DateTime.UtcNow.AddMinutes(_jwtSettings.TokenExpirationInMinutes),
                RefreshToken = newRefreshToken.Token,
                RefreshTokenExpires = newRefreshToken.Expires,
                IsActive = user.IsActive,
                CreatedAt = user.CreatedAt,
                UpdatedAt = user.UpdatedAt
            };
        }

        public async Task<bool> RevokeToken(string token, string ipAddress)
        {
            var principal = _jwtHelper.GetPrincipalFromExpiredToken(token);
            if (principal == null) return false;

            var nameIdentifierClaim = principal.FindFirst(ClaimTypes.NameIdentifier);
            if (nameIdentifierClaim == null || !Guid.TryParse(nameIdentifierClaim.Value, out var userId))
                return false;

            var user = await _context.Users
                .Include(u => u.RefreshTokens)
                .FirstOrDefaultAsync(u => u.Id == userId);

            if (user == null) return false;

            var refreshToken = user.RefreshTokens.FirstOrDefault(rt => rt.IsActive);
            if (refreshToken == null) return false;

            refreshToken.Revoked = DateTime.UtcNow;
            refreshToken.RevokedByIp = ipAddress;
            refreshToken.ReasonRevoked = "Revoked without replacement";

            await _context.SaveChangesAsync();

            return true;
        }

        public async Task<User?> GetUserById(Guid userId)
        {
            return await _context.Users.FindAsync(userId);
        }

        public async Task<IEnumerable<User>> GetAllUsers(string? role = null)
        {
            var usersQuery = _context.Users.AsQueryable();
            
            if (!string.IsNullOrEmpty(role))
            {
                usersQuery = usersQuery.Where(u => u.Role == role);
            }

            return await usersQuery.ToListAsync();
        }
    }
}
