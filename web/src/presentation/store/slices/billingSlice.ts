import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';
import { Invoice } from '@/domain/entities';
import { BillingRepository } from '@/data/repositories/BillingRepository';

const repository = new BillingRepository();

interface BillingState {
  invoices: Invoice[];
  isLoading: boolean;
  error: string | null;
}

const initialState: BillingState = {
  invoices: [],
  isLoading: false,
  error: null,
};

export const fetchInvoices = createAsyncThunk(
  'billing/fetchInvoices',
  async (params?: { patientId?: string }) => {
    return await repository.getInvoices(params);
  }
);

const billingSlice = createSlice({
  name: 'billing',
  initialState,
  reducers: {},
  extraReducers: (builder) => {
    builder
      .addCase(fetchInvoices.pending, (state) => {
        state.isLoading = true;
        state.error = null;
      })
      .addCase(fetchInvoices.fulfilled, (state, action) => {
        state.isLoading = false;
        state.invoices = action.payload;
      })
      .addCase(fetchInvoices.rejected, (state, action) => {
        state.isLoading = false;
        state.error = action.error.message || 'Failed to fetch invoices';
      });
  },
});

export default billingSlice.reducer;
