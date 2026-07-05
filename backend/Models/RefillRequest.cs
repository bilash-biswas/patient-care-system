using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PatientManagementSystem.Models
{
    public class RefillRequest
    {
        [Key]
        public Guid Id { get; set; } = Guid.NewGuid();

        [Required]
        public Guid PrescriptionId { get; set; }

        [ForeignKey("PrescriptionId")]
        public virtual Prescription Prescription { get; set; } = null!;

        [Required]
        public Guid PatientId { get; set; }

        [ForeignKey("PatientId")]
        public virtual Patient Patient { get; set; } = null!;

        public string Status { get; set; } = "Pending"; // Pending, Approved, Denied

        public DateTime RequestDate { get; set; } = DateTime.UtcNow;
        public DateTime? ProcessedDate { get; set; }
    }
}
