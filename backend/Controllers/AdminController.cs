using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using PatientManagementSystem.DTOs;
using PatientManagementSystem.Responses;
using PatientManagementSystem.Services;
using System;
using System.Collections.Generic;
using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;

namespace PatientManagementSystem.Controllers
{
    [Route("api/admin")]
    [ApiController]
    [Authorize]
    [Microsoft.AspNetCore.RateLimiting.EnableRateLimiting("fixed")]
    public class AdminController : ControllerBase
    {
        private readonly IAdminService _adminService;
        private readonly ILogger<AdminController> _logger;

        public AdminController(IAdminService adminService, ILogger<AdminController> logger)
        {
            _adminService = adminService;
            _logger = logger;
        }

        [HttpGet("users")]
        [Authorize(Roles = "Admin,Doctor,Nurse,Patient")]
        public async Task<IActionResult> GetAllUsers([FromQuery] string? role = null)
        {
            try
            {
                var userRole = User.FindFirst(ClaimTypes.Role)?.Value;
                if (userRole != "Admin" && role != "Doctor" && role != "Nurse")
                {
                    return Forbid();
                }
                var users = await _adminService.GetAllUsersAsync(role);
                return Ok(ApiResponse<IEnumerable<AdminUserDto>>.Ok(users));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting all users");
                return StatusCode(StatusCodes.Status500InternalServerError, ApiResponse<string>.Fail("Internal server error"));
            }
        }

        [HttpGet("stats")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> GetDashboardStats()
        {
            try
            {
                var stats = await _adminService.GetDashboardStatsAsync();
                return Ok(ApiResponse<AdminDashboardStatsDto>.Ok(stats));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting admin dashboard statistics");
                return StatusCode(StatusCodes.Status500InternalServerError, ApiResponse<string>.Fail("Internal server error"));
            }
        }

        [HttpPost("users/{userId}/toggle")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> ToggleUserStatus(Guid userId, [FromBody] ToggleStatusDto toggleDto)
        {
            try
            {
                var result = await _adminService.ToggleUserStatusAsync(userId, toggleDto.IsActive);
                if (!result)
                {
                    return NotFound(ApiResponse<string>.Fail("User not found"));
                }
                return Ok(ApiResponse<bool>.Ok(true));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error toggling user status for user {UserId}", userId);
                return StatusCode(StatusCodes.Status500InternalServerError, ApiResponse<string>.Fail("Internal server error"));
            }
        }
    }
}
