using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using Microsoft.EntityFrameworkCore;
using PatientManagementSystem.Data;
using PatientManagementSystem.DTOs;
using PatientManagementSystem.Models;

namespace PatientManagementSystem.Services
{
    public class AppointmentService : IAppointmentService
    {
        private readonly ApplicationDbContext _context;
        private readonly IMapper _mapper;

        public AppointmentService(ApplicationDbContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        public async Task<(IEnumerable<Appointment> Appointments, int TotalCount)> GetAppointmentsAsync(
            Guid? doctorId,
            Guid? patientId,
            DateTime? startDate,
            DateTime? endDate,
            string? status,
            Guid requestUserId,
            string requestUserRole,
            int page,
            int pageSize)
        {
            var query = _context.Appointments
                .Include(a => a.Patient)
                .Include(a => a.Doctor)
                .AsQueryable();

            if (requestUserRole == "Doctor")
            {
                query = query.Where(a => a.DoctorId == requestUserId);
            }
            else if (requestUserRole == "Patient")
            {
                var patient = await _context.Patients
                    .FirstOrDefaultAsync(p => p.UserId == requestUserId);

                if (patient != null)
                {
                    query = query.Where(a => a.PatientId == patient.Id);
                }
                else
                {
                    return (new List<Appointment>(), 0);
                }
            }

            if (doctorId.HasValue)
                query = query.Where(a => a.DoctorId == doctorId.Value);

            if (patientId.HasValue)
                query = query.Where(a => a.PatientId == patientId.Value);

            if (startDate.HasValue)
                query = query.Where(a => a.AppointmentDate >= startDate.Value);

            if (endDate.HasValue)
                query = query.Where(a => a.AppointmentDate <= endDate.Value);

            if (!string.IsNullOrEmpty(status))
                query = query.Where(a => a.Status == status);

            var totalCount = await query.CountAsync();
            var appointments = await query
                .OrderByDescending(a => a.AppointmentDate)
                .ThenByDescending(a => a.StartTime)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            return (appointments, totalCount);
        }

        public async Task<Appointment?> GetAppointmentByIdAsync(Guid id, Guid requestUserId, string requestUserRole)
        {
            var appointment = await _context.Appointments
                .Include(a => a.Patient)
                .Include(a => a.Doctor)
                .FirstOrDefaultAsync(a => a.Id == id);

            if (appointment == null) return null;

            if (requestUserRole == "Doctor" && appointment.DoctorId != requestUserId)
                throw new UnauthorizedAccessException("You are not authorized to view this appointment.");

            if (requestUserRole == "Patient")
            {
                var patient = await _context.Patients
                    .FirstOrDefaultAsync(p => p.UserId == requestUserId);

                if (patient == null || appointment.PatientId != patient.Id)
                    throw new UnauthorizedAccessException("You are not authorized to view this appointment.");
            }

            return appointment;
        }

        public async Task<Appointment> CreateAppointmentAsync(CreateAppointmentDto createAppointmentDto, Guid requestUserId, string requestUserRole)
        {
            var patientId = Guid.Empty;

            if (requestUserRole == "Patient")
            {
                var patient = await _context.Patients
                    .FirstOrDefaultAsync(p => p.UserId == requestUserId);

                if (patient == null)
                    throw new ApplicationException("Patient record not found");

                patientId = patient.Id;
            }
            else
            {
                if (createAppointmentDto.PatientId == Guid.Empty)
                    throw new ApplicationException("PatientId is required");
                patientId = createAppointmentDto.PatientId;
            }

            var doctor = await _context.Users
                .FirstOrDefaultAsync(u => u.Id == createAppointmentDto.DoctorId && u.Role == "Doctor");

            if (doctor == null)
                throw new ApplicationException("Invalid doctor");

            var dayOfWeek = createAppointmentDto.AppointmentDate.DayOfWeek;
            var availability = await _context.DoctorAvailabilities
                .FirstOrDefaultAsync(da => da.DoctorId == createAppointmentDto.DoctorId && da.DayOfWeek == dayOfWeek);

            TimeSpan allowedStartTime = availability?.StartTime ?? new TimeSpan(8, 0, 0);
            TimeSpan allowedEndTime = availability?.EndTime ?? new TimeSpan(17, 0, 0);
            bool isAvailable = availability?.IsAvailable ?? (dayOfWeek != DayOfWeek.Saturday && dayOfWeek != DayOfWeek.Sunday);

            if (!isAvailable || 
                createAppointmentDto.StartTime < allowedStartTime || 
                createAppointmentDto.EndTime > allowedEndTime)
            {
                throw new ApplicationException("Doctor is not available at this time");
            }

            var conflict = await _context.Appointments
                .Where(a => a.DoctorId == createAppointmentDto.DoctorId &&
                           a.AppointmentDate.Date == createAppointmentDto.AppointmentDate.Date &&
                           a.Status != "Cancelled" &&
                           ((a.StartTime <= createAppointmentDto.StartTime && a.EndTime > createAppointmentDto.StartTime) ||
                            (a.StartTime < createAppointmentDto.EndTime && a.EndTime >= createAppointmentDto.EndTime) ||
                            (a.StartTime >= createAppointmentDto.StartTime && a.EndTime <= createAppointmentDto.EndTime)))
                .FirstOrDefaultAsync();

            if (conflict != null)
                throw new ApplicationException("Appointment time conflicts with existing appointment");

            var appointment = _mapper.Map<Appointment>(createAppointmentDto);
            appointment.PatientId = patientId;
            appointment.Status = requestUserRole == "Patient" ? "PendingPayment" : "Scheduled";
            appointment.CreatedAt = DateTime.UtcNow;

            _context.Appointments.Add(appointment);
            await _context.SaveChangesAsync();

            // Automatically create a pending invoice for this appointment
            var invoice = new Invoice
            {
                Id = Guid.NewGuid(),
                PatientId = patientId,
                AppointmentId = appointment.Id,
                Amount = 50.00m, // Standard fee
                Currency = "usd",
                Status = "Unpaid",
                DueDate = DateTime.UtcNow.AddDays(7),
                CreatedAt = DateTime.UtcNow
            };

            _context.Invoices.Add(invoice);
            await _context.SaveChangesAsync();

            // Reload the newly created appointment with includes to make it complete
            return await _context.Appointments
                .Include(a => a.Patient)
                .Include(a => a.Doctor)
                .FirstAsync(a => a.Id == appointment.Id);
        }

        public async Task<Appointment?> UpdateAppointmentStatusAsync(Guid id, string status, Guid requestUserId, string requestUserRole)
        {
            var appointment = await _context.Appointments
                .Include(a => a.Patient)
                .Include(a => a.Doctor)
                .FirstOrDefaultAsync(a => a.Id == id);
            
            if (appointment == null) return null;

            if (requestUserRole == "Doctor" && appointment.DoctorId != requestUserId)
                throw new UnauthorizedAccessException("You are not authorized to update this appointment status.");

            if (requestUserRole == "Patient")
            {
                var patient = await _context.Patients
                    .FirstOrDefaultAsync(p => p.UserId == requestUserId);

                if (patient == null || appointment.PatientId != patient.Id)
                    throw new UnauthorizedAccessException("You are not authorized to update this appointment status.");
            }

            var validStatuses = new[] { "Scheduled", "Completed", "Cancelled", "NoShow" };
            if (!validStatuses.Contains(status))
                throw new ApplicationException("Invalid status");

            appointment.Status = status;
            appointment.UpdatedAt = DateTime.UtcNow;

            _context.Entry(appointment).State = EntityState.Modified;
            await _context.SaveChangesAsync();

            return appointment;
        }

        public async Task<bool> DeleteAppointmentAsync(Guid id, Guid requestUserId, string requestUserRole)
        {
            var appointment = await _context.Appointments.FindAsync(id);
            if (appointment == null) return false;

            if (requestUserRole == "Doctor" && appointment.DoctorId != requestUserId)
                throw new UnauthorizedAccessException("You are not authorized to delete this appointment.");

            _context.Appointments.Remove(appointment);
            await _context.SaveChangesAsync();

            return true;
        }
    }
}
