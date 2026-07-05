import api from '@/core/api';

export class BillingRepository {
  async getInvoices(params?: { patientId?: string }) {
    const response = await api.get('/billing/invoices', { params });
    return response.data.data;
  }

  async getInvoiceById(id: string) {
    const response = await api.get(`/billing/invoices/${id}`);
    return response.data.data;
  }

  async createPaymentIntent(invoiceId: string) {
    const response = await api.post(`/billing/invoices/${invoiceId}/pay`);
    return response.data.data; // This returns the clientSecret
  }
}
