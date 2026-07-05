using System;

namespace PatientManagementSystem.DTOs
{
    public class InvoiceResponseDto
    {
        public Guid Id { get; set; }
        public Guid PatientId { get; set; }
        public Guid? AppointmentId { get; set; }
        public decimal Amount { get; set; }
        public string Currency { get; set; } = "usd";
        public string Status { get; set; } = "Pending";
        public DateTime DueDate { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? PaidAt { get; set; }
    }
}
