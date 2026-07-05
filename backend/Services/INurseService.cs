using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using PatientManagementSystem.Models;

namespace PatientManagementSystem.Services
{
    public interface INurseService
    {
        Task<(IEnumerable<User> Nurses, int TotalCount)> GetNursesAsync(string? search, bool? isActive, int page, int pageSize);
        Task<User?> GetNurseByIdAsync(Guid id);
    }
}
