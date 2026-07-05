import api from '@/core/api';
import { IPatientRepository } from '@/domain/repositories';
import { Patient } from '@/domain/entities';

export class PatientRepository implements IPatientRepository {
  async getPatients(search?: string, page = 1, pageSize = 20) {
    const response = await api.get('/Patients', {
      params: { search, page, pageSize }
    });
    return {
      data: response.data.data,
      totalCount: response.data.pagination.totalCount
    };
  }

  async getPatientById(id: string) {
    const response = await api.get(`/Patients/${id}`);
    return response.data.data;
  }

  async createPatient(patient: Partial<Patient>) {
    const response = await api.post('/Patients', patient);
    return response.data.data;
  }

  async updatePatient(id: string, patient: Partial<Patient>) {
    const response = await api.put(`/Patients/${id}`, patient);
    return response.data.data;
  }

  async deletePatient(id: string) {
    await api.delete(`/Patients/${id}`);
  }
}
