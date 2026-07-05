using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PatientManagementSystem.Models;
using PatientManagementSystem.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;

namespace PatientManagementSystem.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize(Roles = "Admin,Doctor")]
    public class NursesController : ControllerBase
    {
        private readonly INurseService _nurseService;
        private readonly ILogger<NursesController> _logger;

        public NursesController(INurseService nurseService, ILogger<NursesController> logger)
        {
            _nurseService = nurseService;
            _logger = logger;
        }

        [HttpGet]
        public async Task<IActionResult> GetNurses(
            [FromQuery] string? search,
            [FromQuery] bool? isActive,
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 8)
        {
            try
            {
                var (nurses, totalCount) = await _nurseService.GetNursesAsync(search, isActive, page, pageSize);

                var nurseListDto = nurses.Select(u => new {
                    u.Id,
                    u.FirstName,
                    u.LastName,
                    u.Email,
                    u.PhoneNumber,
                    u.Role,
                    u.IsActive,
                    u.CreatedAt,
                    u.LastLogin
                });

                return Ok(new
                {
                    success = true,
                    data = nurseListDto,
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
                _logger.LogError(ex, "Error getting nurses list");
                return StatusCode(500, new { success = false, message = "Internal server error" });
            }
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetNurse(Guid id)
        {
            try
            {
                var nurse = await _nurseService.GetNurseByIdAsync(id);

                if (nurse == null)
                {
                    return NotFound(new { success = false, message = "Nurse not found" });
                }

                var nurseDto = new {
                    nurse.Id,
                    nurse.FirstName,
                    nurse.LastName,
                    nurse.Email,
                    nurse.PhoneNumber,
                    nurse.Role,
                    nurse.IsActive,
                    nurse.CreatedAt,
                    nurse.LastLogin
                };

                return Ok(new { success = true, data = nurseDto });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting nurse details for ID {NurseId}", id);
                return StatusCode(500, new { success = false, message = "Internal server error" });
            }
        }
    }
}
