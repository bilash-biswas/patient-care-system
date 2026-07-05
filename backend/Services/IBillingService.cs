using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using PatientManagementSystem.DTOs;

namespace PatientManagementSystem.Services
{
    public interface IBillingService
    {
        Task<IEnumerable<InvoiceResponseDto>> GetInvoicesAsync(Guid? patientId, Guid userId, string userRole);
        Task<InvoiceResponseDto?> GetInvoiceByIdAsync(Guid id, Guid userId, string userRole);
        Task<string> PayInvoiceAsync(Guid id, Guid userId, string userRole);
    }
}
