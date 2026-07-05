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
    public class MedicalRecordService : IMedicalRecordService
    {
        private readonly ApplicationDbContext _context;
        private readonly IMapper _mapper;

        public MedicalRecordService(ApplicationDbContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        public async Task<(IEnumerable<MedicalRecord> MedicalRecords, int TotalCount)> GetMedicalRecordsAsync(
            Guid? patientId,
            Guid? doctorId,
            DateTime? startDate,
            DateTime? endDate,
            string? recordType,
            Guid requestUserId,
            string requestUserRole,
            int page,
            int pageSize)
        {
            var query = _context.MedicalRecords
                .Include(m => m.Patient)
                .Include(m => m.Doctor)
                .AsQueryable();

            if (requestUserRole == "Doctor")
            {
                query = query.Where(m => m.DoctorId == requestUserId);
            }
            else if (requestUserRole == "Patient")
            {
                query = query.Where(m => m.Patient.UserId == requestUserId);
            }

            if (patientId.HasValue)
                query = query.Where(m => m.PatientId == patientId.Value);

            if (doctorId.HasValue)
                query = query.Where(m => m.DoctorId == doctorId.Value);

            if (startDate.HasValue)
                query = query.Where(m => m.VisitDate >= startDate.Value);

            if (endDate.HasValue)
                query = query.Where(m => m.VisitDate <= endDate.Value);

            if (!string.IsNullOrEmpty(recordType))
                query = query.Where(m => m.RecordType == recordType);

            var totalCount = await query.CountAsync();
            var medicalRecords = await query
                .OrderByDescending(m => m.VisitDate)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            return (medicalRecords, totalCount);
        }

        public async Task<MedicalRecord?> GetMedicalRecordByIdAsync(Guid id, Guid requestUserId, string requestUserRole)
        {
            var medicalRecord = await _context.MedicalRecords
                .Include(m => m.Patient)
                .Include(m => m.Doctor)
                .FirstOrDefaultAsync(m => m.Id == id);

            if (medicalRecord == null) return null;

            if (requestUserRole == "Doctor" && medicalRecord.DoctorId != requestUserId)
                throw new UnauthorizedAccessException("You are not authorized to access this medical record.");

            if (requestUserRole == "Patient" && medicalRecord.Patient.UserId != requestUserId)
                throw new UnauthorizedAccessException("You are not authorized to access this medical record.");

            return medicalRecord;
        }

        public async Task<MedicalRecord> CreateMedicalRecordAsync(CreateMedicalRecordDto createMedicalRecordDto, Guid requestUserId)
        {
            var patient = await _context.Patients.FindAsync(createMedicalRecordDto.PatientId);
            if (patient == null)
                throw new ApplicationException("Patient not found");

            if (createMedicalRecordDto.DoctorId.HasValue)
            {
                var doctor = await _context.Users
                    .FirstOrDefaultAsync(u => u.Id == createMedicalRecordDto.DoctorId.Value &&
                                            (u.Role == "Doctor" || u.Role == "Admin"));

                if (doctor == null)
                    throw new ApplicationException("Invalid doctor");
            }
            else
            {
                var user = await _context.Users.FindAsync(requestUserId);
                if (user?.Role == "Doctor")
                {
                    createMedicalRecordDto.DoctorId = user.Id;
                }
            }

            var medicalRecord = _mapper.Map<MedicalRecord>(createMedicalRecordDto);
            medicalRecord.CreatedAt = DateTime.UtcNow;

            _context.MedicalRecords.Add(medicalRecord);
            await _context.SaveChangesAsync();

            // Reload to populate Patient and Doctor navigation properties
            return await _context.MedicalRecords
                .Include(m => m.Patient)
                .Include(m => m.Doctor)
                .FirstAsync(m => m.Id == medicalRecord.Id);
        }

        public async Task<MedicalRecord?> UpdateMedicalRecordAsync(Guid id, CreateMedicalRecordDto updateMedicalRecordDto, Guid requestUserId, string requestUserRole)
        {
            var medicalRecord = await _context.MedicalRecords
                .Include(m => m.Patient)
                .Include(m => m.Doctor)
                .FirstOrDefaultAsync(m => m.Id == id);

            if (medicalRecord == null) return null;

            if (requestUserRole == "Doctor" && medicalRecord.DoctorId != requestUserId)
                throw new UnauthorizedAccessException("You are not authorized to update this medical record.");

            _mapper.Map(updateMedicalRecordDto, medicalRecord);
            medicalRecord.UpdatedAt = DateTime.UtcNow;

            _context.Entry(medicalRecord).State = EntityState.Modified;
            await _context.SaveChangesAsync();

            return medicalRecord;
        }

        public async Task<bool> DeleteMedicalRecordAsync(Guid id)
        {
            var medicalRecord = await _context.MedicalRecords.FindAsync(id);
            if (medicalRecord == null) return false;

            _context.MedicalRecords.Remove(medicalRecord);
            await _context.SaveChangesAsync();

            return true;
        }
    }
}
