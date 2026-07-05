using System.ComponentModel.DataAnnotations;

namespace PatientManagementSystem.Models
{
    public class Patient
    {
        [Key]
        public Guid Id { get; set; } = Guid.NewGuid();

        [Required]
        public Guid UserId { get; set; }

        [Required]
        [MaxLength(50)]
        public string FirstName { get; set; } = string.Empty;

        [Required]
        [MaxLength(50)]
        public string LastName { get; set; } = string.Empty;

        [Required]
        [MaxLength(20)]
        public string Gender { get; set; } = string.Empty;

        [Required]
        public DateTime DateOfBirth { get; set; }

        [MaxLength(20)]
        public string? BloodGroup { get; set; }

        [MaxLength(500)]
        public string? Address { get; set; }

        [MaxLength(100)]
        public string? EmergencyContactName { get; set; }

        [MaxLength(20)]
        public string? EmergencyContactPhone { get; set; }

        [MaxLength(50)]
        public string? InsuranceProvider { get; set; }

        [MaxLength(50)]
        public string? InsurancePolicyNumber { get; set; }
        
        [MaxLength(20)]
        public string? Phone { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }

        public virtual User User { get; set; } = null!;
        public virtual ICollection<Appointment> Appointments { get; set; } = new List<Appointment>();
        public virtual ICollection<MedicalRecord> MedicalRecords { get; set; } = new List<MedicalRecord>();
    }
}
