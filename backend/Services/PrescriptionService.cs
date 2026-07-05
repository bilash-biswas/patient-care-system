using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using PatientManagementSystem.Data;
using PatientManagementSystem.Models;

namespace PatientManagementSystem.Services
{
    public class PrescriptionService : IPrescriptionService
    {
        private readonly ApplicationDbContext _context;

        public PrescriptionService(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<Prescription>> GetPrescriptionsAsync(Guid? medicalRecordId, Guid? patientId, Guid userId, string userRole)
        {
            var query = _context.Prescriptions.AsQueryable();

            if (userRole.Equals("Patient", StringComparison.OrdinalIgnoreCase))
            {
                var patient = await _context.Patients.FirstOrDefaultAsync(p => p.UserId == userId);
                if (patient == null)
                {
                    throw new KeyNotFoundException("Patient record not found");
                }

                if (patientId.HasValue && patientId.Value != patient.Id)
                {
                    throw new UnauthorizedAccessException("You are not authorized to view prescriptions for another patient.");
                }

                query = query.Where(p => p.MedicalRecord.PatientId == patient.Id);

                if (medicalRecordId.HasValue)
                {
                    var recordExistsForPatient = await _context.MedicalRecords
                        .AnyAsync(mr => mr.Id == medicalRecordId.Value && mr.PatientId == patient.Id);
                    if (!recordExistsForPatient)
                    {
                        throw new UnauthorizedAccessException("You are not authorized to view prescriptions for this medical record.");
                    }
                    query = query.Where(p => p.MedicalRecordId == medicalRecordId.Value);
                }
            }
            else
            {
                if (medicalRecordId.HasValue)
                {
                    query = query.Where(p => p.MedicalRecordId == medicalRecordId.Value);
                }

                if (patientId.HasValue)
                {
                    query = query.Where(p => p.MedicalRecord.PatientId == patientId.Value);
                }
            }

            return await query
                .Include(p => p.MedicalRecord)
                .OrderByDescending(p => p.CreatedAt)
                .ToListAsync();
        }

        public async Task<Prescription> CreatePrescriptionAsync(Prescription prescription)
        {
            var medicalRecordExists = await _context.MedicalRecords.AnyAsync(mr => mr.Id == prescription.MedicalRecordId);
            if (!medicalRecordExists)
            {
                throw new KeyNotFoundException($"Medical record with ID {prescription.MedicalRecordId} was not found.");
            }

            prescription.CreatedAt = DateTime.UtcNow;
            _context.Prescriptions.Add(prescription);
            await _context.SaveChangesAsync();
            return prescription;
        }

        public async Task<RefillRequest> RequestRefillAsync(Guid prescriptionId, Guid requestUserId)
        {
            var patient = await _context.Patients.FirstOrDefaultAsync(p => p.UserId == requestUserId);
            if (patient == null)
                throw new KeyNotFoundException("Patient record not found");

            var prescription = await _context.Prescriptions
                .Include(p => p.MedicalRecord)
                .FirstOrDefaultAsync(p => p.Id == prescriptionId);

            if (prescription == null)
                throw new KeyNotFoundException("Prescription not found");

            if (prescription.MedicalRecord.PatientId != patient.Id)
                throw new UnauthorizedAccessException("You are not authorized to request a refill for this prescription.");

            var existingPendingRequest = await _context.RefillRequests
                .AnyAsync(r => r.PrescriptionId == prescriptionId && r.Status == "Pending");
            if (existingPendingRequest)
                throw new ApplicationException("There is already a pending refill request for this prescription.");

            var refillRequest = new RefillRequest
            {
                PrescriptionId = prescriptionId,
                PatientId = patient.Id,
                Status = "Pending",
                RequestDate = DateTime.UtcNow
            };

            _context.RefillRequests.Add(refillRequest);
            await _context.SaveChangesAsync();

            return refillRequest;
        }

        public async Task<IEnumerable<RefillRequest>> GetRefillRequestsAsync()
        {
            return await _context.RefillRequests
                .Include(r => r.Prescription)
                .Include(r => r.Patient)
                .OrderByDescending(r => r.RequestDate)
                .ToListAsync();
        }
    }
}
