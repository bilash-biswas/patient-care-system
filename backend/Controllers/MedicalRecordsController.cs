using AutoMapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PatientManagementSystem.DTOs;
using PatientManagementSystem.Models;
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
    [Authorize(Roles = "Admin,Doctor,Nurse,Patient")]
    public class MedicalRecordsController : ControllerBase
    {
        private readonly IMedicalRecordService _medicalRecordService;
        private readonly ILogger<MedicalRecordsController> _logger;
        private readonly IMapper _mapper;

        public MedicalRecordsController(
            IMedicalRecordService medicalRecordService,
            ILogger<MedicalRecordsController> logger,
            IMapper mapper)
        {
            _medicalRecordService = medicalRecordService;
            _logger = logger;
            _mapper = mapper;
        }

        // GET: api/medical-records
        [HttpGet]
        public async Task<IActionResult> GetMedicalRecords(
            [FromQuery] Guid? patientId,
            [FromQuery] Guid? doctorId,
            [FromQuery] DateTime? startDate,
            [FromQuery] DateTime? endDate,
            [FromQuery] string? recordType,
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 20)
        {
            try
            {
                var userRole = User.FindFirst(ClaimTypes.Role)?.Value ?? string.Empty;
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                
                if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var userId))
                    return Unauthorized(new { success = false, message = "User ID not found" });

                var (medicalRecords, totalCount) = await _medicalRecordService.GetMedicalRecordsAsync(
                    patientId,
                    doctorId,
                    startDate,
                    endDate,
                    recordType,
                    userId,
                    userRole,
                    page,
                    pageSize);

                var response = _mapper.Map<List<MedicalRecordResponseDto>>(medicalRecords);

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
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting medical records");
                return StatusCode(500, new { success = false, message = "Internal server error" });
            }
        }

        // GET: api/medical-records/5
        [HttpGet("{id}")]
        public async Task<IActionResult> GetMedicalRecord(Guid id)
        {
            try
            {
                var userRole = User.FindFirst(ClaimTypes.Role)?.Value ?? string.Empty;
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                
                if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var userId))
                    return Unauthorized(new { success = false, message = "User ID not found" });

                var medicalRecord = await _medicalRecordService.GetMedicalRecordByIdAsync(id, userId, userRole);

                if (medicalRecord == null)
                    return NotFound(new { success = false, message = "Medical record not found" });

                var response = _mapper.Map<MedicalRecordResponseDto>(medicalRecord);
                return Ok(new { success = true, data = response });
            }
            catch (UnauthorizedAccessException ex)
            {
                _logger.LogWarning(ex, "Unauthorized access attempt to get medical record");
                return Forbid();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting medical record");
                return StatusCode(500, new { success = false, message = "Internal server error" });
            }
        }

        // POST: api/medical-records
        [HttpPost]
        [Authorize(Roles = "Admin,Doctor")]
        public async Task<IActionResult> CreateMedicalRecord(CreateMedicalRecordDto createMedicalRecordDto)
        {
            try
            {
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var userId))
                    return Unauthorized(new { success = false, message = "User ID not found" });

                var medicalRecord = await _medicalRecordService.CreateMedicalRecordAsync(createMedicalRecordDto, userId);
                var response = _mapper.Map<MedicalRecordResponseDto>(medicalRecord);
                return CreatedAtAction(nameof(GetMedicalRecord), new { id = medicalRecord.Id },
                    new { success = true, data = response });
            }
            catch (ApplicationException ex)
            {
                _logger.LogWarning(ex, "Validation failed during medical record creation");
                return BadRequest(new { success = false, message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating medical record");
                return StatusCode(500, new { success = false, message = "Internal server error" });
            }
        }

        // PUT: api/medical-records/5
        [HttpPut("{id}")]
        [Authorize(Roles = "Admin,Doctor")]
        public async Task<IActionResult> UpdateMedicalRecord(Guid id, CreateMedicalRecordDto updateMedicalRecordDto)
        {
            try
            {
                var userRole = User.FindFirst(ClaimTypes.Role)?.Value ?? string.Empty;
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                
                if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var userId))
                    return Unauthorized(new { success = false, message = "User ID not found" });

                var medicalRecord = await _medicalRecordService.UpdateMedicalRecordAsync(id, updateMedicalRecordDto, userId, userRole);
                if (medicalRecord == null)
                    return NotFound(new { success = false, message = "Medical record not found" });

                var response = _mapper.Map<MedicalRecordResponseDto>(medicalRecord);
                return Ok(new { success = true, data = response });
            }
            catch (UnauthorizedAccessException ex)
            {
                _logger.LogWarning(ex, "Unauthorized access attempt to update medical record");
                return Forbid();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating medical record");
                return StatusCode(500, new { success = false, message = "Internal server error" });
            }
        }

        // DELETE: api/medical-records/5
        [HttpDelete("{id}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> DeleteMedicalRecord(Guid id)
        {
            try
            {
                var result = await _medicalRecordService.DeleteMedicalRecordAsync(id);
                if (!result)
                    return NotFound(new { success = false, message = "Medical record not found" });

                return Ok(new { success = true, message = "Medical record deleted successfully" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deleting medical record");
                return StatusCode(500, new { success = false, message = "Internal server error" });
            }
        }
    }
}