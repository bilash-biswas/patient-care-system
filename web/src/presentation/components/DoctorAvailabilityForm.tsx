'use client';

import React, { useEffect, useState } from 'react';
import { Calendar, Clock, Save, AlertCircle, CheckCircle2, Copy, ShieldAlert } from 'lucide-react';
import api from '@/core/api';
import { Button } from '@/presentation/components/Button';

interface DoctorAvailability {
  dayOfWeek: number;
  startTime: string;
  endTime: string;
  isAvailable: boolean;
}

interface DoctorAvailabilityFormProps {
  doctorId: string;
  viewOnly?: boolean;
}

const DAY_NAMES = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

export const DoctorAvailabilityForm = ({ doctorId, viewOnly = false }: DoctorAvailabilityFormProps) => {
  const [schedule, setSchedule] = useState<DoctorAvailability[]>([]);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [message, setMessage] = useState<{ text: string; type: 'success' | 'error' } | null>(null);

  useEffect(() => {
    const fetchAvailability = async () => {
      setLoading(true);
      try {
        const res = await api.get(`/doctors/${doctorId}/availability`);
        const sorted = [...(res.data.data || [])].sort((a, b) => {
          const valA = a.dayOfWeek === 0 ? 7 : a.dayOfWeek;
          const valB = b.dayOfWeek === 0 ? 7 : b.dayOfWeek;
          return valA - valB;
        });
        setSchedule(sorted);
      } catch (err: any) {
        console.error('Error fetching availability', err);
        setMessage({ text: 'Failed to load doctor availability.', type: 'error' });
      } finally {
        setLoading(false);
      }
    };

    fetchAvailability();
  }, [doctorId]);

  const handleToggleAvailable = (dayOfWeek: number) => {
    if (viewOnly) return;
    setSchedule(
      schedule.map((item) =>
        item.dayOfWeek === dayOfWeek ? { ...item, isAvailable: !item.isAvailable } : item
      )
    );
  };

  const handleTimeChange = (dayOfWeek: number, field: 'startTime' | 'endTime', value: string) => {
    if (viewOnly) return;
    setSchedule(
      schedule.map((item) =>
        item.dayOfWeek === dayOfWeek ? { ...item, [field]: value } : item
      )
    );
  };

  const handleCopyToWeekdays = () => {
    const mondayVal = schedule.find((item) => item.dayOfWeek === 1);
    if (!mondayVal) return;
    
    setSchedule(
      schedule.map((item) => {
        // Apply Monday's schedule to Monday(1), Tuesday(2), Wednesday(3), Thursday(4), Friday(5)
        if (item.dayOfWeek >= 1 && item.dayOfWeek <= 5) {
          return {
            ...item,
            isAvailable: mondayVal.isAvailable,
            startTime: mondayVal.startTime,
            endTime: mondayVal.endTime,
          };
        }
        return item;
      })
    );
    
    setMessage({ text: "Copied Monday's hours to all weekdays!", type: 'success' });
    setTimeout(() => setMessage(null), 3000);
  };

  const handleCloseWeekends = () => {
    setSchedule(
      schedule.map((item) => {
        // Set Saturday(6) and Sunday(0) to unavailable
        if (item.dayOfWeek === 6 || item.dayOfWeek === 0) {
          return { ...item, isAvailable: false };
        }
        return item;
      })
    );
    setMessage({ text: 'Closed weekends (Saturday & Sunday)', type: 'success' });
    setTimeout(() => setMessage(null), 3000);
  };

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    if (viewOnly) return;
    setSaving(true);
    setMessage(null);

    try {
      await api.put(`/doctors/${doctorId}/availability`, schedule);
      setMessage({ text: 'Weekly availability schedule saved successfully!', type: 'success' });
      setTimeout(() => setMessage(null), 4000);
    } catch (err: any) {
      console.error('Error saving availability', err);
      setMessage({
        text: err.response?.data?.message || 'Failed to save schedule settings.',
        type: 'error',
      });
    } finally {
      setSaving(false);
    }
  };

  const timeOptions = (() => {
    const options = [];
    for (let h = 0; h < 24; h++) {
      const hh = h.toString().padStart(2, '0');
      options.push(`${hh}:00`);
      options.push(`${hh}:30`);
    }
    return options;
  })();

  if (loading) {
    return (
      <div className="space-y-4 py-6">
        <h4 className="text-[10px] font-black text-secondary-400 dark:text-secondary-500 uppercase tracking-widest animate-pulse">
          Loading availability schedule...
        </h4>
        {[1, 2, 3].map((i) => (
          <div key={i} className="h-12 bg-slate-100 dark:bg-slate-900/30 animate-shimmer rounded-xl" />
        ))}
      </div>
    );
  }

  return (
    <div className="space-y-5 py-2">
      {/* Header & Quick Action Buttons */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pb-3 border-b border-slate-100 dark:border-slate-800/40">
        <h4 className="text-[10px] font-black text-secondary-400 dark:text-secondary-500 uppercase tracking-widest flex items-center">
          <Calendar className="w-3.5 h-3.5 mr-2 text-primary-500" />
          Weekly Availability Schedule
        </h4>

        {!viewOnly && schedule.length > 0 && (
          <div className="flex space-x-2">
            <button
              type="button"
              onClick={handleCopyToWeekdays}
              className="px-2.5 py-1.5 bg-slate-100 hover:bg-slate-200 dark:bg-slate-800 dark:hover:bg-slate-700/80 text-[10px] font-bold rounded-lg text-slate-700 dark:text-slate-350 transition-colors flex items-center cursor-pointer border border-transparent dark:border-slate-800/60"
            >
              <Copy className="w-3 h-3 mr-1" />
              Copy Mon to Weekdays
            </button>
            <button
              type="button"
              onClick={handleCloseWeekends}
              className="px-2.5 py-1.5 bg-slate-100 hover:bg-slate-200 dark:bg-slate-800 dark:hover:bg-slate-700/80 text-[10px] font-bold rounded-lg text-slate-700 dark:text-slate-350 transition-colors flex items-center cursor-pointer border border-transparent dark:border-slate-800/60"
            >
              <ShieldAlert className="w-3 h-3 mr-1" />
              Close Weekends
            </button>
          </div>
        )}
      </div>

      {message && (
        <div
          className={`p-3.5 rounded-xl flex items-center space-x-3 text-xs font-bold border transition-all animate-scaleIn ${
            message.type === 'success'
              ? 'bg-emerald-50/10 border-emerald-500/20 text-emerald-600 dark:text-emerald-400'
              : 'bg-red-50/10 border-red-500/20 text-red-600 dark:text-red-400'
          }`}
        >
          {message.type === 'success' ? (
            <CheckCircle2 className="w-4 h-4 shrink-0 text-emerald-500" />
          ) : (
            <AlertCircle className="w-4 h-4 shrink-0 text-red-500" />
          )}
          <span>{message.text}</span>
        </div>
      )}

      <form onSubmit={handleSave} className="space-y-4">
        <div className="space-y-2">
          {schedule.map((item) => (
            <div
              key={item.dayOfWeek}
              className={`p-3 px-4 rounded-xl border transition-all flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3 ${
                item.isAvailable
                  ? 'border-slate-200/60 dark:border-slate-800/60 bg-white/20 dark:bg-slate-900/10 hover:border-slate-300 dark:hover:border-slate-700'
                  : 'border-slate-100/50 dark:border-slate-800/30 bg-slate-50/10 dark:bg-slate-950/5 opacity-70'
              }`}
            >
              {/* Day & Toggle Switch */}
              <div className="flex items-center space-x-4">
                <button
                  type="button"
                  disabled={viewOnly}
                  onClick={() => handleToggleAvailable(item.dayOfWeek)}
                  className={`w-9 h-5.5 flex items-center rounded-full p-0.5 transition-all duration-300 ${
                    viewOnly ? 'cursor-not-allowed' : 'cursor-pointer'
                  } ${item.isAvailable ? 'bg-primary-500' : 'bg-slate-300 dark:bg-slate-850'}`}
                >
                  <div
                    className={`bg-white w-4.5 h-4.5 rounded-full shadow-md transform transition-all duration-350 ${
                      item.isAvailable ? 'translate-x-3.5' : 'translate-x-0'
                    }`}
                  />
                </button>
                <div className="flex items-center space-x-2">
                  <span className="text-xs font-black text-slate-900 dark:text-white uppercase tracking-wider min-w-[72px]">
                    {DAY_NAMES[item.dayOfWeek]}
                  </span>
                  <span
                    className={`px-2 py-0.5 rounded-full text-[9px] font-black uppercase tracking-wider select-none ${
                      item.isAvailable
                        ? 'bg-emerald-50 dark:bg-emerald-950/20 text-emerald-600 dark:text-emerald-400'
                        : 'bg-slate-100 dark:bg-slate-900/60 text-slate-500 dark:text-slate-500'
                    }`}
                  >
                    {item.isAvailable ? 'Open' : 'Closed'}
                  </span>
                </div>
              </div>

              {/* Time Pickers (Pill container) */}
              {item.isAvailable ? (
                <div className="flex items-center space-x-2 w-full sm:w-auto shrink-0 select-none bg-slate-50/80 dark:bg-slate-900/60 border border-slate-200/40 dark:border-slate-800/50 p-1.5 px-3 rounded-xl">
                  <Clock className="w-3.5 h-3.5 text-slate-450 dark:text-slate-500 mr-1" />
                  <select
                    disabled={viewOnly}
                    value={item.startTime}
                    onChange={(e) => handleTimeChange(item.dayOfWeek, 'startTime', e.target.value)}
                    className="bg-transparent text-xs font-bold focus:outline-none text-secondary-900 dark:text-white cursor-pointer select-none"
                  >
                    {timeOptions.map((opt) => (
                      <option key={opt} value={opt} className="bg-white dark:bg-slate-900">
                        {opt}
                      </option>
                    ))}
                  </select>
                  <span className="text-[10px] font-extrabold text-slate-400 dark:text-slate-500 uppercase px-1">
                    to
                  </span>
                  <select
                    disabled={viewOnly}
                    value={item.endTime}
                    onChange={(e) => handleTimeChange(item.dayOfWeek, 'endTime', e.target.value)}
                    className="bg-transparent text-xs font-bold focus:outline-none text-secondary-900 dark:text-white cursor-pointer select-none"
                  >
                    {timeOptions.map((opt) => (
                      <option key={opt} value={opt} className="bg-white dark:bg-slate-900">
                        {opt}
                      </option>
                    ))}
                  </select>
                </div>
              ) : (
                <span className="text-[10px] font-black uppercase tracking-wider text-slate-450 dark:text-slate-600 block sm:text-right pr-4 py-1.5 select-none">
                  Out of Office
                </span>
              )}
            </div>
          ))}
        </div>

        {!viewOnly && (
          <div className="pt-1.5">
            <Button
              type="submit"
              className="w-full flex justify-center py-3.5 rounded-2xl bg-gradient-to-r from-primary-600 to-primary-750 hover:from-primary-500 hover:to-primary-650 text-xs font-black uppercase tracking-wider shadow-lg shadow-primary-500/10 transition-all cursor-pointer"
              isLoading={saving}
            >
              <Save className="w-4 h-4 mr-2" />
              Save Availability Schedule
            </Button>
          </div>
        )}
      </form>
    </div>
  );
};
