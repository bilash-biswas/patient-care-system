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
    public class PatientService : IPatientService
    {
        private readonly ApplicationDbContext _context;
        private readonly IMapper _mapper;

        public PatientService(ApplicationDbContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        public async Task<(IEnumerable<Patient> Patients, int TotalCount)> GetPatientsAsync(string? search, int page, int pageSize)
        {
            var query = _context.Patients.AsQueryable();

            if (!string.IsNullOrEmpty(search))
            {
                query = query.Where(p =>
                    p.FirstName.Contains(search) ||
                    p.LastName.Contains(search) ||
                    p.EmergencyContactName!.Contains(search) ||
                    p.EmergencyContactPhone!.Contains(search));
            }

            var totalCount = await query.CountAsync();
            var patients = await query
                .OrderBy(p => p.LastName)
                .ThenBy(p => p.FirstName)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            return (patients, totalCount);
        }

        public async Task<Patient?> GetPatientByIdAsync(Guid id)
        {
            return await _context.Patients.FindAsync(id);
        }

        public async Task<Patient> CreatePatientAsync(CreatePatientDto createPatientDto, Guid userId)
        {
            var patient = _mapper.Map<Patient>(createPatientDto);
            
            patient.UserId = userId;
            patient.DateOfBirth = DateTime.SpecifyKind(patient.DateOfBirth, DateTimeKind.Utc);
            patient.CreatedAt = DateTime.UtcNow;
            patient.UpdatedAt = DateTime.UtcNow;

            _context.Patients.Add(patient);
            await _context.SaveChangesAsync();

            return patient;
        }

        public async Task<Patient?> UpdatePatientAsync(Guid id, UpdatePatientDto updatePatientDto)
        {
            var patient = await _context.Patients.FindAsync(id);
            if (patient == null) return null;

            _mapper.Map(updatePatientDto, patient);

            patient.DateOfBirth = DateTime.SpecifyKind(patient.DateOfBirth, DateTimeKind.Utc);
            patient.CreatedAt = DateTime.SpecifyKind(patient.CreatedAt, DateTimeKind.Utc);
            patient.UpdatedAt = DateTime.UtcNow;

            _context.Entry(patient).State = EntityState.Modified;
            await _context.SaveChangesAsync();

            return patient;
        }

        public async Task<bool> DeletePatientAsync(Guid id)
        {
            var patient = await _context.Patients.FindAsync(id);
            if (patient == null) return false;

            _context.Patients.Remove(patient);
            await _context.SaveChangesAsync();

            return true;
        }

        public async Task<IEnumerable<Appointment>> GetPatientAppointmentsAsync(Guid patientId)
        {
            return await _context.Appointments
                .Include(a => a.Doctor)
                .Where(a => a.PatientId == patientId)
                .OrderByDescending(a => a.AppointmentDate)
                .ThenByDescending(a => a.StartTime)
                .ToListAsync();
        }

        public async Task<IEnumerable<MedicalRecord>> GetPatientMedicalRecordsAsync(Guid patientId)
        {
            return await _context.MedicalRecords
                .Include(m => m.Doctor)
                .Where(m => m.PatientId == patientId)
                .OrderByDescending(m => m.VisitDate)
                .ToListAsync();
        }

        public async Task<Patient?> GetPatientByUserIdAsync(Guid userId)
        {
            var patient = await _context.Patients.FirstOrDefaultAsync(p => p.UserId == userId);
            if (patient == null)
            {
                var user = await _context.Users.FindAsync(userId);
                if (user != null && user.Role == "Patient")
                {
                    patient = new Patient
                    {
                        UserId = user.Id,
                        FirstName = user.FirstName,
                        LastName = user.LastName,
                        Gender = "Not Specified",
                        DateOfBirth = new DateTime(2000, 1, 1, 0, 0, 0, DateTimeKind.Utc),
                        Phone = user.PhoneNumber,
                        CreatedAt = DateTime.UtcNow,
                        UpdatedAt = DateTime.UtcNow
                    };
                    _context.Patients.Add(patient);
                    await _context.SaveChangesAsync();
                }
            }
            return patient;
        }
    }
}
