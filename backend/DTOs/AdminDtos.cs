using System;

namespace PatientManagementSystem.DTOs
{
    public class AdminUserDto
    {
        public Guid Id { get; set; }
        public string Email { get; set; } = string.Empty;
        public string Username { get; set; } = string.Empty;
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public string Role { get; set; } = string.Empty;
        public bool IsActive { get; set; }
        public DateTime CreatedAt { get; set; }
    }

    public class AdminDashboardStatsDto
    {
        public int TotalUsers { get; set; }
        public int ActiveUsers { get; set; }
        public int TotalPatients { get; set; }
        public int TotalDoctors { get; set; }
        public int TotalNurses { get; set; }
        public int TotalAppointments { get; set; }
        public int UpcomingAppointments { get; set; }
        public decimal TotalRevenue { get; set; }
        public int PaidInvoicesCount { get; set; }
        public int UnpaidInvoicesCount { get; set; }
    }

    public class ToggleStatusDto
    {
        public bool IsActive { get; set; }
    }
}
