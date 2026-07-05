'use client';

import React, { useState } from 'react';
import { Appointment } from '@/domain/entities';
import { Card } from './Card';
import { Button } from './Button';
import { Calendar, Clock, User, CheckCircle2, XCircle, MoreVertical, CreditCard, X } from 'lucide-react';
import { cn } from './Button';
import { motion } from 'framer-motion';
import { useRouter } from 'next/navigation';
import api from '@/core/api';

const formatTimeTo12Hour = (time24: string) => {
  if (!time24) return '';
  const [hoursStr, minutesStr] = time24.split(':');
  const hours = parseInt(hoursStr, 10);
  if (isNaN(hours)) return time24;
  const ampm = hours >= 12 ? 'PM' : 'AM';
  const hours12 = hours % 12 || 12;
  return `${hours12}:${minutesStr} ${ampm}`;
};

interface AppointmentListProps {
  appointments: Appointment[];
  isLoading: boolean;
  onStatusUpdate: (id: string, status: string) => void;
}

export const AppointmentList = ({ appointments, isLoading, onStatusUpdate }: AppointmentListProps) => {
  const router = useRouter();
  const [selectedInvoice, setSelectedInvoice] = useState<any | null>(null);
  const [selectedAppointmentId, setSelectedAppointmentId] = useState<string | null>(null);
  const [cardNumber, setCardNumber] = useState('');
  const [cardExpiry, setCardExpiry] = useState('');
  const [cardCvv, setCardCvv] = useState('');
  const [cardName, setCardName] = useState('');
  const [isSuccess, setIsSuccess] = useState(false);
  const [isPaying, setIsPaying] = useState(false);
  const [loadingInvoiceId, setLoadingInvoiceId] = useState<string | null>(null);

  const handlePayClick = async (appointment: Appointment) => {
    setLoadingInvoiceId(appointment.id);
    try {
      const res = await api.get('/Billing/invoices');
      const invoicesList = res.data.data || [];
      const invoice = invoicesList.find((inv: any) => inv.appointmentId === appointment.id);
      if (invoice) {
        setSelectedInvoice(invoice);
        setSelectedAppointmentId(appointment.id);
        setCardNumber('');
        setCardExpiry('');
        setCardCvv('');
        setCardName(appointment.patientName || '');
        setIsSuccess(false);
      } else {
        alert('Invoice not found for this appointment. Please contact billing support.');
      }
    } catch (err) {
      console.error(err);
      alert('Could not retrieve payment invoice. Please try again.');
    } finally {
      setLoadingInvoiceId(null);
    }
  };

  const handlePaymentSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedInvoice || !selectedAppointmentId) return;
    setIsPaying(true);
    try {
      // Simulate verification delay
      await new Promise((resolve) => setTimeout(resolve, 1500));
      
      await api.post(`/billing/invoices/${selectedInvoice.id}/pay`);
      
      setIsSuccess(true);
      
      // Delay to show success screen
      await new Promise((resolve) => setTimeout(resolve, 1500));
      
      // Notify parent to refresh the status to Scheduled instantly
      onStatusUpdate(selectedAppointmentId, 'Scheduled');
      
      setSelectedInvoice(null);
      setSelectedAppointmentId(null);
      setIsSuccess(false);
    } catch (err) {
      console.error('Error paying invoice:', err);
      alert('Payment failed. Please check details and try again.');
    } finally {
      setIsPaying(false);
    }
  };
  const getStatusColor = (status: string) => {
    switch (status) {
      case 'Scheduled': return 'text-sky-700 bg-sky-50 dark:bg-sky-950/20 dark:text-sky-400 border border-sky-200/30';
      case 'Completed': return 'text-emerald-700 bg-emerald-50 dark:bg-emerald-950/20 dark:text-emerald-400 border border-emerald-200/30';
      case 'Cancelled': return 'text-red-700 bg-red-50 dark:bg-red-950/20 dark:text-red-400 border border-red-200/30';
      case 'NoShow': return 'text-amber-700 bg-amber-50 dark:bg-amber-950/20 dark:text-amber-400 border border-amber-200/30';
      case 'PendingPayment': return 'text-amber-700 bg-amber-50 dark:bg-amber-950/20 dark:text-amber-400 border border-amber-200/30';
      default: return 'text-secondary-750 bg-secondary-50 dark:bg-slate-900/40 dark:text-secondary-400';
    }
  };

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
      {isLoading ? (
        [...Array(6)].map((_, i) => (
          <Card key={i} className="animate-shimmer border-none h-56 rounded-2xl bg-slate-100 dark:bg-slate-900/30">
            <div className="h-full w-full" />
          </Card>
        ))
      ) : appointments.length === 0 ? (
        <div className="col-span-full py-20 text-center text-secondary-500 bg-white/40 dark:bg-slate-900/20 backdrop-blur-md rounded-3xl border border-secondary-200/20 dark:border-slate-850">
          <Calendar className="w-12 h-12 mx-auto mb-4 opacity-20 text-secondary-400" />
          <p className="text-lg font-black tracking-tight text-secondary-900 dark:text-white">No Appointments Scheduled</p>
          <p className="mt-2 text-xs font-semibold text-secondary-400">You are all caught up for now!</p>
        </div>
      ) : (
        appointments.map((appointment, index) => (
          <motion.div
            key={appointment.id}
            initial={{ opacity: 0, y: 15 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: index * 0.04 }}
          >
            <Card className="hover:shadow-xl hover:-translate-y-1 transition-all duration-300 border-none glass-card group overflow-hidden p-6 relative">
              <div className="flex justify-between items-start mb-5 relative z-10">
                <span className={cn('px-3 py-1 rounded-full text-[10px] font-extrabold uppercase tracking-wider', getStatusColor(appointment.status))}>
                  {appointment.status}
                </span>
                <button className="p-2.5 hover:bg-secondary-100 dark:hover:bg-slate-800 text-secondary-400 hover:text-secondary-900 dark:hover:text-white rounded-xl transition-colors cursor-pointer">
                  <MoreVertical className="w-4 h-4" />
                </button>
              </div>

              <div className="space-y-5 relative z-10">
                <div className="flex items-center space-x-3.5">
                  <div className="w-11 h-11 rounded-2xl bg-gradient-to-br from-primary-500/10 to-teal-500/5 dark:from-primary-500/20 dark:to-teal-500/10 flex items-center justify-center text-primary-650 dark:text-primary-400 font-extrabold border border-primary-500/10 shadow-sm text-sm">
                    {appointment.patientName?.[0] || 'P'}
                  </div>
                  <div>
                    <p className="text-sm font-extrabold text-secondary-900 dark:text-white leading-snug">{appointment.patientName || 'Patient'}</p>
                    <p className="text-[10px] text-secondary-450 font-bold mt-0.5 tracking-wide">Reason: {appointment.reason}</p>
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-4 py-3 border-y border-secondary-100/50 dark:border-slate-800/40 text-xs font-semibold">
                  <div className="flex items-center text-secondary-650 dark:text-slate-350">
                    <Calendar className="w-4 h-4 mr-2.5 text-primary-500 shrink-0" />
                    {new Date(appointment.appointmentDate).toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' })}
                  </div>
                  <div className="flex items-center text-secondary-650 dark:text-slate-350">
                    <Clock className="w-4 h-4 mr-2.5 text-primary-500 shrink-0" />
                    {formatTimeTo12Hour(appointment.startTime)} - {formatTimeTo12Hour(appointment.endTime)}
                  </div>
                </div>

                <div className="flex items-center text-[10px] font-bold uppercase tracking-wider text-secondary-400">
                  <User className="w-3.5 h-3.5 mr-2" />
                  Dr. {appointment.doctorName || 'General Staff'}
                </div>

                {appointment.status === 'Scheduled' && (
                  <div className="space-y-3 pt-3 border-t border-secondary-100/50 dark:border-slate-800/40 mt-1">
                    <div className="flex gap-2.5">
                      <Button 
                        variant="outline" 
                        size="sm" 
                        className="flex-1 rounded-xl text-emerald-600 dark:text-emerald-400 border-emerald-100 dark:border-emerald-950/20 hover:bg-emerald-50 dark:hover:bg-emerald-950/20 font-bold py-2 text-xs"
                        onClick={() => onStatusUpdate(appointment.id, 'Completed')}
                      >
                        <CheckCircle2 className="w-4 h-4 mr-2 shrink-0" />
                        Complete
                      </Button>
                      <Button 
                        variant="outline" 
                        size="sm" 
                        className="flex-1 rounded-xl text-red-650 dark:text-red-400 border-red-100 dark:border-red-950/20 hover:bg-red-50 dark:hover:bg-red-950/20 font-bold py-2 text-xs"
                        onClick={() => onStatusUpdate(appointment.id, 'Cancelled')}
                      >
                        <XCircle className="w-4 h-4 mr-2 shrink-0" />
                        Cancel
                      </Button>
                    </div>
                    <Button 
                      variant="outline" 
                      size="sm" 
                      className="w-full rounded-xl text-primary-600 dark:text-primary-400 border-primary-100 dark:border-primary-950/20 hover:bg-primary-50 dark:hover:bg-primary-950/20 font-bold py-2 text-xs"
                      onClick={() => window.open(`${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:5278'}/api/Appointments/${appointment.id}/calendar`, '_blank')}
                    >
                      <Calendar className="w-4 h-4 mr-2 shrink-0" />
                      Add to Calendar
                    </Button>
                  </div>
                )}

                {appointment.status === 'PendingPayment' && (
                  <div className="space-y-3 pt-3 border-t border-secondary-100/50 dark:border-slate-800/40 mt-1">
                    <Button 
                      variant="primary" 
                      size="sm" 
                      className="w-full rounded-xl font-bold py-2.5 text-xs bg-amber-600 hover:bg-amber-700 text-white flex items-center justify-center border-none shadow-sm"
                      onClick={() => handlePayClick(appointment)}
                      isLoading={loadingInvoiceId === appointment.id}
                    >
                      <CreditCard className="w-4 h-4 mr-2 shrink-0 animate-pulse" />
                      Pay Now to Confirm
                    </Button>
                  </div>
                )}
              </div>
            </Card>
          </motion.div>
        ))
      )}

      {/* Premium Secure Checkout Modal */}
      {selectedInvoice && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
          <div 
            className="absolute inset-0 bg-slate-900/60 backdrop-blur-md transition-opacity duration-300"
            onClick={() => !isPaying && setSelectedInvoice(null)}
          />

          <Card className="relative w-full max-w-md bg-white/90 dark:bg-slate-950/90 border border-secondary-200/40 dark:border-slate-805/40 shadow-2xl rounded-3xl overflow-hidden z-10 p-0 text-left transition-all duration-350 animate-scaleIn">
            
            {/* Success state */}
            {isSuccess ? (
              <div className="p-8 flex flex-col items-center justify-center text-center space-y-4 py-16">
                <div className="w-20 h-20 bg-emerald-500/10 dark:bg-emerald-500/20 text-emerald-500 dark:text-emerald-400 rounded-full flex items-center justify-center border border-emerald-500/20 animate-bounce">
                  <CheckCircle2 className="w-10 h-10" />
                </div>
                <h3 className="text-xl font-black text-slate-900 dark:text-white">Payment Successful!</h3>
                <p className="text-xs font-semibold text-secondary-500 max-w-xs">Your transaction has been processed. Your appointment is now confirmed.</p>
              </div>
            ) : (
              <form onSubmit={handlePaymentSubmit}>
                {/* Header */}
                <div className="p-6 bg-gradient-to-br from-primary-600 via-primary-750 to-teal-700 text-white relative">
                  <button 
                    type="button"
                    className="absolute top-4 right-4 p-1.5 rounded-full hover:bg-white/10 text-white/80 hover:text-white transition-colors cursor-pointer"
                    onClick={() => setSelectedInvoice(null)}
                    disabled={isPaying}
                  >
                    <X className="w-5 h-5" />
                  </button>
                  <p className="text-[10px] text-teal-205 font-black uppercase tracking-widest mb-1">Secure Checkout</p>
                  <h3 className="text-lg font-black tracking-tight">Complete Appointment Payment</h3>
                  <div className="mt-4 flex justify-between items-baseline">
                    <span className="text-xs text-white/70 font-semibold">Total Amount:</span>
                    <span className="text-2xl font-black">${selectedInvoice.amount.toFixed(2)}</span>
                  </div>
                </div>

                {/* Body */}
                <div className="p-6 space-y-6">
                  {/* Visual Card Preview */}
                  <div className="relative h-44 rounded-2xl bg-gradient-to-br from-slate-900 via-slate-850 to-indigo-950 p-5 text-white flex flex-col justify-between shadow-xl border border-white/5 overflow-hidden">
                    <div className="absolute top-0 right-0 w-32 h-32 bg-primary-500/10 rounded-full blur-2xl pointer-events-none" />
                    
                    <div className="flex justify-between items-start">
                      <span className="text-[10px] font-black tracking-widest text-white/50 uppercase">Clinical Care Pay</span>
                      <CreditCard className="w-7 h-7 text-white/60" />
                    </div>

                    <div className="text-lg font-black tracking-widest text-center font-mono my-2.5">
                      {cardNumber || '•••• •••• •••• ••••'}
                    </div>

                    <div className="flex justify-between items-end">
                      <div>
                        <p className="text-[8px] font-black uppercase text-white/40 tracking-wider">Card Holder</p>
                        <p className="text-[10px] font-black uppercase font-mono tracking-wide">{cardName || 'JOHN PATIENT'}</p>
                      </div>
                      <div className="text-right">
                        <p className="text-[8px] font-black uppercase text-white/40 tracking-wider">Expires</p>
                        <p className="text-[10px] font-black font-mono">{cardExpiry || 'MM/YY'}</p>
                      </div>
                    </div>
                  </div>

                  {/* Card Form Inputs */}
                  <div className="space-y-4">
                    <div>
                      <label className="block text-[10px] font-black uppercase tracking-wider text-secondary-500 mb-1.5">Card Number</label>
                      <input 
                        type="text" 
                        required
                        placeholder="4111 2222 3333 4444"
                        value={cardNumber}
                        maxLength={19}
                        onChange={(e) => {
                          const val = e.target.value.replace(/\D/g, '').replace(/(.{4})/g, '$1 ').trim();
                          setCardNumber(val);
                        }}
                        className="w-full px-4 py-3 text-xs bg-secondary-50 dark:bg-slate-900 border border-secondary-200/50 dark:border-slate-805/40 rounded-xl focus:ring-2 focus:ring-primary-500/20 focus:border-primary-500 text-slate-800 dark:text-slate-100 font-mono outline-none transition-all"
                      />
                    </div>

                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <label className="block text-[10px] font-black uppercase tracking-wider text-secondary-500 mb-1.5">Expiry Date</label>
                        <input 
                          type="text" 
                          required
                          placeholder="MM/YY"
                          value={cardExpiry}
                          maxLength={5}
                          onChange={(e) => {
                            let val = e.target.value.replace(/\D/g, '');
                            if (val.length > 2) {
                              val = `${val.slice(0, 2)}/${val.slice(2, 4)}`;
                            }
                            setCardExpiry(val);
                          }}
                          className="w-full px-4 py-3 text-xs bg-secondary-50 dark:bg-slate-900 border border-secondary-200/50 dark:border-slate-805/40 rounded-xl focus:ring-2 focus:ring-primary-500/20 focus:border-primary-500 text-slate-800 dark:text-slate-100 font-mono outline-none transition-all"
                        />
                      </div>
                      <div>
                        <label className="block text-[10px] font-black uppercase tracking-wider text-secondary-500 mb-1.5">CVV Code</label>
                        <input 
                          type="password" 
                          required
                          placeholder="•••"
                          value={cardCvv}
                          maxLength={3}
                          onChange={(e) => setCardCvv(e.target.value.replace(/\D/g, ''))}
                          className="w-full px-4 py-3 text-xs bg-secondary-50 dark:bg-slate-900 border border-secondary-200/50 dark:border-slate-805/40 rounded-xl focus:ring-2 focus:ring-primary-500/20 focus:border-primary-500 text-slate-800 dark:text-slate-100 font-mono outline-none transition-all"
                        />
                      </div>
                    </div>

                    <div>
                      <label className="block text-[10px] font-black uppercase tracking-wider text-secondary-500 mb-1.5">Cardholder Name</label>
                      <input 
                        type="text" 
                        required
                        placeholder="John Patient"
                        value={cardName}
                        onChange={(e) => setCardName(e.target.value)}
                        className="w-full px-4 py-3 text-xs bg-secondary-50 dark:bg-slate-900 border border-secondary-200/50 dark:border-slate-805/40 rounded-xl focus:ring-2 focus:ring-primary-500/20 focus:border-primary-500 text-slate-800 dark:text-slate-100 outline-none transition-all font-semibold"
                      />
                    </div>
                  </div>
                </div>

                {/* Footer */}
                <div className="p-6 bg-secondary-50/50 dark:bg-slate-950/40 border-t border-secondary-100/50 dark:border-slate-805/30 flex justify-between items-center gap-3">
                  <Button 
                    type="button" 
                    variant="outline"
                    className="flex-1 rounded-xl text-xs py-2.5 font-bold"
                    onClick={() => setSelectedInvoice(null)}
                    disabled={isPaying}
                  >
                    Cancel
                  </Button>
                  <Button 
                    type="submit"
                    variant="primary"
                    className="flex-1 rounded-xl text-xs py-2.5 font-bold bg-gradient-to-r from-primary-600 to-teal-650 hover:from-primary-750 hover:to-teal-750 text-white"
                    isLoading={isPaying}
                  >
                    {isPaying ? 'Verifying...' : 'Pay Invoice'}
                  </Button>
                </div>
              </form>
            )}
          </Card>
        </div>
      )}
    </div>
  );
};
