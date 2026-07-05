namespace PatientManagementSystem.DTOs
{
    public class CreateMedicalRecordDto
    {
        public Guid PatientId { get; set; }
        public Guid? DoctorId { get; set; }
        public string Diagnosis { get; set; } = string.Empty;
        public string Symptoms { get; set; } = string.Empty;
        public string Treatment { get; set; } = string.Empty;
        public string? Prescription { get; set; }
        public string? Notes { get; set; }
        public DateTime VisitDate { get; set; }
        public DateTime? NextVisitDate { get; set; }
        public string? RecordType { get; set; }
    }

    public class MedicalRecordResponseDto
    {
        public Guid Id { get; set; }
        public Guid PatientId { get; set; }
        public string PatientName { get; set; } = string.Empty;
        public Guid? DoctorId { get; set; }
        public string? DoctorName { get; set; }
        public string Diagnosis { get; set; } = string.Empty;
        public string Symptoms { get; set; } = string.Empty;
        public string Treatment { get; set; } = string.Empty;
        public string? Prescription { get; set; }
        public string? Notes { get; set; }
        public DateTime VisitDate { get; set; }
        public DateTime? NextVisitDate { get; set; }
        public string? RecordType { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
