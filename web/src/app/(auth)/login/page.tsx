'use client';

import React, { useState } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { Stethoscope, Mail, Lock, Eye, EyeOff } from 'lucide-react';
import { useAppDispatch, useAppSelector } from '@/presentation/store/hooks';
import { setCredentials, setLoading, setError } from '@/presentation/store/slices/authSlice';
import api from '@/core/api';
import { Button } from '@/presentation/components/Button';
import { Card } from '@/presentation/components/Card';

export default function LoginPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const router = useRouter();
  const dispatch = useAppDispatch();
  
  const authError = useAppSelector((state) => state.auth.error);

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);
    dispatch(setLoading(true));

    try {
      const loginPayload = { email: email.trim(), password };
      const response = await api.post('/Auth/login', loginPayload);
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
      const message = err.response?.data?.message || err.message || 'Login failed';
      dispatch(setError(message));
    } finally {
      setIsLoading(false);
      dispatch(setLoading(false));
    }
  };

  const handleEmailFocus = () => {
    if (/\d/.test(email) && !email.includes('@')) {
      setEmail('');
    }
  };

  return (
    <div className="min-h-screen flex bg-slate-50 dark:bg-slate-950 font-sans transition-all duration-300">
      {/* Left side: Beautiful clinical branding */}
      <div className="hidden lg:flex lg:w-1/2 bg-gradient-to-br from-primary-950 via-primary-900 to-teal-950 text-white p-16 flex-col justify-between relative overflow-hidden">
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
            Healthcare,<br/>made simple & smart.
          </h1>
          <p className="text-slate-350/90 text-sm leading-relaxed font-semibold">
            Seamlessly connect patient histories, doctor agendas, and nurse triages in an integrated, real-time workflow. Built for progressive clinical groups.
          </p>

          {/* Floating Feature Badges */}
          <div className="pt-8 grid grid-cols-2 gap-5">
            <div className="p-4 bg-white/5 border border-white/10 rounded-2xl backdrop-blur-md shadow-sm hover:bg-white/10 transition-colors">
              <span className="text-[10px] font-black text-teal-400 block mb-1 uppercase tracking-widest">100% Encrypted</span>
              <span className="text-[11px] text-slate-300">HIPAA compliant security standards</span>
            </div>
            <div className="p-4 bg-white/5 border border-white/10 rounded-2xl backdrop-blur-md shadow-sm hover:bg-white/10 transition-colors">
              <span className="text-[10px] font-black text-teal-400 block mb-1 uppercase tracking-widest">Real-time Hub</span>
              <span className="text-[11px] text-slate-300">Instant updates & chat notifications</span>
            </div>
          </div>
        </div>

        {/* Footer info */}
        <p className="text-xs text-slate-400 font-bold z-10 tracking-wide uppercase">
          © {new Date().getFullYear()} CareSync Inc. All rights reserved.
        </p>
      </div>

      {/* Right side: Login form */}
      <div className="w-full lg:w-1/2 flex items-center justify-center p-8 sm:p-12 md:p-20 relative overflow-hidden">
        {/* Subtle background glow on mobile */}
        <div className="absolute top-[-10%] right-[-10%] w-[50%] h-[50%] rounded-full bg-primary-500/5 blur-3xl lg:hidden" />

        <div className="w-full max-w-md space-y-8 z-10 animate-scaleIn duration-300">
          {/* Logo on mobile only */}
          <div className="flex items-center space-x-3 lg:hidden mb-6">
            <div className="p-2.5 bg-gradient-to-br from-primary-500 to-teal-650 rounded-2xl text-white shadow-md">
              <Stethoscope className="w-5 h-5" />
            </div>
            <span className="text-lg font-black text-slate-900 dark:text-white">
              CareSync
            </span>
          </div>

          <div>
            <h2 className="text-3xl font-black text-slate-900 dark:text-white tracking-tight">
              Sign In
            </h2>
            <p className="mt-2.5 text-xs text-slate-500 font-bold uppercase tracking-wider">
              Need a portal account?{' '}
              <Link href="/register" className="text-primary-600 hover:text-primary-700 dark:text-primary-400 dark:hover:text-primary-350 transition-colors">
                Register here
              </Link>
            </p>
          </div>

          <Card className="p-8 border border-slate-200/50 dark:border-slate-800/80 shadow-2xl bg-white/80 dark:bg-slate-900/60 backdrop-blur-lg rounded-3xl">
            <form onSubmit={handleLogin} className="space-y-6">
              
              {/* Inline error feedback */}
              {authError && (
                <div className="p-4 bg-red-50/15 border border-red-500/20 text-red-600 dark:text-red-400 text-xs font-bold rounded-2xl flex items-center space-x-2 animate-scaleIn">
                  <span className="w-1.5 h-1.5 rounded-full bg-red-500 shrink-0" />
                  <span>{authError}</span>
                </div>
              )}

              {/* Email Input */}
              <div>
                <label className="block text-[10px] font-black text-secondary-400 dark:text-secondary-500 uppercase tracking-widest mb-2">
                  Email Address
                </label>
                <div className="relative group">
                  <Mail className="absolute left-4 top-1/2 -translate-y-1/2 w-4.5 h-4.5 text-secondary-400 group-focus-within:text-primary-555 transition-colors" />
                  <input
                    type="email"
                    value={email}
                    onChange={(e) => {
                      setEmail(e.target.value);
                      if (authError) dispatch(setError(null));
                    }}
                    onFocus={handleEmailFocus}
                    className="w-full bg-slate-50/50 dark:bg-slate-950/30 pl-11 pr-4 py-3.5 rounded-2xl text-xs focus:outline-none focus:ring-4 focus:ring-primary-500/10 border border-slate-200/60 dark:border-slate-800/80 focus:border-primary-500 dark:text-white placeholder-secondary-400 font-bold transition-all"
                    placeholder="name@hospital.com"
                    required
                    autoComplete="email"
                  />
                </div>
              </div>

              {/* Password Input */}
              <div>
                <label className="block text-[10px] font-black text-secondary-400 dark:text-secondary-500 uppercase tracking-widest mb-2">
                  Password
                </label>
                <div className="relative group">
                  <Lock className="absolute left-4 top-1/2 -translate-y-1/2 w-4.5 h-4.5 text-secondary-400 group-focus-within:text-primary-555 transition-colors" />
                  <input
                    type={showPassword ? 'text' : 'password'}
                    value={password}
                    onChange={(e) => {
                      setPassword(e.target.value);
                      if (authError) dispatch(setError(null));
                    }}
                    className="w-full bg-slate-50/50 dark:bg-slate-950/30 pl-11 pr-12 py-3.5 rounded-2xl text-xs focus:outline-none focus:ring-4 focus:ring-primary-500/10 border border-slate-200/60 dark:border-slate-800/80 focus:border-primary-500 dark:text-white placeholder-secondary-400 font-bold transition-all"
                    placeholder="••••••••"
                    required
                    autoComplete="current-password"
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

              {/* Remember me and Forgot Password */}
              <div className="flex items-center justify-between text-xs pt-1">
                <div className="flex items-center">
                  <input
                    id="remember-me"
                    name="remember-me"
                    type="checkbox"
                    className="h-4.5 w-4.5 text-primary-600 focus:ring-primary-500/20 border-secondary-200 dark:border-slate-800 rounded-lg transition-all cursor-pointer"
                  />
                  <label htmlFor="remember-me" className="ml-2 block text-[10px] text-secondary-500 dark:text-secondary-400 font-bold uppercase tracking-wider cursor-pointer">
                    Remember me
                  </label>
                </div>

                <div>
                  <a href="#" className="font-bold text-[10px] text-primary-600 hover:text-primary-700 dark:text-primary-400 dark:hover:text-primary-355 transition-colors uppercase tracking-wider">
                    Reset Password
                  </a>
                </div>
              </div>

              {/* Submit Button */}
              <div className="pt-2">
                <Button type="submit" className="w-full flex justify-center py-3.5 rounded-2xl bg-gradient-to-r from-primary-600 to-primary-750 hover:from-primary-500 hover:to-primary-650 text-xs font-black uppercase tracking-wider shadow-lg shadow-primary-500/15 transition-all cursor-pointer" isLoading={isLoading}>
                  Sign In Portal
                </Button>
              </div>
            </form>
          </Card>
        </div>
      </div>
    </div>
  );
}
