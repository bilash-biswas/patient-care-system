using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PatientManagementSystem.DTOs;
using PatientManagementSystem.Responses;
using PatientManagementSystem.Services;

namespace PatientManagementSystem.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Microsoft.AspNetCore.RateLimiting.EnableRateLimiting("auth")]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;
        private readonly ILogger<AuthController> _logger;

        public AuthController(IAuthService authService, ILogger<AuthController> logger)
        {
            _authService = authService;
            _logger = logger;
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register(RegisterDto registerDto)
        {
            try
            {
                var ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "127.0.0.1";
                var response = await _authService.Register(registerDto, ipAddress);
                return Ok(ApiResponse<AuthResponseDto>.Ok(response));
            }
            catch(ApplicationException ex)
            {
                _logger.LogWarning(ex, "Registration failed");
                return BadRequest(ApiResponse<string>.Fail(ex.Message));
            } 
            catch(Exception ex)
            {
                _logger.LogError(ex, "Error during registration");
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    ApiResponse<string>.Fail("Internal server error")
                    );
            }
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login(LoginDto loginDto)
        {
            try
            {
                var ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "127.0.0.1";
                var response = await _authService.Login(loginDto, ipAddress);
                return Ok(ApiResponse<AuthResponseDto>.Ok(response));
            }
            catch(ApplicationException ex)
            {
                _logger.LogWarning(ex, "Login failed");
                return Unauthorized(ApiResponse<string>.Fail(ex.Message));
            }
            catch(Exception ex)
            {
                _logger.LogError(ex, "Error during login");
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    ApiResponse<string>.Fail("Internal server error")
                    );
            }
        }

        [HttpPost("refresh-token")]
        public async Task<IActionResult> RefreshToken([FromBody] RefreshTokenDto refreshTokenDto)
        {
            try
            {
                var ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "127.0.0.1";

                var response = await _authService.RefreshToken(
                    refreshTokenDto.Token,
                    refreshTokenDto.RefreshToken,
                    ipAddress
                );

                return Ok(ApiResponse<AuthResponseDto>.Ok(response));
            }
            catch (ApplicationException ex)
            {
                _logger.LogWarning(ex, "Token refresh failed");
                return Unauthorized(ApiResponse<string>.Fail(ex.Message));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error during token refresh");
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    ApiResponse<string>.Fail("Internal server error")
                );
            }
        }

        [Authorize]
        [HttpPost("revoke-token")]
        public async Task<IActionResult> RevokeToken()
        {
            try
            {
                var authHeader = HttpContext.Request.Headers.Authorization.ToString();
                var token = authHeader.StartsWith("Bearer ", StringComparison.OrdinalIgnoreCase)
                    ? authHeader["Bearer ".Length..].Trim()
                    : authHeader;

                var ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "127.0.0.1";

                var result = await _authService.RevokeToken(token, ipAddress);

                if (!result)
                    return BadRequest(ApiResponse<string>.Fail("Token not found"));

                return Ok(ApiResponse<string>.Ok("Token revoked successfully"));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error during token revocation");
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    ApiResponse<string>.Fail("Internal server error")
                );
            }
        }

        [Authorize]
        [HttpGet("me")]
        public async Task<IActionResult> GetCurrentUser()
        {
            try
            {
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var userId))
                    return Unauthorized();

                var user = await _authService.GetUserById(userId);
                if (user == null)
                    return NotFound(ApiResponse<string>.Fail("User not found"));

                return Ok(ApiResponse<object>.Ok(new
                {
                    user.Id,
                    user.Email,
                    user.Username,
                    user.FirstName,
                    user.LastName,
                    user.Role,
                    user.IsActive,
                    user.CreatedAt,
                    user.UpdatedAt
                }));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting current user");
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    ApiResponse<string>.Fail("Internal server error")
                );
            }
        }

        [HttpGet("health")]
        public IActionResult Health()
        {
            return Ok(new { success = true, message = "Running" });
        }
    }
}
