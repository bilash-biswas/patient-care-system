using Microsoft.EntityFrameworkCore;
using PatientManagementSystem.Models;

namespace PatientManagementSystem.Data
{
    public class ApplicationDbContext : DbContext
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options)
        {

        }

        public DbSet<User> Users { get; set; }
        public DbSet<RefreshToken> RefreshTokens { get; set; }
        public DbSet<Patient> Patients { get; set; }
        public DbSet<Appointment> Appointments { get; set; }
        public DbSet<MedicalRecord> MedicalRecords { get; set; }
        public DbSet<DoctorAvailability> DoctorAvailabilities { get; set; }
        public DbSet<Prescription> Prescriptions { get; set; }
        public DbSet<RefillRequest> RefillRequests { get; set; }
        public DbSet<Invoice> Invoices { get; set; }
        public DbSet<Message> Messages { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            modelBuilder.Entity<User>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.HasIndex(e => e.Email).IsUnique();
                entity.HasIndex(e => e.Username).IsUnique();
                entity.Property(e => e.CreatedAt).HasDefaultValueSql("CURRENT_TIMESTAMP");
                entity.Property(e => e.Role).HasDefaultValue("Patient");
                entity.Property(e => e.IsActive).HasDefaultValue(true);
            });

            modelBuilder.Entity<RefreshToken>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.HasIndex(e => e.Token).IsUnique();
                entity.HasOne(e => e.User)
                .WithMany(u => u.RefreshTokens)
                .HasForeignKey(e => e.UserId)
                .OnDelete(DeleteBehavior.Cascade);
            });

            modelBuilder.Entity<Patient>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.HasOne(e => e.User)
                .WithOne()
                .HasForeignKey<Patient>(e => e.UserId)
                .OnDelete(DeleteBehavior.Cascade);
                entity.Property(e => e.CreatedAt).HasDefaultValueSql("CURRENT_TIMESTAMP");
            });

            modelBuilder.Entity<Appointment>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.HasIndex(e => e.AppointmentDate);
                entity.HasIndex(e => e.PatientId);
                entity.HasIndex(e => e.DoctorId);
                entity.HasOne(e => e.Patient)
                .WithMany(p => p.Appointments)
                .HasForeignKey(e => e.PatientId)
                .OnDelete(DeleteBehavior.Restrict);
                entity.HasOne(e => e.Doctor)
                .WithMany(d => d.DoctorAppointments)
                .HasForeignKey(e => e.DoctorId)
                .OnDelete(DeleteBehavior.Restrict);
                entity.Property(e => e.Status).HasDefaultValue("Scheduled");
                entity.Property(e => e.CreatedAt).HasDefaultValueSql("CURRENT_TIMESTAMP");
            });

            modelBuilder.Entity<MedicalRecord>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.HasOne(e => e.Patient)
                .WithMany(p => p.MedicalRecords)
                .HasForeignKey(e => e.PatientId)
                .OnDelete(DeleteBehavior.Cascade);
                entity.HasOne(e => e.Doctor)
                .WithMany(d => d.MedicalRecords)
                .HasForeignKey(e => e.DoctorId)
                .OnDelete(DeleteBehavior.SetNull);
                entity.Property(e => e.CreatedAt).HasDefaultValueSql("CURRENT_TIMESTAMP");
            });

            modelBuilder.Entity<DoctorAvailability>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.HasOne(e => e.Doctor)
                .WithMany()
                .HasForeignKey(e => e.DoctorId)
                .OnDelete(DeleteBehavior.Cascade);
            });

            modelBuilder.Entity<Prescription>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.HasOne(e => e.MedicalRecord)
                .WithMany()
                .HasForeignKey(e => e.MedicalRecordId)
                .OnDelete(DeleteBehavior.Cascade);
                entity.Property(e => e.CreatedAt).HasDefaultValueSql("CURRENT_TIMESTAMP");
            });

            modelBuilder.Entity<RefillRequest>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.HasOne(e => e.Prescription)
                .WithMany(p => p.RefillRequests)
                .HasForeignKey(e => e.PrescriptionId)
                .OnDelete(DeleteBehavior.Cascade);
                entity.HasOne(e => e.Patient)
                .WithMany()
                .HasForeignKey(e => e.PatientId)
                .OnDelete(DeleteBehavior.Restrict);
            });

            modelBuilder.Entity<Invoice>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.HasOne(e => e.Patient)
                .WithMany()
                .HasForeignKey(e => e.PatientId)
                .OnDelete(DeleteBehavior.Restrict);
                entity.Property(e => e.CreatedAt).HasDefaultValueSql("CURRENT_TIMESTAMP");
            });

            modelBuilder.Entity<Message>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.HasIndex(e => e.SenderId);
                entity.HasIndex(e => e.ReceiverId);
                entity.HasIndex(e => e.SentAt);
                entity.HasOne(e => e.Sender)
                .WithMany()
                .HasForeignKey(e => e.SenderId)
                .OnDelete(DeleteBehavior.Restrict);
                entity.HasOne(e => e.Receiver)
                .WithMany()
                .HasForeignKey(e => e.ReceiverId)
                .OnDelete(DeleteBehavior.Restrict);
            });
        }
    }
}
