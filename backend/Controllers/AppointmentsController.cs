using AutoMapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PatientManagementSystem.DTOs;
using PatientManagementSystem.Models;
using PatientManagementSystem.Services;
using Ical.Net;
using Ical.Net.CalendarComponents;
using Ical.Net.DataTypes;
using Ical.Net.Serialization;
using System;
using System.Collections.Generic;
using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;

namespace PatientManagementSystem.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class AppointmentsController : ControllerBase
    {
        private readonly IAppointmentService _appointmentService;
        private readonly ILogger<AppointmentsController> _logger;
        private readonly IMapper _mapper;

        public AppointmentsController(
            IAppointmentService appointmentService,
            ILogger<AppointmentsController> logger,
            IMapper mapper)
        {
            _appointmentService = appointmentService;
            _logger = logger;
            _mapper = mapper;
        }

        [HttpGet]
        public async Task<IActionResult> GetAppointments(
            [FromQuery] Guid? doctorId,
            [FromQuery] Guid? patientId,
            [FromQuery] DateTime? startDate,
            [FromQuery] DateTime? endDate,
            [FromQuery] string? status,
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 20)
        {
            try
            {
                var userRole = User.FindFirst(ClaimTypes.Role)?.Value ?? string.Empty;
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                
                if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var userId))
                    return Unauthorized(new { success = false, message = "User ID not found" });

                var (appointments, totalCount) = await _appointmentService.GetAppointmentsAsync(
                    doctorId,
                    patientId,
                    startDate,
                    endDate,
                    status,
                    userId,
                    userRole,
                    page,
                    pageSize);

                var response = _mapper.Map<List<AppointmentResponseDto>>(appointments);

                return Ok(new
                {
                    success = true,
                    data = response,
                    pagination = new
                    {
                        page,
                        pageSize,
                        totalCount,
                        totalPages = (int)Math.Ceiling(totalCount / (double)pageSize)
                    }
                });
            } 
            catch(Exception ex)
            {
                _logger.LogError(ex, "Error getting appointments");
                return StatusCode(500, new { success = false, message = "Internal server error" });
            }
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetAppointment(Guid id)
        {
            try
            {
                var userRole = User.FindFirst(ClaimTypes.Role)?.Value ?? string.Empty;
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                
                if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var userId))
                    return Unauthorized(new { success = false, message = "User ID not found" });

                var appointment = await _appointmentService.GetAppointmentByIdAsync(id, userId, userRole);

                if (appointment == null)
                    return NotFound(new { success = false, message = "Appointment not found" });

                var response = _mapper.Map<AppointmentResponseDto>(appointment);
                return Ok(new { success = true, data = response });
            }
            catch (UnauthorizedAccessException ex)
            {
                _logger.LogWarning(ex, "Unauthorized access attempt to get appointment");
                return Forbid();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting appointment");
                return StatusCode(500, new { success = false, message = "Internal server error" });
            }
        }

        [HttpPost]
        [Authorize(Roles = "Admin,Doctor,Nurse,Patient")]
        public async Task<IActionResult> CreateAppointment(CreateAppointmentDto createAppointmentDto)
        {
            try
            {
                var userRole = User.FindFirst(ClaimTypes.Role)?.Value ?? string.Empty;
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                
                if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var userId))
                    return Unauthorized(new { success = false, message = "User ID not found" });

                var appointment = await _appointmentService.CreateAppointmentAsync(createAppointmentDto, userId, userRole);
                var response = _mapper.Map<AppointmentResponseDto>(appointment);
                
                return CreatedAtAction(nameof(GetAppointment), new { id = appointment.Id },
                    new { success = true, data = response });
            }
            catch (ApplicationException ex)
            {
                _logger.LogWarning(ex, "Validation failed during appointment creation");
                return BadRequest(new { success = false, message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating appointment");
                return StatusCode(500, new { success = false, message = "Internal server error" });
            }
        }

        [HttpPut("{id}/status")]
        public async Task<IActionResult> UpdateAppointmentStatus(Guid id, [FromBody] string status)
        {
            try
            {
                var userRole = User.FindFirst(ClaimTypes.Role)?.Value ?? string.Empty;
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                
                if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var userId))
                    return Unauthorized(new { success = false, message = "User ID not found" });

                var appointment = await _appointmentService.UpdateAppointmentStatusAsync(id, status, userId, userRole);
                if (appointment == null)
                    return NotFound(new { success = false, message = "Appointment not found" });

                return Ok(new { success = true, message = $"Appointment status updated to {status}" });
            }
            catch (UnauthorizedAccessException ex)
            {
                _logger.LogWarning(ex, "Unauthorized access attempt to update appointment status");
                return Forbid();
            }
            catch (ApplicationException ex)
            {
                _logger.LogWarning(ex, "Validation failed during appointment status update");
                return BadRequest(new { success = false, message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating appointment status");
                return StatusCode(500, new { success = false, message = "Internal server error" });
            }
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = "Admin,Doctor")]
        public async Task<IActionResult> DeleteAppointment(Guid id)
        {
            try
            {
                var userRole = User.FindFirst(ClaimTypes.Role)?.Value ?? string.Empty;
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                
                if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var userId))
                    return Unauthorized(new { success = false, message = "User ID not found" });

                var result = await _appointmentService.DeleteAppointmentAsync(id, userId, userRole);
                if (!result)
                    return NotFound(new { success = false, message = "Appointment not found" });

                return Ok(new { success = true, message = "Appointment deleted successfully" });
            }
            catch (UnauthorizedAccessException ex)
            {
                _logger.LogWarning(ex, "Unauthorized access attempt to delete appointment");
                return Forbid();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deleting appointment");
                return StatusCode(500, new { success = false, message = "Internal server error" });
            }
        }

        [HttpGet("{id}/calendar")]
        [AllowAnonymous]
        public async Task<IActionResult> DownloadCalendarInvite(Guid id)
        {
            try
            {
                var appointment = await _appointmentService.GetAppointmentByIdAsync(id, Guid.Empty, "Admin");

                if (appointment == null) return NotFound();

                var e = new CalendarEvent
                {
                    Start = new CalDateTime(appointment.AppointmentDate.Add(appointment.StartTime)),
                    End = new CalDateTime(appointment.AppointmentDate.Add(appointment.EndTime)),
                    Summary = $"Appointment with Dr. {appointment.Doctor.LastName}",
                    Description = $"Reason: {appointment.Reason}\nPatient: {appointment.Patient.FirstName} {appointment.Patient.LastName}"
                };

                var calendar = new Calendar();
                calendar.Events.Add(e);

                var serializer = new CalendarSerializer();
                var serializedCalendar = serializer.SerializeToString(calendar);
                if (string.IsNullOrEmpty(serializedCalendar)) return StatusCode(500, "Error generating calendar");

                var bytes = System.Text.Encoding.UTF8.GetBytes(serializedCalendar);
                return File(bytes, "text/calendar", "appointment.ics");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error downloading calendar invite for ID {AppointmentId}", id);
                return StatusCode(500, "Error generating calendar invite");
            }
        }
    }
}
