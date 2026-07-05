using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PatientManagementSystem.Data;
using PatientManagementSystem.DTOs;
using PatientManagementSystem.Models;
using PatientManagementSystem.Responses;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;

namespace PatientManagementSystem.Controllers
{
    [Route("api/doctors")]
    [ApiController]
    [Authorize]
    public class DoctorsController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public DoctorsController(ApplicationDbContext context)
        {
            _context = context;
        }

        [HttpGet("{doctorId}/availability")]
        public async Task<IActionResult> GetAvailability(Guid doctorId)
        {
            var doctor = await _context.Users.FirstOrDefaultAsync(u => u.Id == doctorId && u.Role == "Doctor");
            if (doctor == null)
            {
                return NotFound(ApiResponse<string>.Fail("Doctor not found"));
            }

            var availabilities = await _context.DoctorAvailabilities
                .Where(da => da.DoctorId == doctorId)
                .ToListAsync();

            var result = new List<DoctorAvailabilityDto>();
            for (int i = 0; i < 7; i++)
            {
                var day = (DayOfWeek)i;
                var record = availabilities.FirstOrDefault(da => da.DayOfWeek == day);
                
                if (record != null)
                {
                    result.Add(new DoctorAvailabilityDto
                    {
                        DayOfWeek = day,
                        StartTime = record.StartTime.ToString(@"hh\:mm"),
                        EndTime = record.EndTime.ToString(@"hh\:mm"),
                        IsAvailable = record.IsAvailable
                    });
                }
                else
                {
                    bool isDefaultAvailable = day != DayOfWeek.Saturday && day != DayOfWeek.Sunday;
                    result.Add(new DoctorAvailabilityDto
                    {
                        DayOfWeek = day,
                        StartTime = "08:00",
                        EndTime = "17:00",
                        IsAvailable = isDefaultAvailable
                    });
                }
            }

            return Ok(ApiResponse<IEnumerable<DoctorAvailabilityDto>>.Ok(result));
        }

        [HttpPut("{doctorId}/availability")]
        [Authorize(Roles = "Admin,Doctor")]
        public async Task<IActionResult> UpdateAvailability(Guid doctorId, [FromBody] List<DoctorAvailabilityDto> dtoList)
        {
            var doctor = await _context.Users.FirstOrDefaultAsync(u => u.Id == doctorId && u.Role == "Doctor");
            if (doctor == null)
            {
                return NotFound(ApiResponse<string>.Fail("Doctor not found"));
            }

            var currentUserId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            var userRole = User.FindFirst(ClaimTypes.Role)?.Value;

            if (userRole != "Admin" && currentUserId != doctorId.ToString())
            {
                return Forbid();
            }

            var existingRecords = await _context.DoctorAvailabilities
                .Where(da => da.DoctorId == doctorId)
                .ToListAsync();

            foreach (var dto in dtoList)
            {
                var existing = existingRecords.FirstOrDefault(da => da.DayOfWeek == dto.DayOfWeek);

                if (!TimeSpan.TryParse(dto.StartTime, out var startTime))
                {
                    startTime = new TimeSpan(8, 0, 0);
                }
                if (!TimeSpan.TryParse(dto.EndTime, out var endTime))
                {
                    endTime = new TimeSpan(17, 0, 0);
                }

                if (existing != null)
                {
                    existing.StartTime = startTime;
                    existing.EndTime = endTime;
                    existing.IsAvailable = dto.IsAvailable;
                }
                else
                {
                    var newRecord = new DoctorAvailability
                    {
                        DoctorId = doctorId,
                        DayOfWeek = dto.DayOfWeek,
                        StartTime = startTime,
                        EndTime = endTime,
                        IsAvailable = dto.IsAvailable
                    };
                    await _context.DoctorAvailabilities.AddAsync(newRecord);
                }
            }

            await _context.SaveChangesAsync();
            return Ok(ApiResponse<bool>.Ok(true));
        }

        [HttpGet("{doctorId}/slots")]
        public async Task<IActionResult> GetSlots(Guid doctorId, [FromQuery] string date)
        {
            if (!DateTime.TryParse(date, out var parsedDate))
            {
                return BadRequest(ApiResponse<string>.Fail("Invalid date format. Use YYYY-MM-DD."));
            }

            var doctor = await _context.Users.FirstOrDefaultAsync(u => u.Id == doctorId && u.Role == "Doctor");
            if (doctor == null)
            {
                return NotFound(ApiResponse<string>.Fail("Doctor not found"));
            }

            var dayOfWeek = parsedDate.DayOfWeek;
            var availability = await _context.DoctorAvailabilities
                .FirstOrDefaultAsync(da => da.DoctorId == doctorId && da.DayOfWeek == dayOfWeek);

            TimeSpan startTime = new TimeSpan(8, 0, 0);
            TimeSpan endTime = new TimeSpan(17, 0, 0);
            bool isAvailableDay = dayOfWeek != DayOfWeek.Saturday && dayOfWeek != DayOfWeek.Sunday;

            if (availability != null)
            {
                startTime = availability.StartTime;
                endTime = availability.EndTime;
                isAvailableDay = availability.IsAvailable;
            }

            var slots = new List<object>();

            if (isAvailableDay)
            {
                var appointments = await _context.Appointments
                    .Where(a => a.DoctorId == doctorId && a.AppointmentDate.Date == parsedDate.Date && a.Status != "Cancelled")
                    .ToListAsync();

                for (var start = startTime; start + TimeSpan.FromMinutes(30) <= endTime; start = start.Add(TimeSpan.FromMinutes(30)))
                {
                    var slotEnd = start.Add(TimeSpan.FromMinutes(30));
                    var isBooked = appointments.Any(a => 
                        (start >= a.StartTime && start < a.EndTime) ||
                        (slotEnd > a.StartTime && slotEnd <= a.EndTime) ||
                        (start <= a.StartTime && slotEnd >= a.EndTime)
                    );

                    slots.Add(new
                    {
                        startTime = start.ToString(@"hh\:mm"),
                        endTime = slotEnd.ToString(@"hh\:mm"),
                        isAvailable = !isBooked
                    });
                }
            }

            return Ok(ApiResponse<IEnumerable<object>>.Ok(slots));
        }
    }
}
