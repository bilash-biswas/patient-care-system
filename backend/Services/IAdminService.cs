using System.Collections.Generic;
using System.Threading.Tasks;
using PatientManagementSystem.DTOs;

namespace PatientManagementSystem.Services
{
    public interface IAdminService
    {
        Task<IEnumerable<AdminUserDto>> GetAllUsersAsync(string? role);
        Task<AdminDashboardStatsDto> GetDashboardStatsAsync();
        Task<bool> ToggleUserStatusAsync(Guid userId, bool isActive);
    }
}
