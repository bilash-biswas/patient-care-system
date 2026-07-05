import { configureStore } from '@reduxjs/toolkit';
import authReducer from './slices/authSlice';
import patientReducer from './slices/patientSlice';
import appointmentReducer from './slices/appointmentSlice';
import medicalRecordReducer from './slices/medicalRecordSlice';
import prescriptionReducer from './slices/prescriptionSlice';
import billingReducer from './slices/billingSlice';
import chatReducer from './slices/chatSlice';

export const store = configureStore({
  reducer: {
    auth: authReducer,
    patients: patientReducer,
    appointments: appointmentReducer,
    medicalRecords: medicalRecordReducer,
    prescriptions: prescriptionReducer,
    billing: billingReducer,
    chat: chatReducer,
  },
});

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;
