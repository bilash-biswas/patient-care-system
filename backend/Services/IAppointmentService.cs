using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using PatientManagementSystem.DTOs;
using PatientManagementSystem.Models;

namespace PatientManagementSystem.Services
{
    public interface IAppointmentService
    {
        Task<(IEnumerable<Appointment> Appointments, int TotalCount)> GetAppointmentsAsync(
            Guid? doctorId,
            Guid? patientId,
            DateTime? startDate,
            DateTime? endDate,
            string? status,
            Guid requestUserId,
            string requestUserRole,
            int page,
            int pageSize);

        Task<Appointment?> GetAppointmentByIdAsync(Guid id, Guid requestUserId, string requestUserRole);
        
        Task<Appointment> CreateAppointmentAsync(CreateAppointmentDto createAppointmentDto, Guid requestUserId, string requestUserRole);
        
        Task<Appointment?> UpdateAppointmentStatusAsync(Guid id, string status, Guid requestUserId, string requestUserRole);
        
        Task<bool> DeleteAppointmentAsync(Guid id, Guid requestUserId, string requestUserRole);
    }
}
