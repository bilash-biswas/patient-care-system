'use client';

import React, { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { useAppSelector } from '@/presentation/store/hooks';
import { Card } from '@/presentation/components/Card';
import { User, Search, Mail, Phone, X, Clock, Calendar, MessageSquare, AlertCircle, Sparkles } from 'lucide-react';
import { cn } from '@/presentation/components/Button';
import { AppointmentRepository } from '@/data/repositories/AppointmentRepository';
import api from '@/core/api';

interface PeoplePageProps {
  title: string;
  role: string;
  description: string;
  selectedDoctorId?: string;
}

const appointmentRepo = new AppointmentRepository();

const timeToMinutes = (timeStr: string) => {
  const [h, m] = timeStr.split(':');
  return parseInt(h) * 60 + parseInt(m);
};

const minutesToTime = (totalMin: number) => {
  const h = Math.floor(totalMin / 60);
  const m = totalMin % 60;
  return `${h.toString().padStart(2, '0')}:${m.toString().padStart(2, '0')}`;
};

const formatTimeTo12Hour = (time24: string) => {
  if (!time24) return '';
  const [hoursStr, minutesStr] = time24.split(':');
  const hours = parseInt(hoursStr, 10);
  if (isNaN(hours)) return time24;
  const ampm = hours >= 12 ? 'PM' : 'AM';
  const hours12 = hours % 12 || 12;
  return `${hours12}:${minutesStr} ${ampm}`;
};

const DAY_NAMES = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

// Static read-only weekly availability timetable display
const ReadOnlyAvailability = ({ doctorId }: { doctorId: string }) => {
  const [schedule, setSchedule] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchAvailability = async () => {
      try {
        const res = await api.get(`/doctors/${doctorId}/availability`);
        // Sort days: Monday (1) to Sunday (0)
        const sorted = (res.data.data || []).sort((a: any, b: any) => {
          const valA = a.dayOfWeek === 0 ? 7 : a.dayOfWeek;
          const valB = b.dayOfWeek === 0 ? 7 : b.dayOfWeek;
          return valA - valB;
        });
        setSchedule(sorted);
      } catch (err) {
        console.error(err);
      } finally {
        setLoading(false);
      }
    };
    fetchAvailability();
  }, [doctorId]);

  if (loading) {
    return (
      <div className="py-4 flex items-center justify-center space-x-2">
        <div className="w-4 h-4 border-2 border-primary-500 border-t-transparent rounded-full animate-spin" />
        <span className="text-[10px] text-secondary-500 italic">Loading timetable...</span>
      </div>
    );
  }

  return (
    <div className="space-y-2.5 pt-1">
      {schedule.map((dayRule) => {
        const dayName = DAY_NAMES[dayRule.dayOfWeek];
        return (
          <div 
            key={dayRule.dayOfWeek} 
            className="flex items-center justify-between text-xs font-semibold py-1.5 border-b border-slate-100/50 dark:border-slate-800/20 last:border-none"
          >
            <span className="text-secondary-500 dark:text-slate-400">{dayName}</span>
            <span className={cn(
              "font-bold text-[11px]",
              dayRule.isAvailable 
                ? "text-secondary-900 dark:text-white" 
                : "text-secondary-400 dark:text-slate-600 italic"
            )}>
              {dayRule.isAvailable ? `${dayRule.startTime} – ${dayRule.endTime}` : 'Closed'}
            </span>
          </div>
        );
      })}
    </div>
  );
};

export const PeoplePage = ({ title, role, description, selectedDoctorId }: PeoplePageProps) => {
  const router = useRouter();
  const [people, setPeople] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [selectedPerson, setSelectedPerson] = useState<any | null>(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [statusFilter, setStatusFilter] = useState('All');
  const [currentPage, setCurrentPage] = useState(1);
  const [totalCount, setTotalCount] = useState(0);
  const [totalPages, setTotalPages] = useState(0);
  const itemsPerPage = 6;

  const { user: currentUser } = useAppSelector((state) => state.auth);

  // Tab State
  const [activeTab, setActiveTab] = useState<'details' | 'booking'>('details');

  // Booking Slots State
  const [bookingDate, setBookingDate] = useState('');
  const [bookingStartTime, setBookingStartTime] = useState('');
  const [bookingEndTime, setBookingEndTime] = useState('');
  const [bookingReason, setBookingReason] = useState('');
  const [bookingNotes, setBookingNotes] = useState('');
  const [bookingError, setBookingError] = useState<string | null>(null);
  const [bookingLoading, setBookingLoading] = useState(false);

  // Visual Time Slots Grid
  const [availableSlots, setAvailableSlots] = useState<{ start: string; end: string; isBooked: boolean }[]>([]);
  const [loadingSlots, setLoadingSlots] = useState(false);
  const [selectedSlot, setSelectedSlot] = useState<string | null>(null);

  // Day-wise availability schedule
  const [doctorSchedule, setDoctorSchedule] = useState<{ dayOfWeek: number; startTime: string; endTime: string; isAvailable: boolean }[]>([]);
  const [loadingSchedule, setLoadingSchedule] = useState(false);
  const [selectedDay, setSelectedDay] = useState<number | null>(null);

  useEffect(() => {
    const fetchData = async () => {
      setLoading(true);
      try {
        let activeQuery = '';
        if (statusFilter === 'Active') activeQuery = '&isActive=true';
        else if (statusFilter === 'Inactive') activeQuery = '&isActive=false';
        
        const searchQuery = search ? `&search=${encodeURIComponent(search)}` : '';
        
        const pageSizeToUse = selectedDoctorId ? 100 : itemsPerPage;
        const res = await api.get(`/chat/directory?role=${role}${searchQuery}${activeQuery}&page=${currentPage}&pageSize=${pageSizeToUse}`);
        
        const list = res.data.data || [];
        setPeople(list);
        setTotalCount(res.data.pagination?.totalCount || 0);
        setTotalPages(res.data.pagination?.totalPages || 0);

        if (selectedDoctorId) {
          const match = list.find((p: any) => p.id === selectedDoctorId);
          if (match) {
            setSelectedPerson(match);
            loadDoctorSchedule(match.id);
          }
        }
      } catch (e) {
        console.error(e);
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, [role, search, statusFilter, currentPage, selectedDoctorId]);

  const startIndex = (currentPage - 1) * itemsPerPage;
  const endIndex = startIndex + itemsPerPage;

  const getPageNumbers = () => {
    const pages = [];
    const maxVisible = 5;
    if (totalPages <= maxVisible) {
      for (let i = 1; i <= totalPages; i++) pages.push(i);
    } else {
      pages.push(1);
      if (currentPage > 3) pages.push('...');
      const start = Math.max(2, currentPage - 1);
      const end = Math.min(totalPages - 1, currentPage + 1);
      for (let i = start; i <= end; i++) pages.push(i);
      if (currentPage < totalPages - 2) pages.push('...');
      pages.push(totalPages);
    }
    return pages;
  };

  // Redesign Helpers
  const getInitials = (firstName: string = '', lastName: string = '') => {
    return `${firstName.charAt(0)}${lastName.charAt(0)}`.toUpperCase();
  };

  const getAvatarStyle = (id: string) => {
    const styles = [
      { bg: 'bg-blue-50/80 dark:bg-blue-950/20 text-blue-600 dark:text-blue-400 border-blue-200/50 dark:border-blue-900/30' },
      { bg: 'bg-teal-50/80 dark:bg-teal-950/20 text-teal-600 dark:text-teal-400 border-teal-200/50 dark:border-teal-900/30' },
      { bg: 'bg-indigo-50/80 dark:bg-indigo-950/20 text-indigo-600 dark:text-indigo-400 border-indigo-200/50 dark:border-indigo-900/30' },
      { bg: 'bg-purple-50/80 dark:bg-purple-950/20 text-purple-600 dark:text-purple-400 border-purple-200/50 dark:border-purple-900/30' },
      { bg: 'bg-pink-50/80 dark:bg-pink-950/20 text-pink-600 dark:text-pink-400 border-pink-200/50 dark:border-pink-900/30' },
    ];
    const index = id.split('').reduce((acc, char) => acc + char.charCodeAt(0), 0) % styles.length;
    return styles[index];
  };

  const getSpecialty = (email: string = '') => {
    const lower = email.toLowerCase();
    if (lower.includes('cardio') || lower.includes('1')) return 'Cardiology';
    if (lower.includes('pedia') || lower.includes('2')) return 'Pediatrics';
    if (lower.includes('neuro') || lower.includes('3')) return 'Neurology';
    if (lower.includes('ortho') || lower.includes('4')) return 'Orthopedics';
    if (lower.includes('derma') || lower.includes('5')) return 'Dermatology';
    return 'General Medicine';
  };

  const getAvailabilitySummary = (id: string) => {
    const index = id.split('').reduce((acc, char) => acc + char.charCodeAt(0), 0) % 3;
    if (index === 0) return 'Mon - Fri • 08:00 - 17:00';
    if (index === 1) return 'Mon, Wed, Fri • 09:00 - 16:30';
    return 'Tue, Thu • 08:30 - 17:00';
  };

  // Load doctor's weekly schedule
  const loadDoctorSchedule = async (doctorId: string) => {
    setLoadingSchedule(true);
    try {
      const res = await api.get(`/doctors/${doctorId}/availability`);
      const sorted = [...(res.data.data || [])].sort((a: any, b: any) => {
        const valA = a.dayOfWeek === 0 ? 7 : a.dayOfWeek;
        const valB = b.dayOfWeek === 0 ? 7 : b.dayOfWeek;
        return valA - valB;
      });
      setDoctorSchedule(sorted);
    } catch (err) {
      console.error('Error loading schedule:', err);
    } finally {
      setLoadingSchedule(false);
    }
  };

  const DAY_NAMES = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

  // Get the next date for a given day of week
  const getNextDateForDay = (dayOfWeek: number): string => {
    const today = new Date();
    const todayDay = today.getDay();
    let daysUntil = dayOfWeek - todayDay;
    if (daysUntil <= 0) daysUntil += 7;
    const nextDate = new Date(today);
    nextDate.setDate(today.getDate() + daysUntil);
    return nextDate.toISOString().split('T')[0];
  };

  // Load available time slots dynamically for a specific date
  const loadAvailableTimeSlots = async (date: string, doctorId: string) => {
    if (!date || !doctorId) return;
    setLoadingSlots(true);
    setSelectedSlot(null);
    setBookingStartTime('');
    setBookingEndTime('');
    setBookingError(null);
    setAvailableSlots([]);

    try {
      const selectedDayOfWeek = new Date(date).getDay();

      // Fetch doctor's availability
      const availRes = await api.get(`/doctors/${doctorId}/availability`);
      const doctorAvails = availRes.data.data || [];
      const dayAvail = doctorAvails.find((da: any) => da.dayOfWeek === selectedDayOfWeek);

      if (!dayAvail || !dayAvail.isAvailable) {
        setAvailableSlots([]);
        setLoadingSlots(false);
        return;
      }

      // Fetch booked slots for date
      const apptsRes = await api.get(`/Appointments?doctorId=${doctorId}&startDate=${date}&endDate=${date}&pageSize=100`);
      const bookedAppts = apptsRes.data.data || [];

      // Calculate 30-min slots
      const startMin = timeToMinutes(dayAvail.startTime);
      const endMin = timeToMinutes(dayAvail.endTime);
      const list = [];

      for (let time = startMin; time + 30 <= endMin; time += 30) {
        const slotStart = minutesToTime(time);
        const slotEnd = minutesToTime(time + 30);

        const isBooked = bookedAppts.some((appt: any) => {
          if (appt.status === 'Cancelled') return false;
          const apptStartMin = timeToMinutes(appt.startTime);
          const apptEndMin = timeToMinutes(appt.endTime);
          return (
            (time >= apptStartMin && time < apptEndMin) ||
            (time + 30 > apptStartMin && time + 30 <= apptEndMin) ||
            (time <= apptStartMin && time + 30 >= apptEndMin)
          );
        });

        list.push({ start: slotStart, end: slotEnd, isBooked });
      }

      setAvailableSlots(list);
    } catch (err) {
      console.error('Error loading availability slots:', err);
      setBookingError('Could not load appointment slots for this date.');
    } finally {
      setLoadingSlots(false);
    }
  };

  const handleBack = () => {
    setSelectedPerson(null);
    if (selectedDoctorId) {
      router.push('/doctors');
    }
  };

  const handleBookingSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedPerson) return;
    
    setBookingError(null);

    if (!bookingDate) {
      setBookingError('Please select a date.');
      return;
    }

    if (!bookingStartTime || !bookingEndTime) {
      setBookingError('Please pick an available time slot card.');
      return;
    }

    setBookingLoading(true);
    try {
      await appointmentRepo.createAppointment({
        doctorId: selectedPerson.id,
        appointmentDate: bookingDate,
        startTime: `${bookingStartTime}:00`,
        endTime: `${bookingEndTime}:00`,
        reason: bookingReason,
        notes: bookingNotes || undefined
      });

      alert('Appointment requested successfully! Please complete your payment on the billing page to confirm your booking.');
      
      setBookingDate('');
      setBookingReason('');
      setBookingNotes('');
      setActiveTab('details');
      setIsModalOpen(false);
      setSelectedPerson(null);

      router.push('/billing');
    } catch (err: any) {
      console.error('Error booking appointment:', err);
      setBookingError(err?.response?.data?.message || 'Failed to book appointment. Doctor may be unavailable.');
    } finally {
      setBookingLoading(false);
    }
  };

  const handleOpenDetails = (person: any) => {
    setSelectedPerson(person);
    setBookingError(null);
    setBookingDate('');
    setBookingStartTime('');
    setBookingEndTime('');
    setBookingReason('');
    setBookingNotes('');
    setAvailableSlots([]);
    setSelectedSlot(null);
    setSelectedDay(null);
    setDoctorSchedule([]);
    setIsModalOpen(true);

    if (role === 'Doctor') {
      loadDoctorSchedule(person.id);
    }
  };

  return (
    <div className="space-y-6">
      {!selectedPerson ? (
        <>
          {/* Page Header */}
          <div>
            <h1 className="text-3xl font-black text-secondary-900 dark:text-white tracking-tight">{title}</h1>
            <p className="text-secondary-500 mt-1.5 font-medium italic opacity-70">{description}</p>
          </div>

          {/* Filter Panel */}
          <div className="glass-card p-4 border-none shadow-sm flex flex-col sm:flex-row items-stretch sm:items-center justify-between gap-4 bg-white/50 dark:bg-slate-900/30 backdrop-blur-md rounded-2xl">
            <div className="relative flex-1 group">
              <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-secondary-400 group-focus-within:text-primary-500 transition-colors" />
              <input 
                type="text" 
                placeholder={`Search ${title.toLowerCase()} by name or email...`} 
                value={search}
                onChange={(e) => { setSearch(e.target.value); setCurrentPage(1); }}
                className="input-field !pl-10.5 w-full text-xs shadow-inner bg-slate-50/50 dark:bg-slate-950/40"
              />
            </div>
            
            {/* Toggle Status Chips */}
            <div className="flex items-center space-x-1.5 shrink-0 self-end sm:self-auto select-none">
              <span className="text-[10px] font-black text-secondary-400 dark:text-secondary-500 uppercase tracking-widest mr-1.5 hidden md:inline">
                Status
              </span>
              {['All', 'Active', 'Inactive'].map((status) => (
                <button
                  key={status}
                  onClick={() => { setStatusFilter(status); setCurrentPage(1); }}
                  className={cn(
                    "px-3.5 py-1.5 rounded-xl text-xs font-bold border transition-all cursor-pointer",
                    statusFilter === status
                      ? "bg-primary-500 border-primary-500 text-white shadow-md shadow-primary-500/10"
                      : "border-slate-200 dark:border-slate-800 text-secondary-700 dark:text-slate-400 hover:bg-slate-50 dark:hover:bg-slate-900/60"
                  )}
                >
                  {status}
                </button>
              ))}
            </div>
          </div>

          {/* Grid List */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {loading ? (
              [1, 2, 3].map(i => <div key={i} className="h-56 animate-shimmer rounded-2xl bg-slate-100 dark:bg-slate-900/30" />)
            ) : people.length === 0 ? (
              <div className="col-span-full py-16 text-center text-secondary-500 bg-white/30 dark:bg-slate-900/20 backdrop-blur-md rounded-3xl border border-secondary-200/20 dark:border-slate-850">
                <User className="w-10 h-10 mx-auto mb-3 text-secondary-300 dark:text-secondary-700" />
                <p className="font-bold">No {title.toLowerCase()} found</p>
              </div>
            ) : (
              people.map((p) => {
                const avatar = getAvatarStyle(p.id);
                const specialty = getSpecialty(p.email);
                const inlineHours = getAvailabilitySummary(p.id);

                return (
                  <Card key={p.id} className="p-6 border-none shadow-sm hover:shadow-xl hover:-translate-y-1 transition-all duration-350 bg-white/40 dark:bg-slate-900/40 backdrop-blur-md relative overflow-hidden group flex flex-col justify-between min-h-[240px]">
                    <div>
                      {/* Card Header (Avatar & Status) */}
                      <div className="flex items-start justify-between">
                        <div className={cn(
                          "w-12 h-12 rounded-2xl border-2 flex items-center justify-center text-xs font-black shadow-inner",
                          avatar.bg
                        )}>
                          {getInitials(p.firstName, p.lastName)}
                        </div>
                        <div className={cn(
                          "px-2.5 py-0.5 rounded-full text-[9px] font-extrabold uppercase tracking-wider",
                          p.isActive 
                            ? 'bg-emerald-50 dark:bg-emerald-950/20 text-emerald-700 dark:text-emerald-400' 
                            : 'bg-secondary-100 text-secondary-700 dark:bg-slate-800 dark:text-secondary-400'
                        )}>
                           {p.isActive ? 'Active' : 'Inactive'}
                        </div>
                      </div>

                      {/* Clinician Information */}
                      <div className="mt-4">
                        <h3 className="text-base font-black text-secondary-900 dark:text-white group-hover:text-primary-600 transition-colors truncate">
                          {p.firstName} {p.lastName}
                        </h3>
                        
                        {role === 'Doctor' ? (
                          <span className="inline-block mt-1 px-2.5 py-0.5 bg-primary-50 dark:bg-primary-950/20 text-primary-600 dark:text-primary-400 text-[9px] font-black uppercase tracking-wider rounded-lg">
                            {specialty}
                          </span>
                        ) : (
                          <span className="inline-block mt-1 px-2.5 py-0.5 bg-teal-50 dark:bg-teal-950/20 text-teal-600 dark:text-teal-400 text-[9px] font-black uppercase tracking-wider rounded-lg">
                            Nursing Care
                          </span>
                        )}
                      </div>

                      {/* Contact details */}
                      <div className="mt-4 pt-4 border-t border-slate-200/20 dark:border-slate-800/40 space-y-2">
                        <div className="flex items-center text-xs text-secondary-650 dark:text-slate-350 font-semibold">
                          <Mail className="w-3.5 h-3.5 mr-2.5 text-secondary-400 shrink-0" />
                          <span className="truncate">{p.email}</span>
                        </div>
                        <div className="flex items-center text-xs text-secondary-650 dark:text-slate-350 font-semibold">
                           <Phone className="w-3.5 h-3.5 mr-2.5 text-secondary-400 shrink-0" />
                           <span>{p.phoneNumber || '+1 (555) 000-0000'}</span>
                        </div>
                        
                        {role === 'Doctor' && (
                          <div className="flex items-center text-xs text-secondary-650 dark:text-slate-350 font-semibold">
                            <Clock className="w-3.5 h-3.5 mr-2.5 text-primary-500 shrink-0" />
                            <span className="text-[10px] text-primary-600 dark:text-primary-400 uppercase tracking-wide font-bold">
                              {inlineHours}
                            </span>
                          </div>
                        )}
                      </div>
                    </div>

                    {/* Card Actions */}
                    <div className="mt-5 pt-2">
                      {role === 'Doctor' && currentUser?.role === 'Patient' ? (
                        <button 
                          onClick={() => router.push(`/doctors/${p.id}`)}
                          className="w-full py-2 rounded-xl bg-gradient-to-r from-primary-600 to-primary-750 hover:from-primary-500 hover:to-primary-650 text-xs font-extrabold text-white shadow-md shadow-primary-600/15 hover:scale-[1.01] transition-all cursor-pointer text-center"
                        >
                          Book Appointment
                        </button>
                      ) : (
                        <button 
                          onClick={() => {
                            if (role === 'Doctor') {
                              router.push(`/doctors/${p.id}`);
                            } else {
                              handleOpenDetails(p);
                            }
                          }}
                          className={cn(
                            "w-full py-2 rounded-xl bg-secondary-100/50 dark:bg-slate-800/40 text-xs font-bold text-secondary-700 dark:text-secondary-300 hover:bg-secondary-200 dark:hover:bg-slate-700/60 transition-all cursor-pointer shadow-sm text-center"
                          )}
                        >
                          View Details
                        </button>
                      )}
                    </div>
                  </Card>
                );
              })
            )}
          </div>

          {/* Pagination Controls */}
          {people.length > 0 && totalPages > 1 && (
            <div className="flex flex-col sm:flex-row items-center justify-between p-5 bg-white/40 dark:bg-slate-900/30 border border-secondary-200/20 dark:border-slate-850 backdrop-blur-md rounded-2xl shadow-sm gap-4 mt-6">
              <p className="text-xs text-secondary-500 font-semibold">
                Showing <span className="font-bold text-secondary-900 dark:text-white">{Math.min(startIndex + 1, totalCount)}</span> to <span className="font-bold text-secondary-900 dark:text-white">{Math.min(endIndex, totalCount)}</span> of <span className="font-bold text-secondary-900 dark:text-white">{totalCount}</span> staff
              </p>
              
              <div className="flex items-center space-x-1.5">
                <button
                  disabled={currentPage === 1}
                  onClick={() => setCurrentPage(currentPage - 1)}
                  className="px-3.5 py-2 text-xs font-bold border border-secondary-200 dark:border-slate-800 rounded-xl hover:bg-secondary-50 dark:hover:bg-slate-800 disabled:opacity-50 disabled:pointer-events-none transition-all text-secondary-700 dark:text-secondary-300 cursor-pointer"
                >
                  Previous
                </button>
                
                <div className="flex items-center space-x-1">
                  {getPageNumbers().map((page, idx) => {
                    if (page === '...') {
                      return (
                        <span key={`ellipsis-${idx}`} className="px-2 text-xs font-bold text-secondary-400">
                          ...
                        </span>
                      );
                    }
                    return (
                      <button
                        key={page}
                        onClick={() => setCurrentPage(page as number)}
                        className={`w-8 h-8 rounded-xl text-xs font-bold transition-all duration-350 cursor-pointer ${
                          currentPage === page 
                            ? 'bg-primary-600 text-white shadow-md' 
                            : 'text-secondary-550 hover:bg-secondary-50 dark:hover:bg-slate-800 dark:text-secondary-400'
                        }`}
                      >
                        {page}
                      </button>
                    );
                  })}
                </div>

                <button
                  disabled={currentPage === totalPages}
                  onClick={() => setCurrentPage(currentPage + 1)}
                  className="px-3.5 py-2 text-xs font-bold border border-secondary-200 dark:border-slate-800 rounded-xl hover:bg-secondary-50 dark:hover:bg-slate-800 disabled:opacity-50 disabled:pointer-events-none transition-all text-secondary-700 dark:text-secondary-300 cursor-pointer"
                >
                  Next
                </button>
              </div>
            </div>
          )}
        </>
      ) : (
        /* Unified Profile & Booking Sub-Page View (Inline, NO Modal) */
        <div className="animate-fadeIn duration-250 max-w-5xl mx-auto space-y-6">
          {/* Back button */}
          <button
            onClick={handleBack}
            className="flex items-center space-x-2 text-xs font-bold text-primary-600 dark:text-primary-400 hover:text-primary-500 transition-colors cursor-pointer group"
          >
            <svg className="w-4 h-4 transform group-hover:-translate-x-0.5 transition-transform" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2.5}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M15 19l-7-7 7-7" />
            </svg>
            <span>Back to Directory</span>
          </button>

          {role === 'Doctor' && currentUser?.role === 'Patient' ? (
            /* Two Column Split Grid for Doctors Booking */
            <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">
              
              {/* Left Column: Doctor Bio & Profile Info */}
              <div className="lg:col-span-5 space-y-6">
                <Card className="border-none shadow-md bg-white/60 dark:bg-slate-900/30 backdrop-blur-md rounded-3xl overflow-hidden p-0 flex flex-col">
                  {/* Header Cover Banner */}
                  <div className="h-28 bg-gradient-to-r from-primary-600 via-primary-750 to-teal-850 relative">
                    <div className="absolute -bottom-8 left-6 w-16 h-16 rounded-2xl border-4 border-white dark:border-slate-950 bg-primary-50/50 dark:bg-slate-900/30 flex items-center justify-center text-primary-600 dark:text-primary-400 shadow-md">
                      <span className="text-base font-black">
                        {getInitials(selectedPerson.firstName, selectedPerson.lastName)}
                      </span>
                    </div>
                  </div>

                  <div className="px-6 pt-12 pb-6 space-y-4">
                    <div>
                      <div className="flex items-center space-x-2.5">
                        <h2 className="text-xl font-black text-secondary-900 dark:text-white leading-tight">
                          {selectedPerson.firstName} {selectedPerson.lastName}
                        </h2>
                        <span className={cn(
                          "px-2 py-0.5 rounded-full text-[8px] font-extrabold uppercase tracking-wider",
                          selectedPerson.isActive 
                            ? 'bg-emerald-50 dark:bg-emerald-950/20 text-emerald-800 dark:text-emerald-400' 
                            : 'bg-red-50 dark:bg-red-950/20 text-red-800 dark:text-red-400'
                        )}>
                          {selectedPerson.isActive ? 'Active' : 'Inactive'}
                        </span>
                      </div>
                      <p className="inline-block mt-1 px-2.5 py-0.5 bg-primary-50 dark:bg-primary-950/20 text-primary-600 dark:text-primary-400 text-[10px] font-black uppercase tracking-wider rounded-lg">
                        {getSpecialty(selectedPerson.email)} Specialist
                      </p>
                    </div>

                    {/* Premium stats display */}
                    <div className="grid grid-cols-2 gap-3 pt-2 border-t border-slate-100 dark:border-slate-800/40">
                      <div className="p-3 bg-slate-50/50 dark:bg-slate-950/20 rounded-xl text-center">
                        <p className="text-[10px] font-bold text-secondary-400 uppercase tracking-widest">Experience</p>
                        <p className="text-sm font-black text-secondary-900 dark:text-white mt-0.5">12+ Years</p>
                      </div>
                      <div className="p-3 bg-slate-50/50 dark:bg-slate-950/20 rounded-xl text-center">
                        <p className="text-[10px] font-bold text-secondary-400 uppercase tracking-widest">Rating</p>
                        <p className="text-sm font-black text-primary-500 mt-0.5">★ 4.9 (140+)</p>
                      </div>
                    </div>
                  </div>
                </Card>

                {/* Contact Information */}
                <Card className="border-none shadow-md bg-white/60 dark:bg-slate-900/30 backdrop-blur-md rounded-3xl p-5 space-y-3.5">
                  <h4 className="text-[10px] font-black text-secondary-400 dark:text-secondary-500 uppercase tracking-widest">Contact Information</h4>
                  <div className="space-y-3">
                    <div className="flex items-center text-xs font-semibold text-secondary-700 dark:text-slate-350">
                      <div className="w-8 h-8 rounded-lg bg-slate-100 dark:bg-slate-800/60 flex items-center justify-center mr-3 text-secondary-400 shrink-0">
                        <Mail className="w-4 h-4" />
                      </div>
                      <span className="truncate">{selectedPerson.email}</span>
                    </div>
                    <div className="flex items-center text-xs font-semibold text-secondary-700 dark:text-slate-350">
                      <div className="w-8 h-8 rounded-lg bg-slate-100 dark:bg-slate-800/60 flex items-center justify-center mr-3 text-secondary-400 shrink-0">
                        <Phone className="w-4 h-4" />
                      </div>
                      <span>{selectedPerson.phoneNumber || '+1 (555) 000-0000'}</span>
                    </div>
                  </div>
                </Card>
              </div>

              {/* Right Column: Dynamic Booking Form Card */}
              <div className="lg:col-span-7">
                <Card className="border-none shadow-md bg-white/60 dark:bg-slate-900/30 backdrop-blur-md rounded-3xl p-6 space-y-5">
                  <div className="pb-3 border-b border-slate-100 dark:border-slate-800/40">
                    <h3 className="text-sm font-black text-secondary-900 dark:text-white uppercase tracking-wider">Book an Appointment</h3>
                    <p className="text-[11px] text-secondary-400 font-semibold mt-0.5">Select a date and open time slot to register your visit.</p>
                  </div>

                  {/* Date Picker (Horizontal Cards of Next 14 Days) */}
                  <div className="space-y-2">
                    <div className="flex items-center justify-between">
                      <label className="block text-[10px] font-black text-secondary-400 dark:text-secondary-500 uppercase tracking-widest">
                        Select Booking Date
                      </label>
                      <button
                        type="button"
                        onClick={() => {
                          setBookingDate('');
                          setAvailableSlots([]);
                        }}
                        className="text-[9px] font-bold text-primary-600 dark:text-primary-400 hover:underline cursor-pointer"
                      >
                        Reset / Custom Date
                      </button>
                    </div>

                    <div className="flex space-x-2.5 overflow-x-auto pb-2.5 pt-1 px-1 scrollbar-thin">
                      {Array.from({ length: 10 }).map((_, i) => {
                        const dateObj = new Date();
                        dateObj.setDate(dateObj.getDate() + i);
                        const dateStr = dateObj.toISOString().split('T')[0];
                        const dayOfWeek = dateObj.getDay();
                        const isSelected = bookingDate === dateStr;

                        const scheduleRule = doctorSchedule.find(s => s.dayOfWeek === dayOfWeek);
                        const isAvailableDay = scheduleRule ? scheduleRule.isAvailable : true;

                        const dayLabel = DAY_NAMES[dayOfWeek];
                        const formattedLabel = `${dateObj.getDate().toString().padStart(2, '0')}/${(dateObj.getMonth() + 1).toString().padStart(2, '0')}/${dateObj.getFullYear()}`;

                        return (
                          <button
                            key={dateStr}
                            type="button"
                            onClick={() => {
                              if (!isAvailableDay) return;
                              setBookingDate(dateStr);
                              loadAvailableTimeSlots(dateStr, selectedPerson.id);
                            }}
                            className={cn(
                              "flex flex-col items-center justify-between p-3 rounded-2xl border min-w-[105px] text-center transition-all shrink-0 select-none",
                              !isAvailableDay
                                ? "bg-slate-50 dark:bg-slate-900/20 border-slate-100 dark:border-slate-800/30 opacity-40 cursor-not-allowed"
                                : isSelected
                                  ? "bg-primary-500 border-primary-500 text-white shadow-lg shadow-primary-500/15 scale-[1.03] cursor-pointer"
                                  : "border-slate-200 dark:border-slate-800 hover:border-primary-400 hover:bg-primary-50/20 bg-white/40 dark:bg-slate-900/10 cursor-pointer"
                            )}
                          >
                            <span className={cn(
                              "text-[10px] font-black uppercase tracking-wider",
                              isSelected ? "text-primary-100" : "text-secondary-400"
                            )}>
                              {dayLabel.slice(0, 3)}
                            </span>
                            <span className="text-xs font-black mt-1">
                              {formattedLabel.slice(0, 5)}
                            </span>
                            <span className={cn(
                              "text-[8px] font-extrabold uppercase mt-1 px-1.5 py-0.5 rounded-md",
                              !isAvailableDay
                                ? "bg-slate-200 dark:bg-slate-800 text-slate-500"
                                : isSelected
                                  ? "bg-primary-600 text-white"
                                  : "bg-emerald-50 dark:bg-emerald-950/20 text-emerald-600"
                            )}>
                              {isAvailableDay ? "Open" : "Closed"}
                            </span>
                          </button>
                        );
                      })}
                    </div>
                  </div>

                  {/* Time Slots Selection */}
                  {bookingDate && (
                    <div className="space-y-2 animate-fadeIn duration-200">
                      <div className="flex items-center justify-between">
                        <label className="block text-[10px] font-black text-secondary-400 dark:text-secondary-500 uppercase tracking-widest">
                          Select Time Slot
                        </label>
                        {availableSlots.length > 0 && !loadingSlots && (
                          <span className="text-[9px] font-bold text-secondary-400 dark:text-secondary-600">
                            {availableSlots.filter(s => !s.isBooked).length} available
                          </span>
                        )}
                      </div>
                      
                      {loadingSlots ? (
                        <div className="py-6 flex flex-col items-center justify-center space-y-2">
                          <div className="w-6 h-6 border-2 border-primary-500 border-t-transparent rounded-full animate-spin" />
                          <span className="text-[10px] text-secondary-500 font-semibold italic">Loading slots...</span>
                        </div>
                      ) : availableSlots.length > 0 ? (
                        <div className="grid grid-cols-2 gap-2.5 max-h-[160px] overflow-y-auto p-1.5 border border-slate-200/50 dark:border-slate-800/40 rounded-2xl bg-slate-50/20 dark:bg-slate-900/10">
                          {availableSlots.map((slot) => {
                            const slotKey = `${slot.start}-${slot.end}`;
                            const isSelected = selectedSlot === slotKey;
                            return (
                              <button
                                key={slotKey}
                                type="button"
                                disabled={slot.isBooked}
                                onClick={() => {
                                  setSelectedSlot(slotKey);
                                  setBookingStartTime(slot.start);
                                  setBookingEndTime(slot.end);
                                  setBookingError(null);
                                }}
                                className={cn(
                                  "px-3 py-2.5 rounded-xl border text-center text-xs font-bold transition-all select-none flex items-center justify-center space-x-2",
                                  slot.isBooked
                                    ? "bg-slate-100/50 dark:bg-slate-900/40 text-slate-400 dark:text-slate-750 border-slate-200/40 dark:border-slate-800/30 cursor-not-allowed line-through"
                                    : isSelected
                                      ? "bg-primary-500 border-primary-500 text-white shadow-md shadow-primary-500/15 scale-[1.03] cursor-pointer"
                                      : "border-slate-200 dark:border-slate-800 hover:border-primary-400 hover:bg-primary-50/20 text-secondary-900 dark:text-white cursor-pointer"
                                )}
                              >
                                <span>{formatTimeTo12Hour(slot.start)} – {formatTimeTo12Hour(slot.end)}</span>
                              </button>
                            );
                          })}
                        </div>
                      ) : (
                        <div className="p-4 bg-amber-50/50 dark:bg-amber-950/10 border border-amber-200/50 dark:border-amber-900/30 rounded-2xl text-center">
                          <p className="text-xs text-amber-700 dark:text-amber-400 font-bold">Doctor is not available on this day.</p>
                        </div>
                      )}
                    </div>
                  )}

                  {/* Reason */}
                  <div>
                    <label className="block text-[10px] font-black text-secondary-400 dark:text-secondary-500 uppercase tracking-widest mb-1.5">
                      Reason for Visit
                    </label>
                    <textarea
                      rows={2}
                      value={bookingReason}
                      onChange={(e) => { setBookingReason(e.target.value); setBookingError(null); }}
                      required
                      placeholder="e.g. Health Consult, Specialist checkup..."
                      className="w-full bg-slate-50/50 dark:bg-slate-900/35 px-4 py-2.5 rounded-xl text-xs focus:outline-none focus:ring-2 focus:ring-primary-500/10 border border-slate-200 dark:border-slate-800 dark:text-white font-semibold transition-all resize-none placeholder-secondary-450"
                    />
                  </div>

                  {/* Notes */}
                  <div>
                    <label className="block text-[10px] font-black text-secondary-400 dark:text-secondary-500 uppercase tracking-widest mb-1.5">
                      Notes / Symptoms (Optional)
                    </label>
                    <textarea
                      rows={2}
                      value={bookingNotes}
                      onChange={(e) => setBookingNotes(e.target.value)}
                      placeholder="Add any notes for the doctor..."
                      className="w-full bg-slate-50/50 dark:bg-slate-900/35 px-4 py-2.5 rounded-xl text-xs focus:outline-none focus:ring-2 focus:ring-primary-500/10 border border-slate-200 dark:border-slate-800 dark:text-white font-semibold transition-all resize-none placeholder-secondary-450"
                    />
                  </div>

                  {/* Action Buttons */}
                  <div className="pt-4 border-t border-slate-100 dark:border-slate-800/40 flex space-x-3">
                    <button 
                      type="button"
                      onClick={handleBack}
                      className="flex-1 py-3 rounded-2xl border border-slate-200 dark:border-slate-850 hover:bg-slate-50 dark:hover:bg-slate-900/50 text-xs font-bold text-secondary-700 dark:text-secondary-300 transition-colors cursor-pointer"
                    >
                      Cancel
                    </button>
                    <button 
                      type="button"
                      onClick={handleBookingSubmit}
                      disabled={bookingLoading}
                      className="flex-1 py-3 bg-gradient-to-r from-primary-600 to-primary-750 hover:from-primary-500 hover:to-primary-650 rounded-2xl text-xs font-extrabold text-white shadow-md shadow-primary-600/15 hover:shadow-lg transition-all cursor-pointer text-center"
                    >
                      {bookingLoading ? 'Confirming...' : 'Confirm Booking'}
                    </button>
                  </div>
                </Card>
              </div>
            </div>
          ) : (
            /* Profile & Availability Details Card (Standard/Read-only view for others e.g. Nurses) */
            <Card className="border-none shadow-xl bg-white/70 dark:bg-slate-900/35 backdrop-blur-md rounded-3xl overflow-hidden p-0 flex flex-col max-w-xl mx-auto">
              {/* Header Cover Banner */}
              <div className="h-32 bg-gradient-to-r from-primary-600 via-primary-750 to-teal-850 relative">
                <div className="absolute -bottom-10 left-6 w-20 h-20 rounded-2xl border-4 border-white dark:border-slate-950 bg-primary-50/50 dark:bg-slate-900/30 flex items-center justify-center text-primary-600 dark:text-primary-400 shadow-md">
                  <span className="text-lg font-black">
                    {getInitials(selectedPerson.firstName, selectedPerson.lastName)}
                  </span>
                </div>
              </div>

              <div className="px-6 pt-14 pb-6 space-y-6">
                <div>
                  <div className="flex items-center space-x-3">
                    <h2 className="text-2xl font-black text-secondary-900 dark:text-white leading-tight">
                      {selectedPerson.firstName} {selectedPerson.lastName}
                    </h2>
                    <span className={cn(
                      "px-2.5 py-0.5 rounded-full text-[9px] font-extrabold uppercase tracking-wider",
                      selectedPerson.isActive 
                        ? 'bg-emerald-50 dark:bg-emerald-950/20 text-emerald-800 dark:text-emerald-400' 
                        : 'bg-red-50 dark:bg-red-950/20 text-red-800 dark:text-red-400'
                    )}>
                      {selectedPerson.isActive ? 'Active' : 'Inactive'}
                    </span>
                  </div>
                  
                  {role === 'Doctor' ? (
                    <p className="inline-block mt-1.5 px-2.5 py-0.5 bg-primary-50 dark:bg-primary-950/20 text-primary-600 dark:text-primary-400 text-[10px] font-black uppercase tracking-wider rounded-lg">
                      {getSpecialty(selectedPerson.email)} Specialist
                    </p>
                  ) : (
                    <p className="inline-block mt-1.5 px-2.5 py-0.5 bg-teal-50 dark:bg-teal-950/20 text-teal-600 dark:text-teal-400 text-[10px] font-black uppercase tracking-wider rounded-lg">
                      Nursing Staff Care
                    </p>
                  )}
                </div>

                <div className="space-y-5">
                  {/* Contact Info Card */}
                  <div className="p-4 bg-secondary-50/50 dark:bg-slate-900/30 border border-secondary-200/20 dark:border-slate-800/40 rounded-2xl space-y-3 shadow-inner">
                    <h4 className="text-[10px] font-black text-secondary-400 dark:text-secondary-500 uppercase tracking-widest">Contact Information</h4>
                    <div className="flex items-center text-xs font-semibold text-secondary-700 dark:text-slate-350">
                      <Mail className="w-4 h-4 mr-3 text-secondary-400 shrink-0" />
                      <span className="truncate">{selectedPerson.email}</span>
                    </div>
                    <div className="flex items-center text-xs font-semibold text-secondary-700 dark:text-slate-350">
                      <Phone className="w-4 h-4 mr-3 text-secondary-400 shrink-0" />
                      <span>{selectedPerson.phoneNumber || '+1 (555) 000-0000'}</span>
                    </div>
                  </div>

                  {/* Doctor Availability - Read Only */}
                  {role === 'Doctor' && (
                    <div className="mt-4 pt-4 border-t border-slate-200/20 dark:border-slate-800/40">
                      <h4 className="text-[10px] font-black text-secondary-400 dark:text-secondary-500 uppercase tracking-widest flex items-center mb-3">
                        <Calendar className="w-3.5 h-3.5 mr-2 text-primary-500" />
                        Weekly Availability
                      </h4>
                      <ReadOnlyAvailability doctorId={selectedPerson.id} />
                    </div>
                  )}
                </div>

                {/* Back to Directory Button */}
                <div className="pt-6 border-t border-slate-200/20 dark:border-slate-800/40">
                  <button 
                    onClick={handleBack}
                    className="w-full py-3 rounded-2xl border border-secondary-200 dark:border-slate-800 hover:bg-secondary-50 dark:hover:bg-slate-900/50 text-xs font-bold text-secondary-700 dark:text-secondary-300 transition-colors cursor-pointer"
                  >
                    Back to Directory
                  </button>
                </div>
              </div>
            </Card>
          )}
        </div>
      )}
    </div>
  );
};
