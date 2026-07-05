using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using PatientManagementSystem.Models;

namespace PatientManagementSystem.Services
{
    public interface IPrescriptionService
    {
        Task<IEnumerable<Prescription>> GetPrescriptionsAsync(Guid? medicalRecordId, Guid? patientId, Guid userId, string userRole);
        
        Task<Prescription> CreatePrescriptionAsync(Prescription prescription);
        
        Task<RefillRequest> RequestRefillAsync(Guid prescriptionId, Guid requestUserId);
        
        Task<IEnumerable<RefillRequest>> GetRefillRequestsAsync();
    }
}
