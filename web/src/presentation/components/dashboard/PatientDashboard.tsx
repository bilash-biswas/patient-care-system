'use client';

import { Card } from '@/presentation/components/Card';
import { Calendar, Pill, CreditCard, Activity, Bell, ChevronRight, FileText, Users } from 'lucide-react';
import { Button } from '@/presentation/components/Button';

const formatTimeTo12Hour = (time24: string) => {
  if (!time24) return '';
  const [hoursStr, minutesStr] = time24.split(':');
  const hours = parseInt(hoursStr, 10);
  if (isNaN(hours)) return time24;
  const ampm = hours >= 12 ? 'PM' : 'AM';
  const hours12 = hours % 12 || 12;
  return `${hours12}:${minutesStr} ${ampm}`;
};

export const PatientDashboard = ({ appointments, prescriptions, invoices, router }: any) => {
  const activeMeds = prescriptions?.filter((p: any) => p.status === 'Active').length || 0;
  const pendingBills = invoices?.filter((i: any) => i.status === 'Unpaid').length || 0;

  const patientStats = [
    { label: 'Upcoming', value: appointments.length > 0 ? '1' : '0', icon: Calendar, color: 'text-sky-600 dark:text-sky-400', bg: 'bg-sky-50 dark:bg-sky-950/20', gradient: 'from-sky-500/10 to-blue-500/5' },
    { label: 'Active Meds', value: activeMeds.toString(), icon: Pill, color: 'text-emerald-600 dark:text-emerald-400', bg: 'bg-emerald-50 dark:bg-emerald-950/20', gradient: 'from-emerald-500/10 to-teal-500/5' },
    { label: 'Pending Bills', value: pendingBills.toString(), icon: CreditCard, color: 'text-amber-600 dark:text-amber-400', bg: 'bg-amber-50 dark:bg-amber-950/20', gradient: 'from-amber-500/10 to-orange-500/5' },
    { label: 'Health Score', value: '88', icon: Activity, color: 'text-violet-600 dark:text-violet-400', bg: 'bg-violet-50 dark:bg-violet-950/20', gradient: 'from-violet-500/10 to-indigo-500/5' },
  ];

  const nextAppt = appointments[0];

  return (
    <div className="space-y-8">
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {patientStats.map((stat) => (
          <Card key={stat.label} className={`p-6 border-none shadow-sm hover:shadow-xl hover:-translate-y-1 transition-all duration-300 bg-gradient-to-br ${stat.gradient} relative overflow-hidden group`}>
            <stat.icon className="absolute -right-6 -bottom-6 w-28 h-28 opacity-5 text-secondary-500 group-hover:scale-110 transition-transform duration-300" />
            <div className="flex items-center space-x-4 relative z-10">
              <div className={`p-3 rounded-2xl ${stat.bg} ${stat.color} shadow-sm`}>
                <stat.icon className="w-6 h-6" />
              </div>
              <div>
                <p className="text-[11px] font-black text-secondary-500 dark:text-secondary-400 uppercase tracking-widest">{stat.label}</p>
                <p className="text-3xl font-black text-secondary-900 dark:text-white mt-1 tracking-tight">{stat.value}</p>
              </div>
            </div>
          </Card>
        ))}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <div className="lg:col-span-2 space-y-8">
          {/* Featured Next Appointment */}
          {nextAppt ? (
            <Card className="p-0 border-none shadow-xl bg-gradient-to-br from-primary-600 via-primary-750 to-teal-800 text-white overflow-hidden relative rounded-3xl">
              <Calendar className="absolute -right-4 -bottom-4 w-48 h-48 opacity-10" />
              <div className="p-8 relative z-10">
                <p className="text-primary-100/80 text-xs font-black uppercase tracking-widest mb-2">Upcoming Consultation</p>
                <h3 className="text-3xl font-black mb-6 tracking-tight">
                  {new Date(nextAppt.appointmentDate).toLocaleDateString('en-US', { month: 'long', day: 'numeric' })} at {formatTimeTo12Hour(nextAppt.startTime)}
                </h3>
                <div className="flex flex-wrap items-center gap-6">
                   <div className="flex items-center bg-white/10 px-4 py-2 rounded-xl backdrop-blur-sm border border-white/5">
                     <Activity className="w-4 h-4 text-white mr-2.5" />
                     <span className="text-xs font-bold">{nextAppt.reason}</span>
                   </div>
                   <div className="flex items-center bg-white/10 px-4 py-2 rounded-xl backdrop-blur-sm border border-white/5">
                     <Users className="w-4 h-4 text-white mr-2.5" />
                     <span className="text-xs font-bold">Dr. {nextAppt.doctorName}</span>
                   </div>
                </div>
                <div className="mt-8 flex items-center space-x-3">
                   <Button className="bg-white text-primary-800 hover:bg-primary-50 rounded-xl px-6 py-2.5 font-bold shadow-md shadow-black/10">Reschedule</Button>
                   <Button variant="outline" className="text-white border-white/20 hover:bg-white/10 rounded-xl px-5 py-2.5 font-bold">View Details</Button>
                </div>
              </div>
            </Card>
          ) : (
            <Card className="p-16 text-center border-dashed border-2 border-secondary-200 dark:border-slate-800 bg-white/30 dark:bg-slate-900/30 backdrop-blur-md rounded-3xl">
               <Bell className="w-12 h-12 mx-auto mb-4 text-secondary-300 animate-bounce" />
               <h4 className="text-lg font-black text-secondary-900 dark:text-white tracking-tight">No Upcoming Appointments</h4>
               <p className="text-sm text-secondary-500 mt-2 mb-6 max-w-sm mx-auto font-medium">Need a routine checkup or specific care? Schedule a new session with your provider.</p>
               <Button variant="primary" onClick={() => router.push('/appointments')} className="px-6 rounded-xl">Book Consultation Now</Button>
            </Card>
          )}

          {/* Recent Records */}
          <Card className="p-6 border-none shadow-sm bg-white/40 dark:bg-slate-900/40 backdrop-blur-md">
            <h3 className="text-lg font-black text-secondary-900 dark:text-white mb-6 tracking-tight">Recent Medical Prescriptions</h3>
            <div className="space-y-4">
               {prescriptions?.slice(0, 3).map((p: any) => (
                 <div key={p.id} className="flex items-center justify-between p-4 rounded-2xl bg-white/50 dark:bg-slate-950/20 border border-secondary-200/20 dark:border-slate-800/40 hover:bg-white dark:hover:bg-slate-950/60 transition-all group cursor-pointer shadow-sm" onClick={() => router.push('/prescriptions')}>
                    <div className="flex items-center space-x-4">
                      <div className="p-3 rounded-2xl bg-primary-50 dark:bg-primary-950/30 text-primary-600 dark:text-primary-400 shadow-sm border border-primary-500/10">
                        <FileText className="w-5 h-5" />
                      </div>
                      <div>
                        <p className="text-sm font-extrabold text-secondary-900 dark:text-white group-hover:text-primary-600 transition-colors leading-snug">{p.medicationName}</p>
                        <p className="text-xs text-secondary-400 font-semibold mt-0.5">{new Date(p.createdAt).toLocaleDateString()} • {p.dosage}</p>
                      </div>
                    </div>
                    <ChevronRight className="w-5 h-5 text-secondary-400 group-hover:text-primary-600 transition-all group-hover:translate-x-0.5" />
                 </div>
               ))}
               {(!prescriptions || prescriptions.length === 0) && (
                 <p className="text-sm text-secondary-500 italic text-center py-6">No prescription logs recorded.</p>
               )}
            </div>
          </Card>
        </div>

        <div className="space-y-8">
          <Card className="p-6 border-none shadow-sm bg-white/40 dark:bg-slate-900/40 backdrop-blur-md">
            <h3 className="text-lg font-black text-secondary-900 dark:text-white mb-6 tracking-tight">Weekly Health Tips</h3>
            <div className="p-5 rounded-2xl bg-teal-50/50 dark:bg-teal-950/15 border border-teal-100/50 dark:border-teal-900/30 shadow-inner">
               <p className="text-sm font-extrabold text-teal-800 dark:text-teal-400">Stay Well Hydrated!</p>
               <p className="text-xs text-teal-600 dark:text-teal-500 mt-2 leading-relaxed font-semibold">
                 Drinking at least 8 glasses of water each day regulates body temperature, keeps joints lubricated, boosts energy levels, and supports kidney operations.
               </p>
            </div>
          </Card>

          <Card className="p-6 border-none shadow-sm bg-white/40 dark:bg-slate-900/40 backdrop-blur-md">
            <h3 className="text-lg font-black text-secondary-900 dark:text-white mb-4 tracking-tight">Quick Actions</h3>
            <div className="space-y-3">
              <Button variant="outline" className="w-full justify-start rounded-2xl p-5 border-secondary-200/50 dark:border-slate-800/60 hover:bg-white dark:hover:bg-slate-950/40 shadow-sm" onClick={() => router.push('/billing')}>
                <CreditCard className="w-5 h-5 mr-3.5 text-amber-500" />
                <div className="text-left">
                  <span className="text-xs font-black text-secondary-900 dark:text-white block">Pay Pending Invoices</span>
                  <span className="text-[10px] text-secondary-400 font-semibold block mt-0.5">Settle balance using Stripe</span>
                </div>
              </Button>
              <Button variant="outline" className="w-full justify-start rounded-2xl p-5 border-secondary-200/50 dark:border-slate-800/60 hover:bg-white dark:hover:bg-slate-950/40 shadow-sm" onClick={() => router.push('/prescriptions')}>
                <Pill className="w-5 h-5 mr-3.5 text-emerald-500" />
                <div className="text-left">
                  <span className="text-xs font-black text-secondary-900 dark:text-white block">Refill Prescription</span>
                  <span className="text-[10px] text-secondary-400 font-semibold block mt-0.5">Request clinical refill approvals</span>
                </div>
              </Button>
            </div>
          </Card>
        </div>
      </div>
    </div>
  );
};
