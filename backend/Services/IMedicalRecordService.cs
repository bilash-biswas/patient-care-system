using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using PatientManagementSystem.DTOs;
using PatientManagementSystem.Models;

namespace PatientManagementSystem.Services
{
    public interface IMedicalRecordService
    {
        Task<(IEnumerable<MedicalRecord> MedicalRecords, int TotalCount)> GetMedicalRecordsAsync(
            Guid? patientId,
            Guid? doctorId,
            DateTime? startDate,
            DateTime? endDate,
            string? recordType,
            Guid requestUserId,
            string requestUserRole,
            int page,
            int pageSize);

        Task<MedicalRecord?> GetMedicalRecordByIdAsync(Guid id, Guid requestUserId, string requestUserRole);

        Task<MedicalRecord> CreateMedicalRecordAsync(CreateMedicalRecordDto createMedicalRecordDto, Guid requestUserId);

        Task<MedicalRecord?> UpdateMedicalRecordAsync(Guid id, CreateMedicalRecordDto updateMedicalRecordDto, Guid requestUserId, string requestUserRole);

        Task<bool> DeleteMedicalRecordAsync(Guid id);
    }
}
