using System;

namespace PatientManagementSystem.DTOs
{
    public class DoctorAvailabilityDto
    {
        public DayOfWeek DayOfWeek { get; set; }
        public string StartTime { get; set; } = string.Empty;
        public string EndTime { get; set; } = string.Empty;
        public bool IsAvailable { get; set; }
    }
}
