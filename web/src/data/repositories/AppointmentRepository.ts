import api from '@/core/api';
import { Appointment } from '@/domain/entities';

export class AppointmentRepository {
  async getAppointments(params?: any) {
    const response = await api.get('/Appointments', { params });
    return {
      data: response.data.data,
      totalCount: response.data.pagination?.totalCount || response.data.data.length
    };
  }

  async getAppointmentById(id: string) {
    const response = await api.get(`/Appointments/${id}`);
    return response.data.data;
  }

  async createAppointment(appointment: Partial<Appointment>) {
    const response = await api.post('/Appointments', appointment);
    return response.data.data;
  }

  async updateStatus(id: string, status: string) {
    const response = await api.put(`/Appointments/${id}/status`, `"${status}"`, {
      headers: { 'Content-Type': 'application/json' }
    });
    return response.data;
  }

  async deleteAppointment(id: string) {
    await api.delete(`/Appointments/${id}`);
  }
}
