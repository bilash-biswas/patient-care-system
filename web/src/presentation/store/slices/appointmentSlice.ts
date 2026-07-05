import { createSlice, createAsyncThunk, PayloadAction } from '@reduxjs/toolkit';
import { Appointment } from '@/domain/entities';
import { AppointmentRepository } from '@/data/repositories/AppointmentRepository';

const appointmentRepo = new AppointmentRepository();

interface AppointmentState {
  appointments: Appointment[];
  totalCount: number;
  isLoading: boolean;
  error: string | null;
}

const initialState: AppointmentState = {
  appointments: [],
  totalCount: 0,
  isLoading: false,
  error: null,
};

export const fetchAppointments = createAsyncThunk(
  'appointments/fetchAll',
  async (params: any) => {
    return await appointmentRepo.getAppointments(params);
  }
);

const appointmentSlice = createSlice({
  name: 'appointments',
  initialState,
  reducers: {},
  extraReducers: (builder) => {
    builder
      .addCase(fetchAppointments.pending, (state) => {
        state.isLoading = true;
      })
      .addCase(fetchAppointments.fulfilled, (state, action) => {
        state.isLoading = false;
        state.appointments = action.payload.data;
        state.totalCount = action.payload.totalCount;
      })
      .addCase(fetchAppointments.rejected, (state, action) => {
        state.isLoading = false;
        state.error = action.error.message || 'Failed to fetch appointments';
      });
  },
});

export default appointmentSlice.reducer;
