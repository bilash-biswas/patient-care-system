using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Distributed;
using Microsoft.Extensions.Logging;
using PatientManagementSystem.Data;
using PatientManagementSystem.DTOs;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;

namespace PatientManagementSystem.Services
{
    public class AdminService : IAdminService
    {
        private readonly ApplicationDbContext _context;
        private readonly IAuthService _authService;
        private readonly IDistributedCache _cache;
        private readonly ILogger<AdminService> _logger;

        private static readonly JsonSerializerOptions _jsonOptions = new JsonSerializerOptions
        {
            PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
            PropertyNameCaseInsensitive = true
        };

        public AdminService(ApplicationDbContext context, IAuthService authService, IDistributedCache cache, ILogger<AdminService> logger)
        {
            _context = context;
            _authService = authService;
            _cache = cache;
            _logger = logger;
        }

        public async Task<IEnumerable<AdminUserDto>> GetAllUsersAsync(string? role)
        {
            string cacheKey = $"admin_users_{role ?? "all"}";
            string? cachedData = null;

            try
            {
                cachedData = await _cache.GetStringAsync(cacheKey);
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Distributed cache read failed. Falling back to database.");
            }

            if (!string.IsNullOrEmpty(cachedData))
            {
                try
                {
                    var deserialized = JsonSerializer.Deserialize<IEnumerable<AdminUserDto>>(cachedData, _jsonOptions);
                    if (deserialized != null)
                    {
                        return deserialized;
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogWarning(ex, "Failed to deserialize cached users.");
                }
            }

            var users = await _authService.GetAllUsers(role);
            var userData = users.Select(u => new AdminUserDto
            {
                Id = u.Id,
                Email = u.Email,
                Username = u.Username,
                FirstName = u.FirstName,
                LastName = u.LastName,
                Role = u.Role,
                IsActive = u.IsActive,
                CreatedAt = u.CreatedAt
            }).ToList();

            try
            {
                var serializedResponse = JsonSerializer.Serialize(userData, _jsonOptions);

                await _cache.SetStringAsync(cacheKey, serializedResponse, new DistributedCacheEntryOptions
                {
                    AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(5)
                });
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Distributed cache write failed.");
            }

            return userData;
        }

        public async Task<AdminDashboardStatsDto> GetDashboardStatsAsync()
        {
            string cacheKey = "admin_dashboard_stats";
            string? cachedData = null;

            try
            {
                cachedData = await _cache.GetStringAsync(cacheKey);
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Distributed cache read failed for dashboard stats. Falling back to database.");
            }

            if (!string.IsNullOrEmpty(cachedData))
            {
                try
                {
                    var deserialized = JsonSerializer.Deserialize<AdminDashboardStatsDto>(cachedData, _jsonOptions);
                    if (deserialized != null)
                    {
                        return deserialized;
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogWarning(ex, "Failed to deserialize cached dashboard stats.");
                }
            }

            var stats = new AdminDashboardStatsDto
            {
                TotalUsers = await _context.Users.CountAsync(),
                ActiveUsers = await _context.Users.CountAsync(u => u.IsActive),
                TotalPatients = await _context.Patients.CountAsync(),
                TotalDoctors = await _context.Users.CountAsync(u => u.Role == "Doctor"),
                TotalNurses = await _context.Users.CountAsync(u => u.Role == "Nurse"),
                TotalAppointments = await _context.Appointments.CountAsync(),
                UpcomingAppointments = await _context.Appointments
                    .CountAsync(a => a.Status == "Scheduled" && a.AppointmentDate >= DateTime.UtcNow.Date),
                TotalRevenue = await _context.Invoices.Where(i => i.Status == "Paid").SumAsync(i => i.Amount),
                PaidInvoicesCount = await _context.Invoices.CountAsync(i => i.Status == "Paid"),
                UnpaidInvoicesCount = await _context.Invoices.CountAsync(i => i.Status == "Unpaid")
            };

            try
            {
                var serializedResponse = JsonSerializer.Serialize(stats, _jsonOptions);

                await _cache.SetStringAsync(cacheKey, serializedResponse, new DistributedCacheEntryOptions
                {
                    AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(1) // Cache for 1 minute
                });
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Distributed cache write failed for dashboard stats.");
            }

            return stats;
        }

        public async Task<bool> ToggleUserStatusAsync(Guid userId, bool isActive)
        {
            var user = await _context.Users.FindAsync(userId);
            if (user == null)
            {
                return false;
            }

            user.IsActive = isActive;
            user.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            // Evict caches
            try
            {
                await _cache.RemoveAsync("admin_users_all");
                await _cache.RemoveAsync("admin_users_Admin");
                await _cache.RemoveAsync("admin_users_Doctor");
                await _cache.RemoveAsync("admin_users_Nurse");
                await _cache.RemoveAsync("admin_users_Patient");
                await _cache.RemoveAsync("admin_dashboard_stats");
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Failed to invalidate admin cache after user status change");
            }

            return true;
        }
    }
}
