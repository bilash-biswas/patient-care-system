import api from '@/core/api';
import { IMedicalRecordRepository } from '@/domain/repositories';
import { MedicalRecord } from '@/domain/entities';

export class MedicalRecordRepository implements IMedicalRecordRepository {
  async getRecords(filters?: any) {
    const response = await api.get('/MedicalRecords', {
      params: filters
    });
    return {
      data: response.data.data,
      totalCount: response.data.pagination?.totalCount || response.data.data.length
    };
  }

  async getRecordById(id: string) {
    const response = await api.get(`/MedicalRecords/${id}`);
    return response.data.data;
  }

  async createRecord(record: any) {
    const response = await api.post('/MedicalRecords', record);
    return response.data.data;
  }
}
