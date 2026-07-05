import { Patient, Appointment, MedicalRecord } from '../entities';

export interface IPatientRepository {
  getPatients(search?: string, page?: number, pageSize?: number): Promise<{ data: Patient[]; totalCount: number }>;
  getPatientById(id: string): Promise<Patient>;
  createPatient(patient: Partial<Patient>): Promise<Patient>;
  updatePatient(id: string, patient: Partial<Patient>): Promise<Patient>;
  deletePatient(id: string): Promise<void>;
}

export interface IAppointmentRepository {
  getAppointments(filters?: any): Promise<{ data: Appointment[]; totalCount: number }>;
  getAppointmentById(id: string): Promise<Appointment>;
  createAppointment(appointment: any): Promise<Appointment>;
  updateStatus(id: string, status: string): Promise<void>;
}

export interface IMedicalRecordRepository {
  getRecords(filters?: any): Promise<{ data: MedicalRecord[]; totalCount: number }>;
  getRecordById(id: string): Promise<MedicalRecord>;
  createRecord(record: any): Promise<MedicalRecord>;
}
