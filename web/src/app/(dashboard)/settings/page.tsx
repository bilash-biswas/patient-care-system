'use client';

import React from 'react';
import { Card } from '@/presentation/components/Card';
import { Button } from '@/presentation/components/Button';
import { 
  User, 
  Moon, 
  Sun, 
  Bell, 
  Shield, 
  Database, 
  Mail,
  Camera
} from 'lucide-react';
import { useTheme } from '@/presentation/components/ThemeProvider';
import { useAppSelector } from '@/presentation/store/hooks';

export default function SettingsPage() {
  const { theme, toggleTheme } = useTheme();
  const { user } = useAppSelector((state) => state.auth);

  return (
    <div className="max-w-4xl mx-auto space-y-8 animate-fadeIn duration-300">
      <div>
        <h1 className="text-3xl font-black text-slate-900 dark:text-white tracking-tight">Settings</h1>
        <p className="text-xs font-semibold text-secondary-500 dark:text-secondary-400 mt-1 uppercase tracking-wider">
          Manage your account preferences and application theme.
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
        {/* Navigation Sidebar */}
        <div className="space-y-2">
          <button className="w-full flex items-center space-x-3.5 p-3.5 bg-primary-500/10 border border-primary-500/20 text-primary-600 dark:text-primary-400 rounded-2xl font-black text-xs uppercase tracking-wider transition-all cursor-pointer">
            <User className="w-4 h-4 shrink-0" />
            <span>Profile</span>
          </button>
          <button className="w-full flex items-center space-x-3.5 p-3.5 text-secondary-400 dark:text-secondary-500 hover:text-secondary-650 dark:hover:text-secondary-200 hover:bg-secondary-50 dark:hover:bg-slate-950/20 border border-transparent rounded-2xl font-black text-xs uppercase tracking-wider transition-all cursor-pointer">
            <Bell className="w-4 h-4 shrink-0" />
            <span>Notifications</span>
          </button>
          <button className="w-full flex items-center space-x-3.5 p-3.5 text-secondary-400 dark:text-secondary-500 hover:text-secondary-650 dark:hover:text-secondary-200 hover:bg-secondary-50 dark:hover:bg-slate-950/20 border border-transparent rounded-2xl font-black text-xs uppercase tracking-wider transition-all cursor-pointer">
            <Shield className="w-4 h-4 shrink-0" />
            <span>Security</span>
          </button>
          <button className="w-full flex items-center space-x-3.5 p-3.5 text-secondary-400 dark:text-secondary-500 hover:text-secondary-650 dark:hover:text-secondary-200 hover:bg-secondary-50 dark:hover:bg-slate-950/20 border border-transparent rounded-2xl font-black text-xs uppercase tracking-wider transition-all cursor-pointer">
            <Database className="w-4 h-4 shrink-0" />
            <span>Data Management</span>
          </button>
        </div>

        {/* Content Area */}
        <div className="md:col-span-3 space-y-6">
          {/* Profile Section */}
          <Card className="p-6 border border-secondary-200/40 dark:border-slate-805/40 rounded-3xl">
            <h3 className="text-base font-black text-slate-850 dark:text-white uppercase tracking-wider mb-6">Profile Information</h3>
            
            <div className="flex flex-col sm:flex-row sm:items-start space-y-6 sm:space-y-0 sm:space-x-8">
              <div className="relative group shrink-0 mx-auto sm:mx-0">
                <div className="w-24 h-24 bg-gradient-to-br from-primary-500/10 to-teal-500/10 border-2 border-primary-500/20 rounded-3xl flex items-center justify-center text-3xl font-black text-primary-500 dark:text-primary-400 shadow-md">
                  {user?.firstName?.[0] || 'U'}
                </div>
                <button className="absolute -bottom-1 -right-1 p-2 bg-white dark:bg-slate-900 border border-secondary-200/40 dark:border-slate-805/40 shadow-md rounded-xl text-secondary-500 hover:text-primary-500 dark:hover:text-primary-400 transition-all cursor-pointer">
                  <Camera className="w-4 h-4" />
                </button>
              </div>
              
              <div className="flex-1 space-y-6 w-full">
                <div>
                  <h4 className="text-base font-black text-slate-800 dark:text-white leading-snug">{user?.firstName} {user?.lastName}</h4>
                  <p className="text-[10px] font-black text-primary-600 dark:text-primary-400 uppercase tracking-widest mt-1">{user?.role || 'User'} • Active Portal Account</p>
                </div>
                
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-5">
                  <div className="space-y-2">
                    <label className="block text-[10px] font-black text-secondary-400 dark:text-secondary-500 uppercase tracking-widest">First Name</label>
                    <input type="text" className="w-full bg-secondary-50/50 dark:bg-slate-950/40 px-4 py-3 rounded-2xl text-xs focus:outline-none focus:ring-2 focus:ring-primary-500/10 border border-secondary-200/60 dark:border-slate-805/65 focus:border-primary-500 dark:text-white placeholder-secondary-400 font-bold transition-all shadow-inner" defaultValue={user?.firstName || ''} />
                  </div>
                  <div className="space-y-2">
                    <label className="block text-[10px] font-black text-secondary-400 dark:text-secondary-500 uppercase tracking-widest">Last Name</label>
                    <input type="text" className="w-full bg-secondary-50/50 dark:bg-slate-950/40 px-4 py-3 rounded-2xl text-xs focus:outline-none focus:ring-2 focus:ring-primary-500/10 border border-secondary-200/60 dark:border-slate-805/65 focus:border-primary-500 dark:text-white placeholder-secondary-400 font-bold transition-all shadow-inner" defaultValue={user?.lastName || ''} />
                  </div>
                </div>
                
                <div className="space-y-2">
                  <label className="block text-[10px] font-black text-secondary-400 dark:text-secondary-500 uppercase tracking-widest">Email Address</label>
                  <div className="relative group">
                    <Mail className="absolute left-4 top-1/2 -translate-y-1/2 w-4.5 h-4.5 text-secondary-400 group-focus-within:text-primary-555 transition-colors" />
                    <input type="email" className="w-full bg-secondary-50/50 dark:bg-slate-950/40 pl-11 pr-4 py-3 rounded-2xl text-xs focus:outline-none focus:ring-2 focus:ring-primary-500/10 border border-secondary-200/60 dark:border-slate-805/65 focus:border-primary-500 dark:text-white placeholder-secondary-400 font-bold transition-all shadow-inner" defaultValue={user?.email || ''} />
                  </div>
                </div>
                
                <div className="pt-2">
                  <Button variant="primary">Save Changes</Button>
                </div>
              </div>
            </div>
          </Card>

          {/* Appearance Section */}
          <Card className="p-6 border border-secondary-200/40 dark:border-slate-805/40 rounded-3xl">
            <div className="flex items-center justify-between">
              <div>
                <h3 className="text-base font-black text-slate-850 dark:text-white uppercase tracking-wider">Appearance Mode</h3>
                <p className="text-xs font-semibold text-secondary-450 dark:text-secondary-500 mt-1">Customize the interface theme configuration.</p>
              </div>
              
              <button 
                onClick={toggleTheme}
                className="flex items-center space-x-1.5 p-1 bg-secondary-100/50 dark:bg-slate-950/50 rounded-full border border-secondary-200/40 dark:border-slate-805/40 transition-colors cursor-pointer"
              >
                <div className={`p-2.5 rounded-full transition-all ${theme === 'light' ? 'bg-white dark:bg-slate-900 shadow-md text-primary-500' : 'text-secondary-400 hover:text-secondary-300'}`}>
                  <Sun className="w-4.5 h-4.5" />
                </div>
                <div className={`p-2.5 rounded-full transition-all ${theme === 'dark' ? 'bg-white dark:bg-slate-900 shadow-md text-primary-405' : 'text-secondary-400 hover:text-secondary-600'}`}>
                  <Moon className="w-4.5 h-4.5" />
                </div>
              </button>
            </div>
          </Card>
        </div>
      </div>
    </div>
  );
}

