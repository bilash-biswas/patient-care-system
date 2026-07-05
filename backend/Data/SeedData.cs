using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using PatientManagementSystem.Models;

namespace PatientManagementSystem.Data
{
    public static class SeedData
    {
        public static async Task InitializeAsync(IServiceProvider serviceProvider)
        {
            using var scope = serviceProvider.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();

            // Ensure database is created
            await context.Database.EnsureCreatedAsync();

            // Seed Admin User
            var existingAdmin = await context.Users.FirstOrDefaultAsync(u => u.Role == "Admin");
            if (existingAdmin == null)
            {
                var adminUser = new User
                {
                    Email = "admin@hospital.com",
                    Username = "admin",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("Admin@123"),
                    FirstName = "System",
                    LastName = "Administrator",
                    Role = "Admin",
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                };
                context.Users.Add(adminUser);
            }
            else
            {
                existingAdmin.Email = "admin@hospital.com";
                existingAdmin.PasswordHash = BCrypt.Net.BCrypt.HashPassword("Admin@123");
            }
            await context.SaveChangesAsync();

            // Seed Doctor User
            if (!await context.Users.AnyAsync(u => u.Role == "Doctor"))
            {
                var doctorUser = new User
                {
                    Email = "doctor@hospital.com",
                    Username = "dr.smith",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("Doctor@123"),
                    FirstName = "John",
                    LastName = "Smith",
                    PhoneNumber = "+1234567890",
                    Role = "Doctor",
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                };

                context.Users.Add(doctorUser);
                await context.SaveChangesAsync();
            }

            // Seed Nurse User
            if (!await context.Users.AnyAsync(u => u.Role == "Nurse"))
            {
                var nurseUser = new User
                {
                    Email = "nurse@hospital.com",
                    Username = "nurse.jane",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("Nurse@123"),
                    FirstName = "Jane",
                    LastName = "Doe",
                    PhoneNumber = "+1234567891",
                    Role = "Nurse",
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                };

                context.Users.Add(nurseUser);
                await context.SaveChangesAsync();
            }

            // Seed Sample Patient User
            if (!await context.Users.AnyAsync(u => u.Role == "Patient"))
            {
                var patientUser = new User
                {
                    Email = "patient@example.com",
                    Username = "patient.john",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("Patient@123"),
                    FirstName = "John",
                    LastName = "Patient",
                    PhoneNumber = "+1234567892",
                    Role = "Patient",
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                };

                context.Users.Add(patientUser);
                await context.SaveChangesAsync();

                // Create patient record
                var patient = new Patient
                {
                    UserId = patientUser.Id,
                    FirstName = patientUser.FirstName,
                    LastName = patientUser.LastName,
                    Gender = "Male",
                    DateOfBirth = new DateTime(1990, 5, 15, 0, 0, 0, DateTimeKind.Utc),
                    BloodGroup = "A+",
                    Address = "123 Main Street, City",
                    EmergencyContactName = "Mary Patient",
                    EmergencyContactPhone = "+1234567893",
                    InsuranceProvider = "HealthCare Inc.",
                    InsurancePolicyNumber = "HC123456789",
                    CreatedAt = DateTime.UtcNow
                };

                context.Patients.Add(patient);
                await context.SaveChangesAsync();

                // Create sample appointment
                var doctor = await context.Users.FirstOrDefaultAsync(u => u.Role == "Doctor");
                if (doctor != null)
                {
                    var appointment = new Appointment
                    {
                        PatientId = patient.Id,
                        DoctorId = doctor.Id,
                        Reason = "Annual Checkup",
                        AppointmentDate = DateTime.UtcNow.AddDays(7),
                        StartTime = new TimeSpan(9, 0, 0),
                        EndTime = new TimeSpan(9, 30, 0),
                        Status = "Scheduled",
                        CreatedAt = DateTime.UtcNow
                    };

                    context.Appointments.Add(appointment);

                    // Create sample medical record
                    var medicalRecord = new MedicalRecord
                    {
                        PatientId = patient.Id,
                        DoctorId = doctor.Id,
                        Diagnosis = "Hypertension Stage 1",
                        Symptoms = "Elevated blood pressure readings",
                        Treatment = "Lifestyle modifications, regular monitoring",
                        Prescription = "No medication required at this stage",
                        VisitDate = DateTime.UtcNow.AddDays(-30),
                        NextVisitDate = DateTime.UtcNow.AddDays(30),
                        RecordType = "Consultation",
                        CreatedAt = DateTime.UtcNow
                    };

                    context.MedicalRecords.Add(medicalRecord);
                    await context.SaveChangesAsync();
                }
            }

            await context.SaveChangesAsync();
        }

        public static async Task SeedBulkDataAsync(IServiceProvider serviceProvider)
        {
            using var scope = serviceProvider.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();

            // Only seed if we don't have many patients already (avoid double seeding)
            if (await context.Patients.CountAsync() > 100) return;

            string passwordHash = BCrypt.Net.BCrypt.HashPassword("password123");
            var doctors = new List<User>();
            var patients = new List<User>();

            // Seed 1000 Doctors
            for (int i = 1; i <= 1000; i++)
            {
                doctors.Add(new User
                {
                    Email = $"doctor{i}@hospital.com",
                    Username = $"doctor{i}",
                    PasswordHash = passwordHash,
                    FirstName = "Doctor",
                    LastName = i.ToString(),
                    Role = "Doctor",
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                });
            }
            context.Users.AddRange(doctors);
            await context.SaveChangesAsync();

            // Seed 1000 Nurses
            var nurses = new List<User>();
            for (int i = 1; i <= 1000; i++)
            {
                nurses.Add(new User
                {
                    Email = $"nurse{i}@hospital.com",
                    Username = $"nurse{i}",
                    PasswordHash = passwordHash,
                    FirstName = "Nurse",
                    LastName = i.ToString(),
                    Role = "Nurse",
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                });
            }
            context.Users.AddRange(nurses);
            await context.SaveChangesAsync();

            // Seed 1000 Patients
            for (int i = 1; i <= 1000; i++)
            {
                patients.Add(new User
                {
                    Email = $"patient{i}@example.com",
                    Username = $"patient{i}",
                    PasswordHash = passwordHash,
                    FirstName = "Patient",
                    LastName = i.ToString(),
                    Role = "Patient",
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                });
            }
            context.Users.AddRange(patients);
            await context.SaveChangesAsync();

            // Create Patient profiles
            var patientProfiles = new List<Patient>();
            int counter = 0;
            foreach (var pUser in patients)
            {
                counter++;
                patientProfiles.Add(new Patient
                {
                    UserId = pUser.Id,
                    FirstName = pUser.FirstName,
                    LastName = pUser.LastName,
                    Gender = counter % 2 == 0 ? "Male" : "Female",
                    DateOfBirth = DateTime.UtcNow.AddYears(-20 - (counter % 30)),
                    BloodGroup = "O+",
                    Address = $"Address {counter}",
                    CreatedAt = DateTime.UtcNow
                });
            }
            context.Patients.AddRange(patientProfiles);
            await context.SaveChangesAsync();

            // Seed 1000 Appointments
            var appointments = new List<Appointment>();
            for (int i = 0; i < 1000; i++)
            {
                appointments.Add(new Appointment
                {
                    PatientId = patientProfiles[i].Id,
                    DoctorId = doctors[i % 1000].Id,
                    Reason = $"Reason {i}",
                    AppointmentDate = DateTime.UtcNow.AddDays(i % 30),
                    StartTime = new TimeSpan(9, 0, 0),
                    EndTime = new TimeSpan(9, 30, 0),
                    Status = "Scheduled",
                    CreatedAt = DateTime.UtcNow
                });
            }
            context.Appointments.AddRange(appointments);
            await context.SaveChangesAsync();

            // Seed 1000 Medical Records
            var medicalRecords = new List<MedicalRecord>();
            for (int i = 0; i < 1000; i++)
            {
                medicalRecords.Add(new MedicalRecord
                {
                    PatientId = patientProfiles[i].Id,
                    DoctorId = doctors[i % 1000].Id,
                    Diagnosis = $"Diagnosis {i}",
                    Symptoms = $"Symptoms {i}",
                    Treatment = $"Treatment {i}",
                    VisitDate = DateTime.UtcNow.AddDays(-(i % 60)),
                    RecordType = "Consultation",
                    CreatedAt = DateTime.UtcNow
                });
            }
            context.MedicalRecords.AddRange(medicalRecords);
            await context.SaveChangesAsync();
        }
    }
}