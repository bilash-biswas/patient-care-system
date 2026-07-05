using AutoMapper;
using PatientManagementSystem.DTOs;
using PatientManagementSystem.Models;
namespace PatientManagementSystem.Helpers
{
    public class AutoMapperProfile : Profile
    {
        public AutoMapperProfile()
        {
            CreateMap<User, AuthResponseDto>();

            CreateMap<CreatePatientDto, Patient>();
            CreateMap<UpdatePatientDto, Patient>()
                .ForAllMembers(opts => opts.Condition((src, dest, srcMember) => srcMember != null));
            CreateMap<Patient, PatientResponseDto>();

            CreateMap<CreateAppointmentDto, Appointment>();
            CreateMap<Appointment, AppointmentResponseDto>()
                .ForMember(dest => dest.PatientName, opt =>
                    opt.MapFrom(src => $"{src.Patient.FirstName} {src.Patient.LastName}"))
                .ForMember(dest => dest.DoctorName, opt =>
                    opt.MapFrom(src => $"{src.Doctor.FirstName} {src.Doctor.LastName}"));

            CreateMap<CreateMedicalRecordDto, MedicalRecord>();
            CreateMap<CreateAppointmentDto, MedicalRecord>();
            CreateMap<MedicalRecord, MedicalRecordResponseDto>()
                .ForMember(dest => dest.PatientName, opt =>
                    opt.MapFrom(src => $"{src.Patient.FirstName} {src.Patient.LastName}"))
                .ForMember(dest => dest.DoctorName, opt =>
                    opt.MapFrom(src => src.Doctor != null ?
                        $"{src.Doctor.FirstName} {src.Doctor.LastName}" : null));
        }
    }
}
