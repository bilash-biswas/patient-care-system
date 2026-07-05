'use client';

import React from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { 
  LayoutDashboard, 
  Users, 
  Calendar, 
  ClipboardList, 
  Settings, 
  LogOut,
  Stethoscope,
  Sun,
  Moon,
  Pill,
  CreditCard,
  MessageSquare,
  BarChart3,
  UserRound,
  HeartPulse
} from 'lucide-react';
import { cn } from '@/presentation/components/Button';
import { useAppDispatch, useAppSelector } from '@/presentation/store/hooks';
import { logout } from '@/presentation/store/slices/authSlice';
import { useTheme } from '@/presentation/components/ThemeProvider';

const allMenuItems = [
  { icon: LayoutDashboard, label: 'Dashboard', href: '/', roles: ['Admin', 'Doctor', 'Patient', 'Nurse'] },
  { icon: Users, label: 'Patients', href: '/patients', roles: ['Admin', 'Doctor', 'Nurse'] },
  { icon: UserRound, label: 'Doctors', href: '/doctors', roles: ['Admin', 'Patient', 'Nurse'] },
  { icon: HeartPulse, label: 'Nurses', href: '/nurses', roles: ['Admin', 'Doctor'] },
  { icon: Calendar, label: 'Appointments', href: '/appointments', roles: ['Admin', 'Doctor', 'Patient', 'Nurse'] },
  { icon: ClipboardList, label: 'Medical Records', href: '/medical-records', roles: ['Admin', 'Doctor', 'Nurse'] },
  { icon: Pill, label: 'Prescriptions', href: '/prescriptions', roles: ['Doctor', 'Patient'] },
  { icon: CreditCard, label: 'Billing', href: '/billing', roles: ['Admin', 'Patient'] },
  { icon: MessageSquare, label: 'Chat', href: '/chat', roles: ['Admin', 'Doctor', 'Patient', 'Nurse'] },
  { icon: BarChart3, label: 'Reports', href: '/reports', roles: ['Admin'] },
];

export const Sidebar = () => {
  const pathname = usePathname();
  const dispatch = useAppDispatch();
  const { user } = useAppSelector((state) => state.auth);
  const { theme, toggleTheme } = useTheme();

  const menuItems = allMenuItems.filter(item => item.roles.includes(user?.role || ''));

  return (
    <div className="w-64 h-screen bg-white/70 dark:bg-slate-950/50 backdrop-blur-xl border-r border-secondary-200/40 dark:border-slate-900/50 flex flex-col p-5 fixed left-0 top-0 z-40 transition-all duration-300">
      {/* Brand Section */}
      <div className="flex items-center space-x-3 mb-8 px-2 mt-4">
        <div className="p-2.5 bg-gradient-to-br from-primary-500 to-primary-700 rounded-xl shadow-md shadow-primary-500/10">
          <Stethoscope className="w-5 h-5 text-white" />
        </div>
        <div>
           <h2 className="text-xl font-extrabold tracking-tight bg-gradient-to-r from-primary-600 to-teal-600 dark:from-primary-400 dark:to-teal-400 bg-clip-text text-transparent">
             PatientCare
           </h2>
        </div>
      </div>

      {/* Main Navigation */}
      <nav className="flex-1 space-y-1.5 overflow-y-auto pr-1 scrollbar-none">
        {menuItems.map((item) => {
          const isActive = pathname === item.href;
          return (
            <Link
              key={item.href}
              href={item.href}
              className={cn(
                'flex items-center space-x-3 px-4 py-3 rounded-xl transition-all duration-300 text-sm font-bold',
                isActive 
                  ? 'bg-primary-50/50 dark:bg-primary-950/20 text-primary-600 dark:text-primary-400 border-l-4 border-primary-500 pl-3 shadow-inner' 
                  : 'text-secondary-600 dark:text-secondary-400 hover:bg-secondary-50 dark:hover:bg-secondary-900/30 hover:text-secondary-900 dark:hover:text-white'
              )}
            >
              <item.icon className={cn('w-5 h-5 transition-transform duration-300 group-hover:scale-110', isActive ? 'text-primary-600 dark:text-primary-400' : 'text-secondary-400 group-hover:text-secondary-500')} />
              <span>{item.label}</span>
            </Link>
          );
        })}
      </nav>

      {/* Bottom Section */}
      <div className="pt-4 mt-4 border-t border-secondary-200/50 dark:border-secondary-900/50 space-y-1.5">
        <button 
          onClick={toggleTheme}
          className="w-full flex items-center space-x-3 px-4 py-2.5 rounded-xl text-sm font-bold text-secondary-600 dark:text-secondary-400 hover:bg-secondary-50 dark:hover:bg-secondary-900/30 hover:text-secondary-900 dark:hover:text-white transition-all duration-300"
        >
          {theme === 'light' ? <Moon className="w-5 h-5 text-secondary-400" /> : <Sun className="w-5 h-5 text-secondary-400" />}
          <span>{theme === 'light' ? 'Dark Mode' : 'Light Mode'}</span>
        </button>

        <Link 
          href="/settings" 
          className="w-full flex items-center space-x-3 px-4 py-2.5 rounded-xl text-sm font-bold text-secondary-600 dark:text-secondary-400 hover:bg-secondary-50 dark:hover:bg-secondary-900/30 hover:text-secondary-900 dark:hover:text-white transition-all duration-300"
        >
          <Settings className="w-5 h-5 text-secondary-400" />
          <span>Settings</span>
        </Link>
        <button 
          onClick={() => dispatch(logout())}
          className="w-full flex items-center space-x-3 px-4 py-2.5 rounded-xl text-sm font-bold text-red-600 hover:bg-red-50/50 dark:text-red-400 dark:hover:bg-red-950/20 transition-all duration-300 text-left cursor-pointer"
        >
          <LogOut className="w-5 h-5 text-red-500" />
          <span>Logout</span>
        </button>
      </div>
    </div>
  );
};
