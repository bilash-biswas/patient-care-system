'use client';

import React, { useEffect } from 'react';
import { useAppDispatch, useAppSelector } from '@/presentation/store/hooks';
import { fetchMedicalRecords } from '@/presentation/store/slices/medicalRecordSlice';
import { Card } from '@/presentation/components/Card';
import { Button } from '@/presentation/components/Button';
import { 
  Search, 
  Plus, 
  FileText, 
  User,
  Calendar,
  Filter,
  UserCheck
} from 'lucide-react';

export default function MedicalRecordsPage() {
  const dispatch = useAppDispatch();
  const { records, isLoading } = useAppSelector((state) => state.medicalRecords);

  useEffect(() => {
    dispatch(fetchMedicalRecords({}));
  }, [dispatch]);

  const handleSearch = (term: string) => {
    dispatch(fetchMedicalRecords({ search: term }));
  };

  return (
    <div className="space-y-8 animate-fadeIn duration-300">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-6">
        <div>
          <h1 className="text-3xl font-black tracking-tight text-slate-900 dark:text-white">Clinical Records</h1>
          <p className="text-xs font-semibold text-secondary-500 dark:text-secondary-400 mt-1 uppercase tracking-wider">
            Manage patient diagnoses, treatments, and medical history.
          </p>
        </div>
        
        <div className="flex items-center gap-3 shrink-0">
           <Button variant="outline" size="sm" className="flex items-center">
             <Filter className="w-4 h-4 mr-2" />
             Filter
           </Button>
           <Button variant="primary" size="sm" className="flex items-center">
             <Plus className="w-4 h-4 mr-2" />
             New Record
           </Button>
        </div>
      </div>

      {/* Search Bar */}
      <div className="relative max-w-md">
        <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-4.5 h-4.5 text-secondary-400" />
        <input
          type="text"
          placeholder="Search by diagnosis or patient..."
          className="w-full bg-white dark:bg-slate-950/40 pl-11 pr-4 py-3 rounded-2xl text-xs focus:outline-none focus:ring-2 focus:ring-primary-500/10 border border-secondary-200/60 dark:border-slate-805/65 focus:border-primary-500 dark:text-white placeholder-secondary-400 font-bold transition-all shadow-inner"
          onChange={(e) => handleSearch(e.target.value)}
        />
      </div>

      {/* Grid Layout */}
      <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
        {isLoading ? (
          [...Array(6)].map((_, i) => (
            <div key={`skeleton-${i}`} className="h-64 rounded-3xl bg-secondary-100/50 dark:bg-slate-900/40 animate-pulse border border-secondary-200/20 dark:border-slate-805/20" />
          ))
        ) : records.length === 0 ? (
          <div className="col-span-full py-16 text-center border border-dashed border-secondary-200/50 dark:border-slate-805/50 bg-secondary-50/10 dark:bg-slate-950/10 rounded-3xl">
             <div className="flex flex-col items-center justify-center space-y-3">
               <div className="p-4 rounded-3xl bg-secondary-50 dark:bg-slate-950 border border-secondary-200/40 dark:border-slate-805/40 text-secondary-300 dark:text-secondary-700">
                 <FileText className="w-8 h-8 opacity-70" />
               </div>
               <p className="text-xs font-bold text-secondary-500 dark:text-secondary-400 uppercase tracking-widest">No clinical records found</p>
             </div>
          </div>
        ) : (
          records.map((record) => (
            <Card key={record.id} className="flex flex-col h-full hover:scale-[1.01] transition-all duration-300 border border-secondary-200/40 dark:border-slate-805/40 p-6 rounded-3xl">
              <div className="flex items-start justify-between mb-4">
                <div className="flex items-center space-x-3.5">
                  <div className="p-2.5 rounded-xl bg-primary-500/10 border border-primary-500/20">
                    <FileText className="w-5 h-5 text-primary-500 dark:text-primary-400" />
                  </div>
                  <span className="text-[10px] font-black text-secondary-400 dark:text-secondary-500 uppercase tracking-widest bg-secondary-100/60 dark:bg-slate-950/60 px-2.5 py-1 rounded-lg border border-secondary-200/30 dark:border-slate-805/40">
                    {record.recordType || 'General'}
                  </span>
                </div>
              </div>

              <div className="flex-1 flex flex-col justify-between space-y-5">
                <div>
                  <h3 className="text-base font-black text-slate-800 dark:text-white leading-snug">
                    {record.diagnosis}
                  </h3>
                  <div className="flex items-center space-x-2 mt-2.5 text-xs text-secondary-500 dark:text-secondary-400 font-bold uppercase tracking-wider">
                     <User className="w-4 h-4 text-secondary-400" />
                     <span>{record.patientName}</span>
                  </div>
                </div>

                <div className="space-y-3.5 bg-secondary-50/50 dark:bg-slate-950/40 p-4.5 rounded-2xl border border-secondary-200/20 dark:border-slate-850/40">
                  <div>
                    <span className="block text-[9px] font-black text-secondary-400 dark:text-secondary-500 uppercase tracking-wider">Symptoms</span>
                    <p className="text-xs text-slate-700 dark:text-slate-350 font-semibold line-clamp-2 mt-1 leading-relaxed">{record.symptoms || '—'}</p>
                  </div>
                  <div className="pt-3.5 border-t border-secondary-100/40 dark:border-slate-850/30">
                    <span className="block text-[9px] font-black text-secondary-400 dark:text-secondary-500 uppercase tracking-wider">Treatment Plan</span>
                    <p className="text-xs text-slate-700 dark:text-slate-350 font-semibold line-clamp-2 mt-1 leading-relaxed">{record.treatment || '—'}</p>
                  </div>
                </div>

                <div className="pt-4 border-t border-secondary-200/30 dark:border-slate-805/30 flex items-center justify-between mt-auto">
                  <div>
                    <p className="text-[9px] font-black text-secondary-400 dark:text-secondary-500 uppercase tracking-wider mb-1">Physician</p>
                    <div className="flex items-center space-x-1.5">
                      <UserCheck className="w-3.5 h-3.5 text-primary-500" />
                      <p className="text-xs font-black text-slate-800 dark:text-slate-200">{record.doctorName}</p>
                    </div>
                  </div>
                  <div className="text-right">
                    <p className="text-[9px] font-black text-secondary-400 dark:text-secondary-500 uppercase tracking-wider mb-1">Date</p>
                    <div className="flex items-center text-xs font-black text-slate-800 dark:text-slate-200 bg-secondary-100/50 dark:bg-slate-950/50 px-2 py-1 rounded-lg border border-secondary-200/20 dark:border-slate-850/40">
                      <Calendar className="w-3.5 h-3.5 mr-1.5 text-primary-500" />
                      {new Date(record.visitDate).toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' })}
                    </div>
                  </div>
                </div>
              </div>
            </Card>
          ))
        )}
      </div>
    </div>
  );
}

