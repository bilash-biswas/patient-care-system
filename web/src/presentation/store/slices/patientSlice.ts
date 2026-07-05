import { createSlice, createAsyncThunk, PayloadAction } from '@reduxjs/toolkit';
import { Patient } from '@/domain/entities';
import { PatientRepository } from '@/data/repositories/PatientRepository';

const patientRepo = new PatientRepository();

interface PatientState {
  patients: Patient[];
  totalCount: number;
  selectedPatient: Patient | null;
  isLoading: boolean;
  error: string | null;
}

const initialState: PatientState = {
  patients: [],
  totalCount: 0,
  selectedPatient: null,
  isLoading: false,
  error: null,
};

export const fetchPatients = createAsyncThunk(
  'patients/fetchAll',
  async ({ search, page, pageSize }: { search?: string; page?: number; pageSize?: number }) => {
    return await patientRepo.getPatients(search, page, pageSize);
  }
);

const patientSlice = createSlice({
  name: 'patients',
  initialState,
  reducers: {
    setSelectedPatient: (state, action: PayloadAction<Patient | null>) => {
      state.selectedPatient = action.payload;
    },
  },
  extraReducers: (builder) => {
    builder
      .addCase(fetchPatients.pending, (state) => {
        state.isLoading = true;
      })
      .addCase(fetchPatients.fulfilled, (state, action) => {
        state.isLoading = false;
        state.patients = action.payload.data;
        state.totalCount = action.payload.totalCount;
      })
      .addCase(fetchPatients.rejected, (state, action) => {
        state.isLoading = false;
        state.error = action.error.message || 'Failed to fetch patients';
      });
  },
});

export const { setSelectedPatient } = patientSlice.actions;
export default patientSlice.reducer;
