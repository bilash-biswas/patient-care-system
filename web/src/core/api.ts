import axios from 'axios';

const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:5278/api';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request Interceptor
api.interceptors.request.use(
  (config) => {
    if (typeof window !== 'undefined') {
      const token = localStorage.getItem('token');
      if (token) {
        config.headers.Authorization = `Bearer ${token}`;
      }
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Response Interceptor
api.interceptors.response.use(
  (response) => response,
  async (error) => {
    if (error.response?.status === 401) {
      if (typeof window !== 'undefined') {
        localStorage.removeItem('token');
        // Optional: Redirect to login or refresh token
      }
    }
    return Promise.reject(error);
  }
);

// API Helper Methods

export const authApi = {
  register: (data: any) => api.post('/Auth/register', data),
  login: (data: any) => api.post('/Auth/login', data),
  refreshToken: (data: any) => api.post('/Auth/refresh-token', data),
  revokeToken: (data: any) => api.post('/Auth/revoke-token', data),
  getMe: () => api.get('/Auth/me'),
  getHealth: () => api.get('/Auth/health'),
};

export const patientApi = {
  getAll: (search?: string, page = 1) => 
    api.get(`/Patients?search=${search || ''}&page=${page}`),
  getById: (id: string) => api.get(`/Patients/${id}`),
  create: (data: any) => api.post('/Patients', data),
  update: (id: string, data: any) => api.put(`/Patients/${id}`, data),
  delete: (id: string) => api.delete(`/Patients/${id}`),
  getRecords: (id: string) => api.get(`/Patients/${id}/medical-records`),
  getAppointments: (id: string) => api.get(`/Patients/${id}/appointments`),
  getMe: () => api.get('/Patients/me'),
};

export const appointmentApi = {
  getAll: (params?: any) => api.get('/Appointments', { params }),
  getById: (id: string) => api.get(`/Appointments/${id}`),
  create: (data: any) => api.post('/Appointments', data),
  updateStatus: (id: string, status: string) => api.put(`/Appointments/${id}/status`, `"${status}"`, {
    headers: { 'Content-Type': 'application/json' }
  }),
  delete: (id: string) => api.delete(`/Appointments/${id}`),
  getCalendarUrl: (id: string) => `${API_BASE_URL}/Appointments/${id}/calendar`,
};

export const billingApi = {
  getInvoices: (params?: any) => api.get('/Billing/invoices', { params }),
  getInvoiceById: (id: string) => api.get(`/Billing/invoices/${id}`),
  payInvoice: (id: string, data: any) => api.post(`/Billing/invoices/${id}/pay`, data),
};

export const chatApi = {
  getDirectory: (params?: any) => api.get('/chat/directory', { params }),
  getMessages: (otherUserId: string, params?: any) => api.get(`/chat/messages/${otherUserId}`, { params }),
  getConversations: () => api.get('/chat/conversations'),
};

export const medicalRecordApi = {
  getAll: (params?: any) => api.get('/MedicalRecords', { params }),
  getById: (id: string) => api.get(`/MedicalRecords/${id}`),
  create: (data: any) => api.post('/MedicalRecords', data),
  update: (id: string, data: any) => api.put(`/MedicalRecords/${id}`, data),
  delete: (id: string) => api.delete(`/MedicalRecords/${id}`),
};

export const nurseApi = {
  getAll: (params?: any) => api.get('/Nurses', { params }),
  getById: (id: string) => api.get(`/Nurses/${id}`),
};

export const prescriptionApi = {
  getAll: (params?: any) => api.get('/Prescriptions', { params }),
  getById: (id: string) => api.get(`/Prescriptions/${id}`),
  create: (data: any) => api.post('/Prescriptions', data),
  requestRefill: (id: string) => api.post(`/Prescriptions/${id}/refill`),
  getRefills: (params?: any) => api.get('/Prescriptions/refills', { params }),
};

export const adminApi = {
  getUsers: (params?: any) => api.get('/admin/users', { params }),
  getStats: () => api.get('/admin/stats'),
};

export default api;
