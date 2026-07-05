import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';
import { Prescription, RefillRequest } from '@/domain/entities';
import { PrescriptionRepository } from '@/data/repositories/PrescriptionRepository';

const repository = new PrescriptionRepository();

interface PrescriptionState {
  prescriptions: Prescription[];
  refillRequests: RefillRequest[];
  isLoading: boolean;
  error: string | null;
}

const initialState: PrescriptionState = {
  prescriptions: [],
  refillRequests: [],
  isLoading: false,
  error: null,
};

export const fetchPrescriptions = createAsyncThunk(
  'prescriptions/fetchAll',
  async (params?: { medicalRecordId?: string; patientId?: string }) => {
    return await repository.getPrescriptions(params);
  }
);

export const requestRefill = createAsyncThunk(
  'prescriptions/requestRefill',
  async (prescriptionId: string) => {
    return await repository.requestRefill(prescriptionId);
  }
);

const prescriptionSlice = createSlice({
  name: 'prescriptions',
  initialState,
  reducers: {},
  extraReducers: (builder) => {
    builder
      .addCase(fetchPrescriptions.pending, (state) => {
        state.isLoading = true;
        state.error = null;
      })
      .addCase(fetchPrescriptions.fulfilled, (state, action) => {
        state.isLoading = false;
        state.prescriptions = action.payload;
      })
      .addCase(fetchPrescriptions.rejected, (state, action) => {
        state.isLoading = false;
        state.error = action.error.message || 'Failed to fetch prescriptions';
      })
      .addCase(requestRefill.fulfilled, (state, action) => {
        state.refillRequests.unshift(action.payload);
      });
  },
});

export default prescriptionSlice.reducer;
