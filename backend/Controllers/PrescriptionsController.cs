using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using PatientManagementSystem.Models;
using PatientManagementSystem.Responses;
using PatientManagementSystem.Services;
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
    public class PrescriptionsController : ControllerBase
    {
        private readonly IPrescriptionService _prescriptionService;
        private readonly ILogger<PrescriptionsController> _logger;

        public PrescriptionsController(IPrescriptionService prescriptionService, ILogger<PrescriptionsController> logger)
        {
            _prescriptionService = prescriptionService;
            _logger = logger;
        }

        [HttpGet]
        public async Task<IActionResult> GetPrescriptions([FromQuery] Guid? medicalRecordId, [FromQuery] Guid? patientId)
        {
            try
            {
                var userRole = User.FindFirst(ClaimTypes.Role)?.Value ?? string.Empty;
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                
                if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var userId))
                    return Unauthorized(ApiResponse<string>.Fail("User ID not found"));

                var prescriptions = await _prescriptionService.GetPrescriptionsAsync(medicalRecordId, patientId, userId, userRole);
                return Ok(ApiResponse<IEnumerable<Prescription>>.Ok(prescriptions));
            }
            catch (KeyNotFoundException ex)
            {
                _logger.LogWarning(ex, "Prescription list target not found");
                return NotFound(ApiResponse<string>.Fail(ex.Message));
            }
            catch (UnauthorizedAccessException ex)
            {
                _logger.LogWarning(ex, "Unauthorized attempt to access prescriptions");
                return Forbid();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting prescriptions");
                return StatusCode(StatusCodes.Status500InternalServerError, ApiResponse<string>.Fail("Internal server error"));
            }
        }

        [HttpPost]
        [Authorize(Roles = "Doctor")]
        public async Task<IActionResult> CreatePrescription([FromBody] Prescription prescription)
        {
            try
            {
                if (!ModelState.IsValid)
                    return BadRequest(ApiResponse<string>.Fail("Invalid model state"));

                var result = await _prescriptionService.CreatePrescriptionAsync(prescription);
                return Ok(ApiResponse<Prescription>.Ok(result));
            }
            catch (KeyNotFoundException ex)
            {
                _logger.LogWarning(ex, "Medical record not found for prescription creation");
                return NotFound(ApiResponse<string>.Fail(ex.Message));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating prescription");
                return StatusCode(StatusCodes.Status500InternalServerError, ApiResponse<string>.Fail("Internal server error"));
            }
        }

        [HttpPost("refill")]
        [Authorize(Roles = "Patient")]
        public async Task<IActionResult> RequestRefill([FromBody] Guid prescriptionId)
        {
            try
            {
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var userId))
                    return Unauthorized(ApiResponse<string>.Fail("User ID not found"));

                var refillRequest = await _prescriptionService.RequestRefillAsync(prescriptionId, userId);
                return Ok(ApiResponse<RefillRequest>.Ok(refillRequest));
            }
            catch (KeyNotFoundException ex)
            {
                _logger.LogWarning(ex, "Refill request target not found");
                return NotFound(ApiResponse<string>.Fail(ex.Message));
            }
            catch (UnauthorizedAccessException ex)
            {
                _logger.LogWarning(ex, "Unauthorized refill request attempt");
                return Forbid();
            }
            catch (ApplicationException ex)
            {
                _logger.LogWarning(ex, "Application exception during refill request");
                return BadRequest(ApiResponse<string>.Fail(ex.Message));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error requesting refill");
                return StatusCode(StatusCodes.Status500InternalServerError, ApiResponse<string>.Fail("Internal server error"));
            }
        }

        [HttpGet("refills")]
        [Authorize(Roles = "Doctor,Admin")]
        public async Task<IActionResult> GetRefillRequests()
        {
            try
            {
                var refills = await _prescriptionService.GetRefillRequestsAsync();
                return Ok(ApiResponse<IEnumerable<RefillRequest>>.Ok(refills));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting refill requests");
                return StatusCode(StatusCodes.Status500InternalServerError, ApiResponse<string>.Fail("Internal server error"));
            }
        }
    }
}
