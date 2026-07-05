using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using PatientManagementSystem.DTOs;
using PatientManagementSystem.Models;

namespace PatientManagementSystem.Services
{
    public interface IPatientService
    {
        Task<(IEnumerable<Patient> Patients, int TotalCount)> GetPatientsAsync(string? search, int page, int pageSize);
        Task<Patient?> GetPatientByIdAsync(Guid id);
        Task<Patient> CreatePatientAsync(CreatePatientDto createPatientDto, Guid userId);
        Task<Patient?> UpdatePatientAsync(Guid id, UpdatePatientDto updatePatientDto);
        Task<bool> DeletePatientAsync(Guid id);
        Task<IEnumerable<Appointment>> GetPatientAppointmentsAsync(Guid patientId);
        Task<IEnumerable<MedicalRecord>> GetPatientMedicalRecordsAsync(Guid patientId);
        Task<Patient?> GetPatientByUserIdAsync(Guid userId);
    }
}
