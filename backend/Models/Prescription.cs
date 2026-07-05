using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PatientManagementSystem.Models
{
    public class Prescription
    {
        [Key]
        public Guid Id { get; set; } = Guid.NewGuid();

        [Required]
        public Guid MedicalRecordId { get; set; }

        [ForeignKey("MedicalRecordId")]
        public virtual MedicalRecord MedicalRecord { get; set; } = null!;

        [Required]
        public string MedicationName { get; set; } = string.Empty;

        public string Dosage { get; set; } = string.Empty;
        public string Frequency { get; set; } = string.Empty;
        public int DurationDays { get; set; }
        
        public string Status { get; set; } = "Active"; // Active, Completed, Cancelled

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public virtual ICollection<RefillRequest> RefillRequests { get; set; } = new List<RefillRequest>();
    }
}
