import api from '@/core/api';

export class PrescriptionRepository {
  async getPrescriptions(params?: { medicalRecordId?: string; patientId?: string }) {
    const response = await api.get('/Prescriptions', { params });
    return response.data.data;
  }

  async requestRefill(prescriptionId: string) {
    const response = await api.post('/Prescriptions/refill', JSON.stringify(prescriptionId), {
      headers: { 'Content-Type': 'application/json' }
    });
    return response.data.data;
  }

  async getRefillRequests() {
    const response = await api.get('/Prescriptions/refills');
    return response.data.data;
  }
}
