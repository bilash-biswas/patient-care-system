import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';
import { MedicalRecord } from '@/domain/entities';
import { MedicalRecordRepository } from '@/data/repositories/MedicalRecordRepository';

const repository = new MedicalRecordRepository();

interface MedicalRecordState {
  records: MedicalRecord[];
  totalCount: number;
  isLoading: boolean;
  error: string | null;
}

const initialState: MedicalRecordState = {
  records: [],
  totalCount: 0,
  isLoading: false,
  error: null,
};

export const fetchMedicalRecords = createAsyncThunk(
  'medicalRecords/fetchAll',
  async (filters: any = {}) => {
    return await repository.getRecords(filters);
  }
);

const medicalRecordSlice = createSlice({
  name: 'medicalRecords',
  initialState,
  reducers: {},
  extraReducers: (builder) => {
    builder
      .addCase(fetchMedicalRecords.pending, (state) => {
        state.isLoading = true;
        state.error = null;
      })
      .addCase(fetchMedicalRecords.fulfilled, (state, action) => {
        state.isLoading = false;
        state.records = action.payload.data;
        state.totalCount = action.payload.totalCount;
      })
      .addCase(fetchMedicalRecords.rejected, (state, action) => {
        state.isLoading = false;
        state.error = action.error.message || 'Failed to fetch medical records';
      });
  },
});

export default medicalRecordSlice.reducer;
