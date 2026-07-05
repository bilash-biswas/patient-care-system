using AutoMapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PatientManagementSystem.Data;
using PatientManagementSystem.DTOs;
using PatientManagementSystem.Models;
using PatientManagementSystem.Services;
using System.Security.Claims;
using Microsoft.Extensions.Caching.Distributed;

namespace PatientManagementSystem.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    [Microsoft.AspNetCore.RateLimiting.EnableRateLimiting("fixed")]
    public class PatientsController : ControllerBase
    {
        private readonly IPatientService _patientService;
        private readonly ILogger<PatientsController> _logger;
        private readonly IMapper _mapper;
        private readonly Microsoft.Extensions.Caching.Distributed.IDistributedCache _cache;


        public PatientsController(IPatientService patientService, ILogger<PatientsController> logger, IMapper mapper, Microsoft.Extensions.Caching.Distributed.IDistributedCache cache)
        {
            _patientService = patientService;
            _logger = logger;
            _mapper = mapper;
            _cache = cache;
        }

        [HttpGet("me")]
        [Authorize(Roles = "Patient")]
        public async Task<IActionResult> GetMyProfile()
        {
            try
            {
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var userId))
                    return Unauthorized(new { success = false, message = "User ID not found" });

                var patient = await _patientService.GetPatientByUserIdAsync(userId);
                if (patient == null)
                    return NotFound(new { success = false, message = "Patient profile not found" });

                var response = _mapper.Map<PatientResponseDto>(patient);
                return Ok(new { success = true, data = response });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting my profile");
                return StatusCode(500, new { success = false, message = "Internal server error" });
            }
        }

        [HttpGet]
        [Authorize(Roles = "Admin,Doctor,Nurse")]
        public async Task<IActionResult> GetPatients([FromQuery] string? search, [FromQuery] int page = 1, [FromQuery] int pageSize = 20)
        {
            try
            {
                var cacheVersion = await _cache.GetStringAsync("patients_cache_version") ?? "1";
                string cacheKey = $"patients_list_v{cacheVersion}_{search ?? "all"}_{page}_{pageSize}";
                var cachedData = await _cache.GetStringAsync(cacheKey);

                if (!string.IsNullOrEmpty(cachedData))
                {
                    return Ok(System.Text.Json.JsonSerializer.Deserialize<object>(cachedData));
                }

                var (patients, totalCount) = await _patientService.GetPatientsAsync(search, page, pageSize);
                var response = _mapper.Map<List<PatientResponseDto>>(patients);

                var responseBody = new
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
                };

                var options = new System.Text.Json.JsonSerializerOptions { PropertyNamingPolicy = System.Text.Json.JsonNamingPolicy.CamelCase };
                var serializedResponse = System.Text.Json.JsonSerializer.Serialize(responseBody, options);
                await _cache.SetStringAsync(cacheKey, serializedResponse, new Microsoft.Extensions.Caching.Distributed.DistributedCacheEntryOptions
                {
                    AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(5)
                });

                return Ok(responseBody);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting patients");
                return StatusCode(500, new { success = false, message = "Internal server error" });
            }
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetPatient(Guid id)
        {
            try
            {
                var patient = await _patientService.GetPatientByIdAsync(id);
                if (patient == null)
                    return NotFound(new { success = false, message = "Patient not found" });

                if (!await CanAccessPatient(id))
                    return Forbid();

                var response = _mapper.Map<PatientResponseDto>(patient);
                return Ok(new { success = true, data = response });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting patient");
                return StatusCode(500, new { success = false, message = "Internal server error" });
            }
        }

        [HttpPost]
        [Authorize(Roles = "Admin,Doctor,Nurse")]
        public async Task<IActionResult> CreatePatient(CreatePatientDto createPatientDto)
        {
            try
            {
                var userIdClaim = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
                if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var userId))
                    return Unauthorized(new { success = false, message = "User ID not found" });

                var patient = await _patientService.CreatePatientAsync(createPatientDto, userId);
                var response = _mapper.Map<PatientResponseDto>(patient);
                
                await InvalidatePatientsCache();

                return CreatedAtAction(nameof(GetPatient), new { id = patient.Id }, new { success = true, data = response });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating patient");
                return StatusCode(500, new { success = false, message = "Internal Server Error" });
            }
        }

        [HttpPut("{id}")]
        [Authorize(Roles = "Admin,Doctor,Nurse")]
        public async Task<IActionResult> UpdatePatient(Guid id, UpdatePatientDto updatePatientDto)
        {
            try
            {
                var patient = await _patientService.UpdatePatientAsync(id, updatePatientDto);
                if (patient == null)
                    return NotFound(new { success = false, message = "Patient not found" });

                var response = _mapper.Map<PatientResponseDto>(patient);
                
                await InvalidatePatientsCache();

                return Ok(new { success = true, data = response });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating patient");
                return StatusCode(500, new { success = false, message = "Internal server error" });
            }
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> DeletePatient(Guid id)
        {
            try
            {
                var result = await _patientService.DeletePatientAsync(id);
                if (!result)
                    return NotFound(new { success = false, message = "Patient not found" });

                await InvalidatePatientsCache();

                return Ok(new { success = true, message = "Patient deleted successfully" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deleting patient");
                return StatusCode(500, new { success = false, message = "Internal server error" });
            }
        }

        [HttpGet("{id}/appointments")]
        public async Task<IActionResult> GetPatientAppointments(Guid id)
        {
            try
            {
                if (!await CanAccessPatient(id))
                    return Forbid();

                var appointments = await _patientService.GetPatientAppointmentsAsync(id);
                var response = _mapper.Map<List<AppointmentResponseDto>>(appointments);
                
                return Ok(new { success = true, data = response });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting patient appointments");
                return StatusCode(500, new { success = false, message = "Internal server error" });
            }
        }

        [HttpGet("{id}/medical-records")]
        public async Task<IActionResult> GetPatientMedicalRecords(Guid id)
        {
            try
            {
                if (!await CanAccessPatient(id))
                    return Forbid();

                var medicalRecords = await _patientService.GetPatientMedicalRecordsAsync(id);
                var response = _mapper.Map<List<MedicalRecordResponseDto>>(medicalRecords);
                
                return Ok(new { success = true, data = response });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting patient medical records");
                return StatusCode(500, new { success = false, message = "Internal server error" });
            }
        }

        private async Task InvalidatePatientsCache()
        {
            try
            {
                await _cache.RemoveAsync("patients_cache_version");
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Failed to invalidate patients cache version key.");
            }
        }

        private async Task<bool> CanAccessPatient(Guid patientId)
        {
            var userRole = User.FindFirst(System.Security.Claims.ClaimTypes.Role)?.Value;
            if (userRole == "Admin" || userRole == "Doctor" || userRole == "Nurse")
                return true;

            var userId = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(userId) || !Guid.TryParse(userId, out var userGuid)) return false;

            var userPatient = await _patientService.GetPatientByUserIdAsync(userGuid);
            return userPatient != null && userPatient.Id == patientId;
        }
    }
}
