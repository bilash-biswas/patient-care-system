using System.ComponentModel.DataAnnotations;

namespace PatientManagementSystem.Models
{
    public class Appointment
    {
        public Guid Id { get; set; } = Guid.NewGuid();
        public Guid PatientId { get; set; }
        public Guid DoctorId { get; set; }

        [MaxLength(500)]
        public string Reason { get; set; } = string.Empty;

        public DateTime AppointmentDate { get; set; }
        public TimeSpan StartTime { get; set; }
        public TimeSpan EndTime { get; set; }

        [MaxLength(20)]
        public string Status { get; set; } = "Scheduled"; // Scheduled, Completed, Cancelled, NoShow

        [MaxLength(500)]
        public string? Notes { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }

        public virtual Patient Patient { get; set; } = null!;
        public virtual User Doctor { get; set; } = null!;

    }
}
