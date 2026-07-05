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
    [Route("api/chat")]
    [ApiController]
    [Authorize]
    public class ChatController : ControllerBase
    {
        private readonly IChatService _chatService;
        private readonly ILogger<ChatController> _logger;

        public ChatController(IChatService chatService, ILogger<ChatController> logger)
        {
            _chatService = chatService;
            _logger = logger;
        }

        [HttpGet("directory")]
        public async Task<IActionResult> GetDirectory(
            [FromQuery] string? role = null,
            [FromQuery] string? search = null,
            [FromQuery] bool? isActive = null,
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 6)
        {
            try
            {
                var userRole = User.FindFirst(ClaimTypes.Role)?.Value ?? string.Empty;
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                
                if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var userId))
                    return Unauthorized(ApiResponse<string>.Fail("User ID not found"));

                var (directory, totalCount) = await _chatService.GetDirectoryAsync(role, search, isActive, page, pageSize, userId, userRole);

                return Ok(new
                {
                    success = true,
                    data = directory,
                    pagination = new
                    {
                        page,
                        pageSize,
                        totalCount,
                        totalPages = (int)Math.Ceiling(totalCount / (double)pageSize)
                    }
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting directory");
                return StatusCode(StatusCodes.Status500InternalServerError, ApiResponse<string>.Fail("Internal server error"));
            }
        }

        [HttpGet("messages/{otherUserId}")]
        public async Task<IActionResult> GetMessages(
            Guid otherUserId,
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 50)
        {
            try
            {
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var userId))
                    return Unauthorized(ApiResponse<string>.Fail("User ID not found"));

                var (messages, totalCount) = await _chatService.GetMessagesAsync(userId, otherUserId, page, pageSize);

                return Ok(new
                {
                    success = true,
                    data = messages,
                    pagination = new
                    {
                        page,
                        pageSize,
                        totalCount,
                        totalPages = (int)Math.Ceiling(totalCount / (double)pageSize)
                    }
                });
            }
            catch (UnauthorizedAccessException ex)
            {
                _logger.LogWarning(ex, "Unauthorized attempt to access messages");
                return Forbid();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting messages");
                return StatusCode(StatusCodes.Status500InternalServerError, ApiResponse<string>.Fail("Internal server error"));
            }
        }

        [HttpGet("conversations")]
        public async Task<IActionResult> GetConversations()
        {
            try
            {
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var userId))
                    return Unauthorized(ApiResponse<string>.Fail("User ID not found"));

                var contacts = await _chatService.GetConversationsAsync(userId);
                return Ok(ApiResponse<IEnumerable<ChatUserDto>>.Ok(contacts));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting conversations");
                return StatusCode(StatusCodes.Status500InternalServerError, ApiResponse<string>.Fail("Internal server error"));
            }
        }
    }
}
