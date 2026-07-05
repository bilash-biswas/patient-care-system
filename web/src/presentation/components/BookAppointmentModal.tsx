'use client';

import React, { useEffect, useState } from 'react';
import { Card } from '@/presentation/components/Card';
import { Button } from '@/presentation/components/Button';
import { X, Calendar, Clock, User, MessageSquare, AlertCircle, Sparkles } from 'lucide-react';
import { useRouter } from 'next/navigation';
import { AppointmentRepository } from '@/data/repositories/AppointmentRepository';

interface BookAppointmentModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSuccess: () => void;
  currentUser: any;
  initialDoctorId?: string;
}

const appointmentRepo = new AppointmentRepository();

export const BookAppointmentModal = ({ isOpen, onClose, onSuccess, currentUser, initialDoctorId }: BookAppointmentModalProps) => {
  const router = useRouter();
  const [doctors, setDoctors] = useState<any[]>([]);
  const [patients, setPatients] = useState<any[]>([]);
  const [loading, setLoading] = useState(false);
  const [fetchingData, setFetchingData] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Form State
  const [doctorId, setDoctorId] = useState('');
  const [patientId, setPatientId] = useState('');
  const [appointmentDate, setAppointmentDate] = useState('');
  const [startTime, setStartTime] = useState('09:00');
  const [endTime, setEndTime] = useState('09:30');
  const [reason, setReason] = useState('');
  const [notes, setNotes] = useState('');

  const isPatient = currentUser?.role === 'Patient';

  useEffect(() => {
    if (!isOpen) return;

    setDoctorId(initialDoctorId || '');

    const loadData = async () => {
      setFetchingData(true);
      setError(null);
      try {
        const api = (await import('@/core/api')).default;
        
        // Fetch all Doctors
        const doctorsRes = await api.get('/chat/directory?role=Doctor');
        setDoctors(doctorsRes.data.data || []);

        // Fetch Patients if Admin, Doctor, or Nurse
        if (!isPatient) {
          const patientsRes = await api.get('/Patients?pageSize=100');
          setPatients(patientsRes.data.data || []);
        }
      } catch (err) {
        console.error('Error fetching modal metadata:', err);
        setError('Failed to load doctors or patients lists. Please check connection.');
      } finally {
        setFetchingData(false);
      }
    };

    loadData();
  }, [isOpen, isPatient]);

  if (!isOpen) return null;

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);

    // Basic Validations
    if (!doctorId) {
      setError('Please select a doctor.');
      return;
    }
    if (!isPatient && !patientId) {
      setError('Please select a patient.');
      return;
    }
    if (!appointmentDate) {
      setError('Please select a date.');
      return;
    }
    if (!startTime || !endTime) {
      setError('Please select a valid start and end time.');
      return;
    }

    const startMinutes = parseInt(startTime.split(':')[0]) * 60 + parseInt(startTime.split(':')[1]);
    const endMinutes = parseInt(endTime.split(':')[0]) * 60 + parseInt(endTime.split(':')[1]);

    if (startMinutes >= endMinutes) {
      setError('Start time must be strictly before end time.');
      return;
    }

    // Check date (must not be in the past)
    const selectedDate = new Date(appointmentDate);
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    if (selectedDate < today) {
      setError('Appointment date cannot be in the past.');
      return;
    }

    setLoading(true);
    try {
      // Format Start/End Time to TimeSpan string (hh:mm:ss)
      const formattedStartTime = `${startTime}:00`;
      const formattedEndTime = `${endTime}:00`;

      await appointmentRepo.createAppointment({
        doctorId,
        patientId: isPatient ? undefined : patientId, // Backend automatically maps patient's ID if role is Patient
        appointmentDate,
        startTime: formattedStartTime,
        endTime: formattedEndTime,
        reason,
        notes: notes || undefined
      });

      onSuccess();
      onClose();

      if (isPatient) {
        alert('Appointment requested successfully! Please complete your payment on the billing page to confirm your booking.');
        router.push('/billing');
      } else {
        alert('Appointment booked successfully!');
      }
    } catch (err: any) {
      console.error('Error booking appointment:', err);
      setError(err?.response?.data?.message || 'Failed to book appointment. Doctor may be unavailable.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      {/* Backdrop */}
      <div 
        className="absolute inset-0 bg-slate-900/40 backdrop-blur-md transition-opacity duration-300" 
        onClick={onClose} 
      />

      {/* Modal Content */}
      {/* Modal Content */}
      <Card className="relative w-full max-w-lg bg-white/90 dark:bg-slate-950/90 border border-secondary-200/40 dark:border-slate-805/40 shadow-2xl rounded-3xl overflow-hidden z-10 max-h-[90vh] flex flex-col transition-all transform scale-100 animate-scaleIn duration-350 p-0">
        
        {/* Header */}
        <div className="p-6 bg-gradient-to-br from-primary-650 via-primary-750 to-teal-850 text-white relative">
          <div className="absolute top-[-40%] left-[-20%] w-[60%] h-[150%] rounded-full bg-teal-500/10 blur-2xl pointer-events-none" />
          
          <div className="flex items-center justify-between z-10 relative">
            <div className="flex items-center space-x-3">
              <div className="p-2.5 bg-white/10 border border-white/20 rounded-2xl">
                <Sparkles className="w-5 h-5 text-teal-350" />
              </div>
              <div>
                <h3 className="text-lg font-black tracking-tight leading-none">Schedule Appointment</h3>
                <p className="text-[10px] text-white/80 font-bold uppercase tracking-wider mt-1.5">Book real-time clinical care</p>
              </div>
            </div>
            <button 
              onClick={onClose} 
              className="p-1.5 rounded-xl bg-white/10 hover:bg-white/20 transition-all text-white/80 hover:text-white cursor-pointer"
            >
              <X className="w-5 h-5" />
            </button>
          </div>
        </div>

        {/* Scrollable Form */}
        <form onSubmit={handleSubmit} className="flex-1 overflow-y-auto p-6 space-y-5">
          {error && (
            <div className="p-4 bg-rose-50 dark:bg-rose-950/30 border border-rose-100 dark:border-rose-900/50 rounded-2xl flex items-start space-x-3 text-rose-700 dark:text-rose-450 shadow-inner">
              <AlertCircle className="w-5 h-5 mt-0.5 shrink-0 text-rose-500" />
              <p className="text-xs font-bold leading-relaxed">{error}</p>
            </div>
          )}

          {fetchingData ? (
            <div className="py-12 flex flex-col items-center justify-center space-y-3">
              <div className="w-8 h-8 border-4 border-primary-500 border-t-transparent rounded-full animate-spin" />
              <p className="text-xs text-secondary-500 font-semibold italic">Fetching latest providers and schedulers...</p>
            </div>
          ) : (
            <>
              {/* Patient Selection (For Admin/Doctor/Nurse) */}
              {!isPatient && (
                <div>
                  <label className="block text-[10px] font-black text-secondary-400 dark:text-secondary-500 uppercase tracking-widest mb-2">
                    Select Patient
                  </label>
                  <div className="relative group">
                    <User className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-secondary-400 group-focus-within:text-primary-555 transition-colors" />
                    <select
                      value={patientId}
                      onChange={(e) => setPatientId(e.target.value)}
                      required
                      className="w-full bg-secondary-50/50 dark:bg-slate-900/35 pl-11 pr-4 py-3 rounded-2xl text-xs focus:outline-none focus:ring-2 focus:ring-primary-500/10 border border-secondary-200/60 dark:border-slate-805/65 focus:border-primary-500 dark:text-white placeholder-secondary-400 font-semibold transition-all appearance-none cursor-pointer"
                    >
                      <option value="">Choose a Patient...</option>
                      {patients.map((p) => (
                        <option key={p.id} value={p.id}>
                          {p.firstName} {p.lastName} (ID: #{p.id.slice(0, 6).toUpperCase()})
                        </option>
                      ))}
                    </select>
                  </div>
                </div>
              )}

              {/* Doctor Selection */}
              <div>
                <label className="block text-[10px] font-black text-secondary-400 dark:text-secondary-500 uppercase tracking-widest mb-2">
                  Select Doctor
                </label>
                <div className="relative group">
                  <User className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-secondary-400 group-focus-within:text-primary-555 transition-colors" />
                  <select
                    value={doctorId}
                    onChange={(e) => setDoctorId(e.target.value)}
                    required
                    className="w-full bg-secondary-50/50 dark:bg-slate-900/35 pl-11 pr-4 py-3 rounded-2xl text-xs focus:outline-none focus:ring-2 focus:ring-primary-500/10 border border-secondary-200/60 dark:border-slate-805/65 focus:border-primary-500 dark:text-white placeholder-secondary-400 font-semibold transition-all appearance-none cursor-pointer"
                  >
                    <option value="">Choose a Doctor...</option>
                    {doctors.map((d) => (
                      <option key={d.id} value={d.id}>
                        Dr. {d.firstName} {d.lastName}
                      </option>
                    ))}
                  </select>
                </div>
              </div>

              {/* Appointment Date */}
              <div>
                <label className="block text-[10px] font-black text-secondary-400 dark:text-secondary-500 uppercase tracking-widest mb-2">
                  Appointment Date
                </label>
                <div className="relative group">
                  <Calendar className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-secondary-400 group-focus-within:text-primary-555 transition-colors" />
                  <input
                    type="date"
                    value={appointmentDate}
                    min={new Date().toISOString().split('T')[0]}
                    onChange={(e) => setAppointmentDate(e.target.value)}
                    required
                    className="w-full bg-secondary-50/50 dark:bg-slate-900/35 pl-11 pr-4 py-3 rounded-2xl text-xs focus:outline-none focus:ring-2 focus:ring-primary-500/10 border border-secondary-200/60 dark:border-slate-805/65 focus:border-primary-500 dark:text-white placeholder-secondary-400 font-semibold transition-all cursor-pointer"
                  />
                </div>
              </div>

              {/* Times: Start and End Grid */}
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-[10px] font-black text-secondary-400 dark:text-secondary-500 uppercase tracking-widest mb-2">
                    Start Time
                  </label>
                  <div className="relative group">
                    <Clock className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-secondary-400 group-focus-within:text-primary-555 transition-colors" />
                    <input
                      type="time"
                      value={startTime}
                      onChange={(e) => setStartTime(e.target.value)}
                      required
                      className="w-full bg-secondary-50/50 dark:bg-slate-900/35 pl-11 pr-4 py-3 rounded-2xl text-xs focus:outline-none focus:ring-2 focus:ring-primary-500/10 border border-secondary-200/60 dark:border-slate-805/65 focus:border-primary-500 dark:text-white placeholder-secondary-400 font-semibold transition-all cursor-pointer"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-[10px] font-black text-secondary-400 dark:text-secondary-500 uppercase tracking-widest mb-2">
                    End Time
                  </label>
                  <div className="relative group">
                    <Clock className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-secondary-400 group-focus-within:text-primary-555 transition-colors" />
                    <input
                      type="time"
                      value={endTime}
                      onChange={(e) => setEndTime(e.target.value)}
                      required
                      className="w-full bg-secondary-50/50 dark:bg-slate-900/35 pl-11 pr-4 py-3 rounded-2xl text-xs focus:outline-none focus:ring-2 focus:ring-primary-500/10 border border-secondary-200/60 dark:border-slate-805/65 focus:border-primary-500 dark:text-white placeholder-secondary-400 font-semibold transition-all cursor-pointer"
                    />
                  </div>
                </div>
              </div>

              {/* Reason for Visit */}
              <div>
                <label className="block text-[10px] font-black text-secondary-400 dark:text-secondary-500 uppercase tracking-widest mb-2">
                  Reason for Visit
                </label>
                <div className="relative group">
                  <MessageSquare className="absolute left-4 top-3.5 w-4 h-4 text-secondary-400 group-focus-within:text-primary-555 transition-colors" />
                  <textarea
                    rows={2}
                    value={reason}
                    onChange={(e) => setReason(e.target.value)}
                    required
                    placeholder="e.g. Annual Checkup, Dental consult..."
                    className="w-full bg-secondary-50/50 dark:bg-slate-900/35 pl-11 pr-4 py-3 rounded-2xl text-xs focus:outline-none focus:ring-2 focus:ring-primary-500/10 border border-secondary-200/60 dark:border-slate-805/65 focus:border-primary-500 dark:text-white placeholder-secondary-400 font-semibold transition-all resize-none"
                  />
                </div>
              </div>

              {/* Notes */}
              <div>
                <label className="block text-[10px] font-black text-secondary-400 dark:text-secondary-500 uppercase tracking-widest mb-2">
                  Notes / Symptoms
                </label>
                <textarea
                  rows={2}
                  value={notes}
                  onChange={(e) => setNotes(e.target.value)}
                  placeholder="Optional details, clinical histories, or descriptions..."
                  className="w-full bg-secondary-50/50 dark:bg-slate-900/35 px-4 py-3 rounded-2xl text-xs focus:outline-none focus:ring-2 focus:ring-primary-500/10 border border-secondary-200/60 dark:border-slate-805/65 focus:border-primary-500 dark:text-white placeholder-secondary-400 font-semibold transition-all resize-none"
                />
              </div>

              {/* Submit Buttons */}
              <div className="pt-2 flex space-x-3.5">
                <Button
                  type="button"
                  variant="ghost"
                  onClick={onClose}
                  className="flex-1 py-3 rounded-2xl text-xs font-bold border border-secondary-250 dark:border-slate-800 hover:bg-secondary-50 dark:hover:bg-slate-900 text-secondary-600 dark:text-secondary-400 cursor-pointer"
                >
                  Cancel
                </Button>
                <Button
                  type="submit"
                  isLoading={loading}
                  className="flex-1 py-3 rounded-2xl bg-gradient-to-r from-primary-600 to-primary-700 hover:from-primary-500 hover:to-primary-600 text-xs font-extrabold text-white shadow-lg shadow-primary-600/15 hover:scale-[1.01] transition-all cursor-pointer"
                >
                  Confirm Booking
                </Button>
              </div>
            </>
          )}
        </form>
      </Card>
    </div>
  );
};
