using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PatientManagementSystem.Models
{
    public class Message
    {
        [Key]
        public Guid Id { get; set; } = Guid.NewGuid();

        [Required]
        public Guid SenderId { get; set; }

        [ForeignKey("SenderId")]
        public virtual User Sender { get; set; } = null!;

        [Required]
        public Guid ReceiverId { get; set; }

        [ForeignKey("ReceiverId")]
        public virtual User Receiver { get; set; } = null!;

        [Required]
        public string Content { get; set; } = string.Empty;

        public DateTime SentAt { get; set; } = DateTime.UtcNow;
        public bool IsRead { get; set; } = false;
    }
}
