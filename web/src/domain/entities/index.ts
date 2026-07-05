export interface User {
  id: string;
  email: string;
  username: string;
  firstName: string;
  lastName: string;
  role: 'Admin' | 'Doctor' | 'Nurse' | 'Patient';
  isActive: boolean;
}

export interface Patient {
  id: string;
  userId?: string;
  firstName: string;
  lastName: string;
  gender: string;
  dateOfBirth: string;
  bloodGroup: string;
  address: string;
  emergencyContactName?: string;
  emergencyContactPhone?: string;
  insuranceProvider?: string;
  insurancePolicyNumber?: string;
  phone?: string;
  createdAt: string;
}

export interface Appointment {
  id: string;
  patientId: string;
  doctorId: string;
  patientName?: string;
  doctorName?: string;
  appointmentDate: string;
  startTime: string;
  endTime: string;
  reason: string;
  status: 'Scheduled' | 'Completed' | 'Cancelled' | 'NoShow' | 'PendingPayment';
  notes?: string;
}

export interface MedicalRecord {
  id: string;
  patientId: string;
  doctorId: string;
  patientName?: string;
  doctorName?: string;
  diagnosis: string;
  symptoms: string;
  treatment: string;
  prescription?: string;
  visitDate: string;
  nextVisitDate?: string;
  recordType: string;
  createdAt: string;
}

export interface Prescription {
  id: string;
  medicalRecordId: string;
  medicationName: string;
  dosage: string;
  frequency: string;
  duration: string;
  instructions?: string;
  createdAt: string;
}

export interface RefillRequest {
  id: string;
  prescriptionId: string;
  patientId: string;
  status: 'Pending' | 'Approved' | 'Rejected';
  requestDate: string;
}

export interface Invoice {
  id: string;
  patientId: string;
  appointmentId?: string;
  amount: number;
  currency: string;
  status: 'Unpaid' | 'Paid' | 'Cancelled';
  dueDate: string;
  paidAt?: string;
  stripePaymentIntentId?: string;
}

export interface Message {
  id: string;
  senderId: string;
  receiverId: string;
  content: string;
  sentAt: string;
  isRead: boolean;
}
