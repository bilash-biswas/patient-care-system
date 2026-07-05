'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { useAppSelector, useAppDispatch } from '@/presentation/store/hooks';
import { fetchPatients } from '@/presentation/store/slices/patientSlice';
import { fetchAppointments } from '@/presentation/store/slices/appointmentSlice';
import { fetchPrescriptions } from '@/presentation/store/slices/prescriptionSlice';
import { fetchInvoices } from '@/presentation/store/slices/billingSlice';
import { AdminDashboard } from '@/presentation/components/dashboard/AdminDashboard';
import { DoctorDashboard } from '@/presentation/components/dashboard/DoctorDashboard';
import { PatientDashboard } from '@/presentation/components/dashboard/PatientDashboard';
import { NurseDashboard } from '@/presentation/components/dashboard/NurseDashboard';

export default function DashboardPage() {
  const router = useRouter();
  const dispatch = useAppDispatch();
  const { user } = useAppSelector((state) => state.auth);
  const { totalCount: patientCount, isLoading: isPatientsLoading } = useAppSelector((state) => state.patients);
  const { totalCount: appointmentCount, appointments, isLoading: isApptsLoading } = useAppSelector((state) => state.appointments);
  const { prescriptions, isLoading: isPresLoading } = useAppSelector((state) => state.prescriptions);
  const { invoices, isLoading: isBillsLoading } = useAppSelector((state) => state.billing);
  const [adminStats, setAdminStats] = useState<any>(null);
  const [isAdminStatsLoading, setIsAdminStatsLoading] = useState(false);

  const isLoading = user?.role === 'Admin'
    ? isBillsLoading || isAdminStatsLoading
    : user?.role === 'Doctor' || user?.role === 'Nurse'
      ? isPatientsLoading || isApptsLoading
      : isPatientsLoading || isApptsLoading || isPresLoading || isBillsLoading;

  useEffect(() => {
    dispatch(fetchPatients({ page: 1, pageSize: 1 }));
    
    if (user?.role === 'Patient' && user.id) {
      dispatch(fetchAppointments({ patientId: user.id, status: 'Scheduled', page: 1, pageSize: 5 }));
      dispatch(fetchPrescriptions({ patientId: user.id }));
      dispatch(fetchInvoices({ patientId: user.id }));
    } else if (user?.role === 'Doctor' || user?.role === 'Nurse') {
      dispatch(fetchAppointments({ status: 'Scheduled', page: 1, pageSize: 5 }));
    } else if (user?.role === 'Admin') {
      dispatch(fetchInvoices({})); 
      
      const fetchAdminStats = async () => {
        setIsAdminStatsLoading(true);
        try {
          const api = (await import('@/core/api')).default;
          const res = await api.get('/admin/stats');
          setAdminStats(res.data.data);
        } catch (e) {
          console.error("Error fetching admin stats:", e);
        } finally {
          setIsAdminStatsLoading(false);
        }
      };
      fetchAdminStats();
    }
  }, [dispatch, user]);

  const getWelcomeMessage = () => {
    if (user?.role === 'Doctor') return `Welcome back, Dr. ${user.lastName || 'Doctor'}`;
    if (user?.role === 'Patient') return `Welcome back, ${user.firstName || 'Patient'}`;
    if (user?.role === 'Nurse') return `Welcome back, Nurse ${user.lastName || 'Nurse'}`;
    return `Welcome back, ${user?.firstName || 'Administrator'}`;
  };

  const renderDashboard = () => {
    if (isLoading) {
      return (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
          {[1, 2, 3, 4].map((i) => (
            <div key={i} className="animate-shimmer h-32 rounded-2xl bg-gray-100 dark:bg-gray-800/50" />
          ))}
        </div>
      );
    }

    switch (user?.role) {
      case 'Admin':
        return <AdminDashboard stats={adminStats} invoices={invoices} />;
      case 'Doctor':
        return <DoctorDashboard appointments={appointments} patientCount={patientCount} router={router} />;
      case 'Patient':
        return <PatientDashboard appointments={appointments} prescriptions={prescriptions} invoices={invoices} router={router} />;
      case 'Nurse':
        return <NurseDashboard appointments={appointments} patientCount={patientCount} router={router} />;
      default:
        return (
          <div className="p-12 text-center card bg-gray-50 dark:bg-gray-800/30">
            <p className="text-gray-500 italic">Welcome to the system. No specific dashboard configured for your role: {user?.role}</p>
          </div>
        );
    }
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-black text-gray-900 dark:text-white tracking-tight">
          {getWelcomeMessage()}
        </h1>
        <p className="text-gray-500 mt-1 font-medium italic opacity-70">
          {user?.role === 'Admin' ? 'System administration and performance monitoring.' : 
           user?.role === 'Doctor' ? "Here's your clinical schedule for today." :
           "Your personalized health overview and upcoming care."}
        </p>
      </div>

      {renderDashboard()}
    </div>
  );
}
