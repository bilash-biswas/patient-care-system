using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using PatientManagementSystem.Data;
using PatientManagementSystem.Models;

namespace PatientManagementSystem.Services
{
    public class NurseService : INurseService
    {
        private readonly ApplicationDbContext _context;

        public NurseService(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<(IEnumerable<User> Nurses, int TotalCount)> GetNursesAsync(string? search, bool? isActive, int page, int pageSize)
        {
            IQueryable<User> query = _context.Users.Where(u => u.Role == "Nurse");

            if (!string.IsNullOrEmpty(search))
            {
                var searchLower = search.ToLower();
                query = query.Where(u => 
                    u.FirstName.ToLower().Contains(searchLower) || 
                    u.LastName.ToLower().Contains(searchLower) || 
                    u.Email.ToLower().Contains(searchLower));
            }

            if (isActive.HasValue)
            {
                query = query.Where(u => u.IsActive == isActive.Value);
            }

            var totalCount = await query.CountAsync();

            var nurses = await query
                .OrderBy(u => u.LastName)
                .ThenBy(u => u.FirstName)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            return (nurses, totalCount);
        }

        public async Task<User?> GetNurseByIdAsync(Guid id)
        {
            return await _context.Users
                .FirstOrDefaultAsync(u => u.Role == "Nurse" && u.Id == id);
        }
    }
}
