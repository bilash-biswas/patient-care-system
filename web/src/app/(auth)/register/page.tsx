'use client';

import React, { useState } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { Stethoscope, User, Mail, Lock, Phone, Eye, EyeOff, Check, HeartPulse } from 'lucide-react';
import { Button } from '@/presentation/components/Button';
import { Card } from '@/presentation/components/Card';
import api from '@/core/api';
import { useAppDispatch } from '@/presentation/store/hooks';
import { setCredentials } from '@/presentation/store/slices/authSlice';

export default function RegisterPage() {
  const [formData, setFormData] = useState({
    firstName: '',
    lastName: '',
    email: '',
    username: '',
    password: '',
    phoneNumber: '',
    role: 'Patient',
  });
  const [showPassword, setShowPassword] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const router = useRouter();
  const dispatch = useAppDispatch();

  const handleRegister = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);

    try {
      const response = await api.post('/Auth/register', formData);
      const apiResponse = response.data;
      const data = apiResponse.data || apiResponse.Data;

      if (!data) {
        throw new Error('No data received from server');
      }

      const userObject = {
        id: data.id || data.Id,
        email: data.email || data.Email,
        username: data.username || data.Username,
        firstName: data.firstName || data.FirstName,
        lastName: data.lastName || data.LastName,
        role: data.role || data.Role,
        isActive: data.isActive !== undefined ? data.isActive : data.IsActive,
      };

      dispatch(setCredentials({
        user: userObject,
        token: data.token || data.Token,
      }));

      router.push('/');
    } catch (err: any) {
      alert(err.response?.data?.message || err.message || 'Registration failed');
    } finally {
      setIsLoading(false);
    }
  };

  const roles = [
    {
      name: 'Patient',
      description: 'Access medical charts, track prescriptions & schedule visits.',
      icon: User,
      textColor: 'text-blue-600 dark:text-blue-400',
      bgGlow: 'group-hover:bg-blue-500/10',
    },
    {
      name: 'Doctor',
      description: 'Consult patient files, update records & manage scheduling.',
      icon: Stethoscope,
      textColor: 'text-teal-600 dark:text-teal-400',
      bgGlow: 'group-hover:bg-teal-500/10',
    },
    {
      name: 'Nurse',
      description: 'Coordinate triages, administer care plans & assist staff.',
      icon: HeartPulse,
      textColor: 'text-pink-600 dark:text-pink-400',
      bgGlow: 'group-hover:bg-pink-500/10',
    },
  ];

  return (
    <div className="min-h-screen flex bg-slate-50 dark:bg-slate-950 font-sans transition-all duration-300">
      {/* Left side: Beautiful clinical branding */}
      <div className="hidden lg:flex lg:w-5/12 bg-gradient-to-br from-primary-950 via-primary-900 to-teal-950 text-white p-16 flex-col justify-between relative overflow-hidden">
        {/* Animated decorative background circles */}
        <div className="absolute top-[-25%] left-[-25%] w-[85%] h-[85%] rounded-full bg-teal-500/10 blur-3xl animate-pulse" />
        <div className="absolute bottom-[-15%] right-[-15%] w-[65%] h-[65%] rounded-full bg-primary-500/10 blur-3xl animate-pulse" style={{ animationDelay: '3.5s' }} />

        {/* Branding header */}
        <div className="flex items-center space-x-3.5 z-10">
          <div className="p-3 bg-white/10 backdrop-blur-md border border-white/20 rounded-2xl shadow-md">
            <Stethoscope className="w-6 h-6 text-teal-400" />
          </div>
          <span className="text-xl font-black tracking-wider bg-clip-text text-transparent bg-gradient-to-r from-white to-teal-300">
            CareSync
          </span>
        </div>

        {/* Hero Copy */}
        <div className="space-y-6 z-10 my-auto max-w-lg">
          <h1 className="text-5xl font-black leading-tight tracking-tight bg-clip-text text-transparent bg-gradient-to-r from-white via-slate-100 to-teal-200">
            Connect. Care.<br/>Collaborate.
          </h1>
          <p className="text-slate-350/90 text-sm leading-relaxed font-semibold">
            Create your account today and gain secure access to clinical operations, real-time messaging, and patient charts. Built for modern medical groups.
          </p>

          {/* Floating Feature Badges */}
          <div className="pt-8 space-y-4">
            <div className="p-4 bg-white/5 border border-white/10 rounded-2xl backdrop-blur-md flex items-start space-x-3 hover:bg-white/10 transition-colors">
              <div className="w-2.5 h-2.5 rounded-full bg-teal-400 mt-1.5 shrink-0" />
              <div>
                <span className="text-xs font-black text-white block uppercase tracking-wider">Unified Platform</span>
                <span className="text-xs text-slate-300/80">Separate, customized views built for Patients, Physicians, and Care teams.</span>
              </div>
            </div>
            <div className="p-4 bg-white/5 border border-white/10 rounded-2xl backdrop-blur-md flex items-start space-x-3 hover:bg-white/10 transition-colors">
              <div className="w-2.5 h-2.5 rounded-full bg-teal-400 mt-1.5 shrink-0" />
              <div>
                <span className="text-xs font-black text-white block uppercase tracking-wider">HIPAA Secured</span>
                <span className="text-xs text-slate-300/80">Adhere to strict data standards, protecting critical healthcare records.</span>
              </div>
            </div>
          </div>
        </div>

        {/* Footer info */}
        <p className="text-xs text-slate-400 font-bold z-10 tracking-wide uppercase">
          © {new Date().getFullYear()} CareSync Inc. All rights reserved.
        </p>
      </div>

      {/* Right side: Register form */}
      <div className="w-full lg:w-7/12 flex items-center justify-center p-6 sm:p-12 md:p-16 relative overflow-hidden">
        {/* Subtle background glow on mobile */}
        <div className="absolute top-[-10%] right-[-10%] w-[50%] h-[50%] rounded-full bg-primary-500/5 blur-3xl lg:hidden" />

        <div className="w-full max-w-2xl space-y-6 z-10 animate-scaleIn duration-300">
          {/* Logo on mobile only */}
          <div className="flex items-center space-x-3 lg:hidden mb-4">
            <div className="p-2.5 bg-gradient-to-br from-primary-500 to-teal-650 rounded-2xl text-white shadow-md">
              <Stethoscope className="w-5 h-5" />
            </div>
            <span className="text-lg font-black text-slate-900 dark:text-white">
              CareSync
            </span>
          </div>

          <div>
            <h2 className="text-3xl font-black text-slate-900 dark:text-white tracking-tight">
              Create Portal Account
            </h2>
            <p className="mt-2.5 text-xs text-slate-500 font-bold uppercase tracking-wider">
              Already registered?{' '}
              <Link href="/login" className="text-primary-600 hover:text-primary-700 dark:text-primary-400 dark:hover:text-primary-350 transition-colors">
                Sign In instead
              </Link>
            </p>
          </div>

          <Card className="p-8 border border-slate-200/50 dark:border-slate-800/80 shadow-2xl bg-white/80 dark:bg-slate-900/60 backdrop-blur-lg rounded-3xl">
            <form onSubmit={handleRegister} className="grid grid-cols-1 md:grid-cols-2 gap-6">
              
              {/* Interactive Role Cards */}
              <div className="md:col-span-2 space-y-3">
                <label className="block text-[10px] font-black text-secondary-400 dark:text-secondary-500 uppercase tracking-widest">
                  Select Portal Role
                </label>
                <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
                  {roles.map((roleItem) => {
                    const IconComponent = roleItem.icon;
                    const isSelected = formData.role === roleItem.name;
                    
                    return (
                      <div
                        key={roleItem.name}
                        onClick={() => setFormData({ ...formData, role: roleItem.name })}
                        className={`group relative p-4 rounded-2xl border-2 cursor-pointer transition-all duration-300 flex flex-col items-center text-center space-y-2 select-none hover:scale-[1.02] ${
                          isSelected
                            ? 'border-primary-500 bg-primary-50/10 dark:bg-primary-950/10 shadow-lg shadow-primary-500/5'
                            : 'border-slate-200/60 dark:border-slate-800/60 bg-white/40 dark:bg-slate-950/20 hover:border-slate-300 dark:hover:border-slate-700'
                        }`}
                      >
                        {isSelected && (
                          <div className="absolute top-2.5 right-2.5 bg-primary-500 text-white p-0.5 rounded-full shadow-md animate-scaleIn">
                            <Check className="w-3.5 h-3.5" />
                          </div>
                        )}
                        <div className={`p-3 rounded-xl bg-slate-50 dark:bg-slate-800/50 transition-all duration-300 ${roleItem.textColor} ${roleItem.bgGlow}`}>
                          <IconComponent className="w-5.5 h-5.5" />
                        </div>
                        <h4 className="text-xs font-black text-slate-900 dark:text-white uppercase tracking-wider">
                          {roleItem.name}
                        </h4>
                        <p className="text-[10px] text-slate-500 leading-normal font-bold">
                          {roleItem.description}
                        </p>
                      </div>
                    );
                  })}
                </div>
              </div>

              {/* First Name */}
              <div>
                <label className="block text-[10px] font-black text-secondary-400 dark:text-secondary-500 uppercase tracking-widest mb-2">
                  First Name
                </label>
                <div className="relative group">
                  <User className="absolute left-4 top-1/2 -translate-y-1/2 w-4.5 h-4.5 text-secondary-400 group-focus-within:text-primary-500 transition-colors" />
                  <input
                    type="text"
                    required
                    className="w-full bg-slate-50/50 dark:bg-slate-950/30 pl-11 pr-4 py-3.5 rounded-2xl text-xs focus:outline-none focus:ring-4 focus:ring-primary-500/10 border border-slate-200/60 dark:border-slate-800/80 focus:border-primary-500 dark:text-white placeholder-secondary-400 font-bold transition-all"
                    placeholder="John"
                    value={formData.firstName}
                    onChange={(e) => setFormData({ ...formData, firstName: e.target.value })}
                  />
                </div>
              </div>

              {/* Last Name */}
              <div>
                <label className="block text-[10px] font-black text-secondary-400 dark:text-secondary-500 uppercase tracking-widest mb-2">
                  Last Name
                </label>
                <div className="relative group">
                  <User className="absolute left-4 top-1/2 -translate-y-1/2 w-4.5 h-4.5 text-secondary-400 group-focus-within:text-primary-500 transition-colors" />
                  <input
                    type="text"
                    required
                    className="w-full bg-slate-50/50 dark:bg-slate-950/30 pl-11 pr-4 py-3.5 rounded-2xl text-xs focus:outline-none focus:ring-4 focus:ring-primary-500/10 border border-slate-200/60 dark:border-slate-800/80 focus:border-primary-500 dark:text-white placeholder-secondary-400 font-bold transition-all"
                    placeholder="Doe"
                    value={formData.lastName}
                    onChange={(e) => setFormData({ ...formData, lastName: e.target.value })}
                  />
                </div>
              </div>

              {/* Username */}
              <div>
                <label className="block text-[10px] font-black text-secondary-400 dark:text-secondary-500 uppercase tracking-widest mb-2">
                  Username
                </label>
                <div className="relative group">
                  <User className="absolute left-4 top-1/2 -translate-y-1/2 w-4.5 h-4.5 text-secondary-400 group-focus-within:text-primary-500 transition-colors" />
                  <input
                    type="text"
                    required
                    className="w-full bg-slate-50/50 dark:bg-slate-950/30 pl-11 pr-4 py-3.5 rounded-2xl text-xs focus:outline-none focus:ring-4 focus:ring-primary-500/10 border border-slate-200/60 dark:border-slate-800/80 focus:border-primary-500 dark:text-white placeholder-secondary-400 font-bold transition-all"
                    placeholder="johndoe"
                    value={formData.username}
                    onChange={(e) => setFormData({ ...formData, username: e.target.value })}
                  />
                </div>
              </div>

              {/* Phone Number */}
              <div>
                <label className="block text-[10px] font-black text-secondary-400 dark:text-secondary-500 uppercase tracking-widest mb-2">
                  Phone Number
                </label>
                <div className="relative group">
                  <Phone className="absolute left-4 top-1/2 -translate-y-1/2 w-4.5 h-4.5 text-secondary-400 group-focus-within:text-primary-500 transition-colors" />
                  <input
                    type="tel"
                    required
                    className="w-full bg-slate-50/50 dark:bg-slate-950/30 pl-11 pr-4 py-3.5 rounded-2xl text-xs focus:outline-none focus:ring-4 focus:ring-primary-500/10 border border-slate-200/60 dark:border-slate-800/80 focus:border-primary-500 dark:text-white placeholder-secondary-400 font-bold transition-all"
                    placeholder="+1 (234) 567-890"
                    value={formData.phoneNumber}
                    onChange={(e) => setFormData({ ...formData, phoneNumber: e.target.value })}
                  />
                </div>
              </div>

              {/* Email Address */}
              <div className="md:col-span-2">
                <label className="block text-[10px] font-black text-secondary-400 dark:text-secondary-500 uppercase tracking-widest mb-2">
                  Email Address
                </label>
                <div className="relative group">
                  <Mail className="absolute left-4 top-1/2 -translate-y-1/2 w-4.5 h-4.5 text-secondary-400 group-focus-within:text-primary-500 transition-colors" />
                  <input
                    type="email"
                    required
                    className="w-full bg-slate-50/50 dark:bg-slate-950/30 pl-11 pr-4 py-3.5 rounded-2xl text-xs focus:outline-none focus:ring-4 focus:ring-primary-500/10 border border-slate-200/60 dark:border-slate-800/80 focus:border-primary-500 dark:text-white placeholder-secondary-400 font-bold transition-all"
                    placeholder="john.doe@hospital.com"
                    value={formData.email}
                    onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                  />
                </div>
              </div>

              {/* Password */}
              <div className="md:col-span-2">
                <label className="block text-[10px] font-black text-secondary-400 dark:text-secondary-500 uppercase tracking-widest mb-2">
                  Password
                </label>
                <div className="relative group">
                  <Lock className="absolute left-4 top-1/2 -translate-y-1/2 w-4.5 h-4.5 text-secondary-400 group-focus-within:text-primary-500 transition-colors" />
                  <input
                    type={showPassword ? 'text' : 'password'}
                    required
                    className="w-full bg-slate-50/50 dark:bg-slate-950/30 pl-11 pr-12 py-3.5 rounded-2xl text-xs focus:outline-none focus:ring-4 focus:ring-primary-500/10 border border-slate-200/60 dark:border-slate-800/80 focus:border-primary-500 dark:text-white placeholder-secondary-400 font-bold transition-all"
                    placeholder="••••••••"
                    value={formData.password}
                    onChange={(e) => setFormData({ ...formData, password: e.target.value })}
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    className="absolute right-4 top-1/2 -translate-y-1/2 text-secondary-400 hover:text-secondary-700 dark:hover:text-secondary-200 transition-colors cursor-pointer"
                  >
                    {showPassword ? <EyeOff className="w-4.5 h-4.5" /> : <Eye className="w-4.5 h-4.5" />}
                  </button>
                </div>
              </div>

              {/* Submit Button */}
              <div className="md:col-span-2 pt-2">
                <Button type="submit" className="w-full flex justify-center py-3.5 rounded-2xl bg-gradient-to-r from-primary-600 to-primary-750 hover:from-primary-500 hover:to-primary-650 text-xs font-black uppercase tracking-wider shadow-lg shadow-primary-500/15 transition-all hover:scale-[1.01] cursor-pointer" isLoading={isLoading}>
                  Create Portal Account
                </Button>
              </div>
            </form>
          </Card>
        </div>
      </div>
    </div>
  );
}
