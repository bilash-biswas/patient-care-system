'use client';

import { Card } from '@/presentation/components/Card';
import { Activity, Users, Clock, ClipboardList, ChevronRight, Stethoscope } from 'lucide-react';
import { Button } from '@/presentation/components/Button';

export const NurseDashboard = ({ appointments, patientCount, router }: any) => {
  const nurseStats = [
    { label: 'Patient Queue', value: appointments.length.toString(), icon: Clock, color: 'text-sky-600 dark:text-sky-400', bg: 'bg-sky-50 dark:bg-sky-950/20', gradient: 'from-sky-500/10 to-blue-500/5' },
    { label: 'Total Patients', value: patientCount.toString(), icon: Users, color: 'text-violet-600 dark:text-violet-400', bg: 'bg-violet-50 dark:bg-violet-950/20', gradient: 'from-violet-500/10 to-indigo-500/5' },
    { label: 'Vitals Pending', value: '3', icon: Activity, color: 'text-amber-600 dark:text-amber-400', bg: 'bg-amber-50 dark:bg-amber-950/20', gradient: 'from-amber-500/10 to-orange-500/5' },
    { label: 'Triage Done', value: '12', icon: ClipboardList, color: 'text-emerald-600 dark:text-emerald-400', bg: 'bg-emerald-50 dark:bg-emerald-950/20', gradient: 'from-emerald-500/10 to-teal-500/5' },
  ];

  return (
    <div className="space-y-8">
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {nurseStats.map((stat) => (
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
        <Card className="lg:col-span-2 p-0 overflow-hidden border-none shadow-sm bg-white/40 dark:bg-slate-900/40 backdrop-blur-md">
          <div className="p-6 border-b border-secondary-200/20 dark:border-slate-800/40 flex items-center justify-between">
            <h3 className="text-lg font-black text-secondary-900 dark:text-white flex items-center tracking-tight">
               <Stethoscope className="w-5 h-5 mr-2.5 text-primary-600 dark:text-primary-400 animate-pulse" />
               Current Patient Queue
             </h3>
            <Button variant="ghost" size="sm" onClick={() => router.push('/appointments')} className="text-xs">
              View Queue
            </Button>
          </div>
          <div className="divide-y divide-secondary-100/50 dark:divide-slate-800/40">
            {appointments.length === 0 ? (
              <div className="p-16 text-center text-secondary-500 italic text-sm">Queue is empty.</div>
            ) : (
              appointments.map((app: any) => (
                <div key={app.id} className="p-5 flex items-center justify-between hover:bg-white dark:hover:bg-slate-950/40 transition-colors">
                  <div className="flex items-center space-x-4">
                    <div className="w-11 h-11 rounded-2xl bg-sky-50 dark:bg-sky-950/20 flex items-center justify-center font-extrabold text-sky-600 dark:text-sky-400 border border-sky-500/10 shadow-sm">
                      {app.patientName?.[0]}
                    </div>
                    <div>
                      <p className="text-sm font-extrabold text-secondary-900 dark:text-white leading-snug">{app.patientName}</p>
                      <p className="text-xs font-semibold text-secondary-400 mt-0.5">Wait Time: 15 mins • {app.reason}</p>
                    </div>
                  </div>
                  <div className="flex space-x-2">
                    <Button variant="outline" size="sm" className="rounded-xl text-xs py-1.5 px-3">Start Vitals</Button>
                    <Button variant="primary" size="sm" className="rounded-xl text-xs py-1.5 px-3">Check-in</Button>
                  </div>
                </div>
              ))
            )}
          </div>
        </Card>

        <Card className="p-6 border-none shadow-sm bg-white/40 dark:bg-slate-900/40 backdrop-blur-md">
          <h3 className="text-lg font-black text-secondary-900 dark:text-white mb-6 tracking-tight">Support Actions</h3>
          <div className="space-y-3">
            {[
              { label: 'Patient Vital History', desc: 'Verify diagnostic tracking logs', href: '#' },
              { label: 'Manage Supply Cabinet', desc: 'Track clinic inventory levels', href: '#' },
              { label: 'Emergency Contact Index', desc: 'Reach emergency responders', href: '#' },
            ].map((action) => (
              <button 
                key={action.label}
                className="w-full p-4 bg-white/50 dark:bg-slate-950/20 border border-secondary-200/20 dark:border-slate-800/40 rounded-2xl flex items-center justify-between hover:bg-white dark:hover:bg-slate-950/60 transition-all text-left shadow-sm group hover:-translate-y-0.5 cursor-pointer"
                onClick={() => action.href !== '#' && router.push(action.href)}
              >
                <div className="pr-4">
                  <span className="text-sm font-extrabold text-secondary-950 dark:text-slate-100 group-hover:text-primary-600 dark:group-hover:text-primary-400 transition-colors">{action.label}</span>
                  <p className="text-[10px] font-semibold text-secondary-400 mt-1">{action.desc}</p>
                </div>
                <ChevronRight className="w-5 h-5 text-secondary-400 shrink-0 group-hover:text-primary-600 dark:group-hover:text-primary-400 transition-colors" />
              </button>
            ))}
          </div>
        </Card>
      </div>
    </div>
  );
};
