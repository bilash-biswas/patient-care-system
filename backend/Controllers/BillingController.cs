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
    [Route("api/billing")]
    [ApiController]
    [Authorize]
    public class BillingController : ControllerBase
    {
        private readonly IBillingService _billingService;
        private readonly ILogger<BillingController> _logger;

        public BillingController(IBillingService billingService, ILogger<BillingController> logger)
        {
            _billingService = billingService;
            _logger = logger;
        }

        [HttpGet("invoices")]
        public async Task<IActionResult> GetInvoices([FromQuery] string? patientId = null)
        {
            try
            {
                var userRole = User.FindFirst(ClaimTypes.Role)?.Value ?? string.Empty;
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

                if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var userId))
                    return Unauthorized(ApiResponse<string>.Fail("User ID not found"));

                Guid? parsedPatientId = null;
                if (!string.IsNullOrEmpty(patientId) && Guid.TryParse(patientId, out var id))
                {
                    parsedPatientId = id;
                }

                var invoices = await _billingService.GetInvoicesAsync(parsedPatientId, userId, userRole);
                return Ok(ApiResponse<IEnumerable<InvoiceResponseDto>>.Ok(invoices));
            }
            catch (KeyNotFoundException ex)
            {
                _logger.LogWarning(ex, "Billing list target not found");
                return NotFound(ApiResponse<string>.Fail(ex.Message));
            }
            catch (UnauthorizedAccessException ex)
            {
                _logger.LogWarning(ex, "Unauthorized attempt to view invoices");
                return Forbid();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting invoices");
                return StatusCode(StatusCodes.Status500InternalServerError, ApiResponse<string>.Fail("Internal server error"));
            }
        }

        [HttpGet("invoices/{id}")]
        public async Task<IActionResult> GetInvoiceById(Guid id)
        {
            try
            {
                var userRole = User.FindFirst(ClaimTypes.Role)?.Value ?? string.Empty;
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

                if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var userId))
                    return Unauthorized(ApiResponse<string>.Fail("User ID not found"));

                var invoice = await _billingService.GetInvoiceByIdAsync(id, userId, userRole);
                if (invoice == null)
                {
                    return NotFound(ApiResponse<string>.Fail("Invoice not found"));
                }

                return Ok(ApiResponse<InvoiceResponseDto>.Ok(invoice));
            }
            catch (UnauthorizedAccessException ex)
            {
                _logger.LogWarning(ex, "Unauthorized attempt to view invoice details");
                return Forbid();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting invoice by ID");
                return StatusCode(StatusCodes.Status500InternalServerError, ApiResponse<string>.Fail("Internal server error"));
            }
        }

        [HttpPost("invoices/{id}/pay")]
        public async Task<IActionResult> PayInvoice(Guid id)
        {
            try
            {
                var userRole = User.FindFirst(ClaimTypes.Role)?.Value ?? string.Empty;
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

                if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var userId))
                    return Unauthorized(ApiResponse<string>.Fail("User ID not found"));

                var clientSecret = await _billingService.PayInvoiceAsync(id, userId, userRole);
                return Ok(ApiResponse<object>.Ok(new { clientSecret }));
            }
            catch (KeyNotFoundException ex)
            {
                _logger.LogWarning(ex, "Pay invoice target not found");
                return NotFound(ApiResponse<string>.Fail(ex.Message));
            }
            catch (UnauthorizedAccessException ex)
            {
                _logger.LogWarning(ex, "Unauthorized attempt to pay invoice");
                return Forbid();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error paying invoice");
                return StatusCode(StatusCodes.Status500InternalServerError, ApiResponse<string>.Fail("Internal server error"));
            }
        }
    }
}
