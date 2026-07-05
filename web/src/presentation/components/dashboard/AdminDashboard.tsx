'use client';

import { Card } from '@/presentation/components/Card';
import { Users, UserCog, DollarSign, FileText, CheckCircle, Calendar, Activity } from 'lucide-react';

interface AdminDashboardProps {
  stats: {
    totalUsers: number;
    activeUsers: number;
    totalPatients: number;
    totalDoctors: number;
    totalNurses: number;
    totalAppointments: number;
    upcomingAppointments: number;
    totalRevenue: number;
    paidInvoicesCount: number;
    unpaidInvoicesCount: number;
  } | null;
  invoices: any[];
}

export const AdminDashboard = ({ stats, invoices }: AdminDashboardProps) => {
  if (!stats) return null;

  const adminStats = [
    { label: 'Total Revenue', value: `$${stats.totalRevenue.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`, icon: DollarSign, color: 'text-teal-600 dark:text-teal-400', bg: 'bg-teal-50 dark:bg-teal-950/20', gradient: 'from-teal-500/10 to-emerald-500/5' },
    { label: 'Total Patients', value: stats.totalPatients.toString(), icon: Users, color: 'text-sky-600 dark:text-sky-400', bg: 'bg-sky-50 dark:bg-sky-950/20', gradient: 'from-sky-500/10 to-blue-500/5' },
    { label: 'Total Doctors', value: stats.totalDoctors.toString(), icon: UserCog, color: 'text-violet-600 dark:text-violet-400', bg: 'bg-violet-50 dark:bg-violet-950/20', gradient: 'from-violet-500/10 to-fuchsia-500/5' },
    { label: 'Upcoming Appts', value: stats.upcomingAppointments.toString(), icon: Calendar, color: 'text-amber-600 dark:text-amber-400', bg: 'bg-amber-50 dark:bg-amber-950/20', gradient: 'from-amber-500/10 to-orange-500/5' },
  ];

  return (
    <div className="space-y-8">
      {/* KPI Cards Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {adminStats.map((stat) => (
          <Card key={stat.label} className={`p-6 border-none shadow-sm hover:shadow-xl hover:-translate-y-1 transition-all duration-300 bg-gradient-to-br ${stat.gradient} relative overflow-hidden group`}>
            {/* Subtle background icon watermark */}
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

      {/* Main Content Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        {/* Recent Invoices Card */}
        <Card className="p-6 border-none shadow-sm relative overflow-hidden bg-white/40 dark:bg-slate-900/40 backdrop-blur-md">
          <h3 className="text-lg font-black text-secondary-900 dark:text-white mb-6 flex items-center tracking-tight">
            <FileText className="w-5 h-5 mr-2.5 text-primary-600 dark:text-primary-400" />
            Recent Financial Invoices
          </h3>
          <div className="space-y-4">
            {invoices?.slice(0, 5).map((inv: any) => (
              <div key={inv.id} className="flex items-center justify-between p-4 rounded-2xl bg-white/50 dark:bg-slate-950/30 border border-secondary-200/20 dark:border-slate-800/40 hover:bg-white dark:hover:bg-slate-950/60 transition-colors shadow-inner">
                <div className="flex items-center space-x-3">
                  <span className="text-xs font-bold text-secondary-500">#{inv.id.slice(0, 8).toUpperCase()}</span>
                  <span className={`px-3 py-1 rounded-full text-[9px] font-extrabold uppercase tracking-wider ${inv.status === 'Paid' ? 'bg-emerald-50 text-emerald-700 dark:bg-emerald-950/20 dark:text-emerald-400' : 'bg-amber-50 text-amber-700 dark:bg-amber-950/20 dark:text-amber-400'}`}>
                    {inv.status}
                  </span>
                </div>
                <span className="text-sm font-extrabold text-secondary-900 dark:text-white">${inv.amount.toLocaleString(undefined, { minimumFractionDigits: 2 })}</span>
              </div>
            ))}
            {(!invoices || invoices.length === 0) && (
              <p className="text-center text-secondary-500 py-6 text-sm italic">No recent financial records found.</p>
            )}
          </div>
        </Card>

        {/* Detailed System Insights Card */}
        <Card className="p-6 border-none shadow-sm relative overflow-hidden bg-white/40 dark:bg-slate-900/40 backdrop-blur-md">
          <h3 className="text-lg font-black text-secondary-900 dark:text-white mb-6 flex items-center tracking-tight">
            <CheckCircle className="w-5 h-5 mr-2.5 text-primary-600 dark:text-primary-400" />
            Clinic Operations & System Insights
          </h3>
          <div className="space-y-6">
            {/* User Statistics Grid */}
            <div className="grid grid-cols-2 gap-4">
              <div className="p-5 rounded-2xl bg-white/50 dark:bg-slate-950/30 border border-secondary-200/20 dark:border-slate-800/40 text-center shadow-inner hover:-translate-y-0.5 transition-transform duration-300">
                <p className="text-3xl font-black text-sky-600 dark:text-sky-400">{stats.activeUsers} <span className="text-sm text-secondary-400">/ {stats.totalUsers}</span></p>
                <p className="text-[10px] font-bold text-secondary-500 dark:text-secondary-400 uppercase tracking-wider mt-1.5">Active / Total Users</p>
              </div>
              <div className="p-5 rounded-2xl bg-white/50 dark:bg-slate-950/30 border border-secondary-200/20 dark:border-slate-800/40 text-center shadow-inner hover:-translate-y-0.5 transition-transform duration-300">
                <p className="text-3xl font-black text-violet-600 dark:text-violet-400">{stats.totalNurses}</p>
                <p className="text-[10px] font-bold text-secondary-500 dark:text-secondary-400 uppercase tracking-wider mt-1.5">Registered Nurses</p>
              </div>
              <div className="p-5 rounded-2xl bg-white/50 dark:bg-slate-950/30 border border-secondary-200/20 dark:border-slate-800/40 text-center shadow-inner hover:-translate-y-0.5 transition-transform duration-300">
                <p className="text-3xl font-black text-amber-600 dark:text-amber-400">{stats.totalAppointments}</p>
                <p className="text-[10px] font-bold text-secondary-500 dark:text-secondary-400 uppercase tracking-wider mt-1.5">Total Appointments</p>
              </div>
              <div className="p-5 rounded-2xl bg-white/50 dark:bg-slate-950/30 border border-secondary-200/20 dark:border-slate-800/40 text-center shadow-inner hover:-translate-y-0.5 transition-transform duration-300">
                <p className="text-3xl font-black text-emerald-600 dark:text-emerald-400">{stats.paidInvoicesCount} <span className="text-sm text-secondary-400">/ {stats.paidInvoicesCount + stats.unpaidInvoicesCount}</span></p>
                <p className="text-[10px] font-bold text-secondary-500 dark:text-secondary-400 uppercase tracking-wider mt-1.5">Paid / Total Invoices</p>
              </div>
            </div>

            {/* Quick Summary Banner */}
            <div className="p-4 bg-primary-50/50 dark:bg-primary-950/20 border border-primary-100/30 dark:border-primary-900/50 rounded-2xl flex items-start space-x-3 text-primary-700 dark:text-primary-300 shadow-sm">
              <Activity className="w-5 h-5 mt-0.5 shrink-0 text-primary-600 dark:text-primary-400 animate-pulse" />
              <p className="text-xs leading-relaxed font-bold">
                Clinic database is fully operational. System statistics and KPI indexes are served from the high-performance distributed cache for maximum speed.
              </p>
            </div>
          </div>
        </Card>
      </div>
    </div>
  );
};
