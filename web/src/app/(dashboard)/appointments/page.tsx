'use client';

import React, { useEffect, useState } from 'react';
import { AppointmentList } from '@/presentation/components/AppointmentList';
import { useAppDispatch, useAppSelector } from '@/presentation/store/hooks';
import { fetchAppointments } from '@/presentation/store/slices/appointmentSlice';
import { Button } from '@/presentation/components/Button';
import { Plus } from 'lucide-react';
import { AppointmentRepository } from '@/data/repositories/AppointmentRepository';
import { BookAppointmentModal } from '@/presentation/components/BookAppointmentModal';

const appointmentRepo = new AppointmentRepository();

export default function AppointmentsPage() {
  const dispatch = useAppDispatch();
  const { appointments, isLoading } = useAppSelector((state) => state.appointments);
  const { user } = useAppSelector((state) => state.auth);
  const [filter, setFilter] = useState('All');
  const [isModalOpen, setIsModalOpen] = useState(false);

  useEffect(() => {
    dispatch(fetchAppointments(filter === 'All' ? {} : { status: filter }));
  }, [dispatch, filter]);

  const handleStatusUpdate = async (id: string, status: string) => {
    try {
      await appointmentRepo.updateStatus(id, status);
      dispatch(fetchAppointments(filter === 'All' ? {} : { status: filter }));
    } catch (err) {
      alert('Failed to update status');
    }
  };

  const statusFilters = ['All', 'Scheduled', 'Completed', 'Cancelled', 'NoShow'];

  return (
    <div className="space-y-8">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-3xl font-bold text-secondary-900">Appointments</h1>
          <p className="text-secondary-500 mt-2">View and manage the clinic schedule.</p>
        </div>
        <Button 
          variant="primary" 
          size="lg" 
          className="rounded-2xl shadow-primary-500/20"
          onClick={() => setIsModalOpen(true)}
        >
          <Plus className="w-5 h-5 mr-2" />
          Book Appointment
        </Button>
      </div>

      <div className="flex items-center space-x-2 overflow-x-auto pb-2 scrollbar-hide">
        <div className="p-1 bg-secondary-100 rounded-2xl flex">
          {statusFilters.map((s) => (
            <button
              key={s}
              onClick={() => setFilter(s)}
              className={`px-6 py-2 rounded-xl text-sm font-bold transition-all ${
                filter === s 
                  ? 'bg-white text-primary-600 shadow-sm' 
                  : 'text-secondary-500 hover:text-secondary-900'
              }`}
            >
              {s}
            </button>
          ))}
        </div>
      </div>

      <AppointmentList
        appointments={appointments}
        isLoading={isLoading}
        onStatusUpdate={handleStatusUpdate}
      />

      <BookAppointmentModal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        onSuccess={() => dispatch(fetchAppointments(filter === 'All' ? {} : { status: filter }))}
        currentUser={user}
      />
    </div>
  );
}
