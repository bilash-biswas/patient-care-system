'use client';

import { useEffect } from 'react';
import { useAppDispatch, useAppSelector } from '@/presentation/store/hooks';
import { fetchPrescriptions, requestRefill } from '@/presentation/store/slices/prescriptionSlice';
import { Pill, RefreshCw, Clock, Calendar } from 'lucide-react';
import { Card } from '@/presentation/components/Card';
import { Button } from '@/presentation/components/Button';

export default function PrescriptionsPage() {
  const dispatch = useAppDispatch();
  const { prescriptions, isLoading } = useAppSelector((state) => state.prescriptions);
  const { user } = useAppSelector((state) => state.auth);

  useEffect(() => {
    if (user?.id) {
      dispatch(fetchPrescriptions({ patientId: user.id }));
    }
  }, [dispatch, user]);

  const handleRefillRequest = (id: string) => {
    dispatch(requestRefill(id));
    alert('Refill request sent!');
  };

  return (
    <div className="space-y-8 animate-fadeIn duration-300">
      <div className="flex justify-between items-center">
        <div>
          <h2 className="text-3xl font-black tracking-tight text-slate-900 dark:text-white">
            My Prescriptions
          </h2>
          <p className="text-xs font-semibold text-secondary-500 dark:text-secondary-400 mt-1 uppercase tracking-wider">
            Track active medications, dosages, instruction timelines, and refill statuses
          </p>
        </div>
      </div>

      {isLoading ? (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {[1, 2, 3, 4].map((i) => (
            <div key={i} className="animate-pulse h-52 rounded-3xl bg-secondary-100/50 dark:bg-slate-900/40 border border-secondary-200/20 dark:border-slate-805/20" />
          ))}
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {prescriptions.map((p) => (
            <Card key={p.id} className="hover:scale-[1.01] transition-all duration-300 border border-secondary-200/40 dark:border-slate-805/40 p-6 rounded-3xl flex flex-col justify-between h-full">
              <div>
                <div className="flex justify-between items-start mb-4">
                  <div className="p-3 rounded-2xl bg-teal-500/10 border border-teal-500/20 text-teal-600 dark:text-teal-400 shadow-sm">
                    <Pill className="w-6 h-6" />
                  </div>
                  <Button 
                    variant="outline"
                    size="sm"
                    onClick={() => handleRefillRequest(p.id)}
                    className="flex items-center space-x-2"
                  >
                    <RefreshCw className="w-3.5 h-3.5" />
                    <span className="uppercase tracking-wider text-[10px]">Request Refill</span>
                  </Button>
                </div>

                <h3 className="text-base font-black text-slate-800 dark:text-white leading-snug">{p.medicationName}</h3>
                <p className="text-xs font-bold text-primary-600 dark:text-primary-400 mt-1.5 uppercase tracking-wide">{p.dosage} — {p.frequency}</p>

                <div className="space-y-3 bg-secondary-50/50 dark:bg-slate-950/40 p-4.5 rounded-2xl border border-secondary-200/20 dark:border-slate-850/40 mt-4">
                  <div className="flex items-center text-xs text-secondary-500 dark:text-secondary-400 font-bold uppercase tracking-wider">
                    <Clock className="w-4 h-4 mr-2 text-primary-500" />
                    <span>Duration: {p.duration}</span>
                  </div>
                  {p.instructions && (
                    <p className="text-xs text-slate-700 dark:text-slate-350 font-semibold italic border-t border-secondary-150/30 dark:border-slate-850/30 pt-2.5 mt-2">
                      &ldquo;{p.instructions}&rdquo;
                    </p>
                  )}
                </div>
              </div>

              <div className="pt-4.5 border-t border-secondary-200/30 dark:border-slate-850/20 flex justify-between items-center mt-5">
                <span className="text-[9px] font-black text-secondary-400 dark:text-secondary-500 uppercase tracking-widest flex items-center">
                  <Calendar className="w-3.5 h-3.5 mr-1.5 text-primary-500/70" />
                  Prescribed {new Date(p.createdAt).toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' })}
                </span>
              </div>
            </Card>
          ))}

          {prescriptions.length === 0 && (
            <div className="col-span-full py-16 text-center border border-dashed border-secondary-200/50 dark:border-slate-805/50 bg-secondary-50/10 dark:bg-slate-950/10 rounded-3xl">
              <div className="flex flex-col items-center justify-center space-y-3">
                <div className="p-4 rounded-3xl bg-secondary-50 dark:bg-slate-950 border border-secondary-200/40 dark:border-slate-805/40 text-secondary-300 dark:text-secondary-700">
                  <Pill className="w-8 h-8 opacity-70" />
                </div>
                <p className="text-xs font-bold text-secondary-500 dark:text-secondary-400 uppercase tracking-widest">No prescriptions found</p>
              </div>
            </div>
          )}
        </div>
      )}
    </div>
  );
}

