using System.ComponentModel.DataAnnotations;

namespace PatientManagementSystem.Models
{
    public class MedicalRecord
    {
        public Guid Id { get; set; } = Guid.NewGuid();
        public Guid PatientId { get; set; }
        public Guid? DoctorId { get; set; }

        [Required]
        [MaxLength(200)]
        public string Diagnosis { get; set; } = string.Empty;

        [MaxLength(1000)]
        public string Symptoms { get; set; } = string.Empty;

        [MaxLength(1000)]
        public string Treatment { get; set; } = string.Empty;

        [MaxLength(1000)]
        public string? Prescription { get; set; }

        [MaxLength(1000)]
        public string? Notes { get; set; }

        public DateTime VisitDate { get; set; }
        public DateTime? NextVisitDate { get; set; }

        [MaxLength(50)]
        public string? RecordType { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }

        public virtual Patient Patient { get; set; } = null!;
        public virtual User? Doctor { get; set; }
    }
}
