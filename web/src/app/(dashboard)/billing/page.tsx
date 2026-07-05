'use client';

import { useEffect, useState } from 'react';
import { useAppDispatch, useAppSelector } from '@/presentation/store/hooks';
import { fetchInvoices } from '@/presentation/store/slices/billingSlice';
import { CreditCard, Download, FileText, CheckCircle, Clock, AlertCircle, X } from 'lucide-react';
import api from '@/core/api';
import { Card } from '@/presentation/components/Card';
import { Button } from '@/presentation/components/Button';

export default function BillingPage() {
  const dispatch = useAppDispatch();
  const { invoices, isLoading } = useAppSelector((state) => state.billing);
  const { user } = useAppSelector((state) => state.auth);
  const [selectedInvoice, setSelectedInvoice] = useState<any | null>(null);
  const [cardNumber, setCardNumber] = useState('');
  const [cardExpiry, setCardExpiry] = useState('');
  const [cardCvv, setCardCvv] = useState('');
  const [cardName, setCardName] = useState('');
  const [isSuccess, setIsSuccess] = useState(false);
  const [isPaying, setIsPaying] = useState<string | null>(null);

  useEffect(() => {
    if (user?.id) {
      dispatch(fetchInvoices({ patientId: user.id }));
    }
  }, [dispatch, user]);

  const handlePayClick = (invoice: any) => {
    setSelectedInvoice(invoice);
    setCardNumber('');
    setCardExpiry('');
    setCardCvv('');
    setCardName(user?.firstName ? `${user.firstName} ${user.lastName || ''}` : '');
    setIsSuccess(false);
  };

  const handlePaymentSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedInvoice) return;
    setIsPaying(selectedInvoice.id);
    try {
      // Simulate checking/verification delay
      await new Promise((resolve) => setTimeout(resolve, 1500));
      
      await api.post(`/billing/invoices/${selectedInvoice.id}/pay`);
      
      setIsSuccess(true);
      
      // Delay to show confirmation screen
      await new Promise((resolve) => setTimeout(resolve, 1500));
      
      if (user?.id) {
        dispatch(fetchInvoices({ patientId: user.id }));
      }
      setSelectedInvoice(null);
      setIsSuccess(false);
    } catch (err) {
      console.error('Error paying invoice:', err);
    } finally {
      setIsPaying(null);
    }
  };

  const totalOutstanding = invoices
    .filter((inv) => inv.status === 'Unpaid')
    .reduce((sum, inv) => sum + inv.amount, 0);

  const totalPaid = invoices
    .filter((inv) => inv.status === 'Paid')
    .reduce((sum, inv) => sum + inv.amount, 0);

  const paidInvoices = invoices.filter((inv) => inv.status === 'Paid');
  const lastPayment = paidInvoices.length > 0
    ? new Date(Math.max(...paidInvoices.map((inv) => new Date(inv.paidAt || inv.dueDate).getTime()))).toLocaleDateString('en-US', { month: 'short', day: 'numeric' })
    : 'N/A';

  const getStatusStyle = (status: string) => {
    switch (status) {
      case 'Paid': return 'bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 border border-emerald-500/20';
      case 'Unpaid': return 'bg-amber-500/10 text-amber-600 dark:text-amber-400 border border-amber-500/20';
      default: return 'bg-slate-500/10 text-slate-600 dark:text-slate-400 border border-slate-500/20';
    }
  };

  return (
    <div className="space-y-8 animate-fadeIn duration-300">
      <div className="flex justify-between items-center">
        <div>
          <h2 className="text-3xl font-black tracking-tight text-slate-900 dark:text-white">
            Billing & Invoices
          </h2>
          <p className="text-xs font-semibold text-secondary-500 dark:text-secondary-400 mt-1 uppercase tracking-wider">
            Manage your patient balances, medical invoices, and transaction histories
          </p>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="relative overflow-hidden rounded-2xl bg-gradient-to-br from-primary-600 via-primary-750 to-teal-700 p-6 text-white shadow-xl shadow-primary-500/15 hover:shadow-primary-500/25 hover:scale-[1.01] transition-all duration-300 group">
          <div className="absolute -right-4 -bottom-4 w-32 h-32 opacity-15 group-hover:scale-110 transition-transform">
            <CreditCard className="w-full h-full text-white" />
          </div>
          <p className="text-teal-150 text-xs font-black uppercase tracking-widest mb-1.5">Total Outstanding</p>
          <h3 className="text-3.5xl font-black">${totalOutstanding.toFixed(2)}</h3>
        </div>

        <Card className="hover:scale-[1.01] transition-all duration-300">
          <div className="flex justify-between items-start">
            <div>
              <p className="text-secondary-400 dark:text-secondary-500 text-xs font-black uppercase tracking-widest mb-1.5">Total Paid</p>
              <h3 className="text-3.5xl font-black text-slate-900 dark:text-white">${totalPaid.toFixed(2)}</h3>
            </div>
            <div className="p-3.5 bg-emerald-500/10 rounded-2xl border border-emerald-500/20 shadow-sm">
              <CheckCircle className="w-5.5 h-5.5 text-emerald-500 dark:text-emerald-400" />
            </div>
          </div>
        </Card>

        <Card className="hover:scale-[1.01] transition-all duration-300">
          <div className="flex justify-between items-start">
            <div>
              <p className="text-secondary-400 dark:text-secondary-500 text-xs font-black uppercase tracking-widest mb-1.5">Last Payment</p>
              <h3 className="text-3.5xl font-black text-slate-900 dark:text-white">{lastPayment}</h3>
            </div>
            <div className="p-3.5 bg-primary-500/10 rounded-2xl border border-primary-500/20 shadow-sm">
              <Clock className="w-5.5 h-5.5 text-primary-500 dark:text-primary-400" />
            </div>
          </div>
        </Card>
      </div>

      <Card className="overflow-hidden border border-secondary-200/40 dark:border-slate-805/40 p-0 rounded-3xl">
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-secondary-50/50 dark:bg-slate-950/40 border-b border-secondary-200/30 dark:border-slate-805/30">
                <th className="px-6 py-4.5 text-[10px] font-black text-secondary-400 dark:text-secondary-500 uppercase tracking-widest">Invoice</th>
                <th className="px-6 py-4.5 text-[10px] font-black text-secondary-400 dark:text-secondary-500 uppercase tracking-widest">Date</th>
                <th className="px-6 py-4.5 text-[10px] font-black text-secondary-400 dark:text-secondary-500 uppercase tracking-widest">Amount</th>
                <th className="px-6 py-4.5 text-[10px] font-black text-secondary-400 dark:text-secondary-500 uppercase tracking-widest">Status</th>
                <th className="px-6 py-4.5 text-[10px] font-black text-secondary-400 dark:text-secondary-500 uppercase tracking-widest text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-secondary-100/50 dark:divide-slate-805/40">
              {invoices.map((inv) => (
                <tr key={inv.id} className="hover:bg-secondary-50/30 dark:hover:bg-slate-950/20 transition-colors">
                  <td className="px-6 py-4.5">
                    <div className="flex items-center">
                      <div className="p-2.5 rounded-xl bg-secondary-100/60 dark:bg-slate-800/60 border border-secondary-200/30 dark:border-slate-805/40 mr-3">
                        <FileText className="w-4.5 h-4.5 text-secondary-500 dark:text-secondary-400" />
                      </div>
                      <span className="text-xs font-black text-slate-800 dark:text-slate-200">#{inv.id.slice(0, 8).toUpperCase()}</span>
                    </div>
                  </td>
                  <td className="px-6 py-4.5 text-xs text-secondary-500 dark:text-secondary-400 font-semibold">{new Date(inv.dueDate).toLocaleDateString(undefined, { year: 'numeric', month: 'short', day: 'numeric' })}</td>
                  <td className="px-6 py-4.5 text-sm font-black text-slate-900 dark:text-white">${inv.amount.toFixed(2)}</td>
                  <td className="px-6 py-4.5">
                    <span className={`px-3 py-1.5 rounded-xl text-[10px] font-black uppercase tracking-wider border ${getStatusStyle(inv.status)}`}>
                      {inv.status}
                    </span>
                  </td>
                  <td className="px-6 py-4.5 text-right space-x-2">
                    {inv.status === 'Unpaid' && (
                      <Button 
                        variant="primary"
                        size="sm"
                        onClick={() => handlePayClick(inv)}
                      >
                        Pay Now
                      </Button>
                    )}
                    <button className="p-2.5 rounded-xl text-secondary-400 hover:text-primary-500 hover:bg-secondary-50 dark:hover:bg-slate-950/40 border border-transparent hover:border-secondary-200/40 dark:hover:border-slate-805/40 transition-all cursor-pointer">
                      <Download className="w-4.5 h-4.5" />
                    </button>
                  </td>
                </tr>
              ))}
              
              {invoices.length === 0 && !isLoading && (
                <tr>
                  <td colSpan={5} className="px-6 py-16 text-center">
                    <div className="flex flex-col items-center justify-center space-y-3">
                      <div className="p-4 rounded-3xl bg-secondary-50 dark:bg-slate-950 border border-secondary-200/40 dark:border-slate-805/40 text-secondary-300 dark:text-secondary-700">
                        <AlertCircle className="w-8 h-8 opacity-70" />
                      </div>
                      <p className="text-xs font-bold text-secondary-500 dark:text-secondary-400 uppercase tracking-widest">No Invoices Found</p>
                    </div>
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </Card>

      {/* Premium Secure Checkout Modal */}
      {selectedInvoice && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
          <div 
            className="absolute inset-0 bg-slate-900/60 backdrop-blur-md transition-opacity duration-300"
            onClick={() => !isPaying && setSelectedInvoice(null)}
          />

          <Card className="relative w-full max-w-md bg-white/90 dark:bg-slate-950/90 border border-secondary-200/40 dark:border-slate-805/40 shadow-2xl rounded-3xl overflow-hidden z-10 p-0 transition-all duration-350 animate-scaleIn">
            
            {/* Success state */}
            {isSuccess ? (
              <div className="p-8 flex flex-col items-center justify-center text-center space-y-4 py-16">
                <div className="w-20 h-20 bg-emerald-500/10 dark:bg-emerald-500/20 text-emerald-500 dark:text-emerald-400 rounded-full flex items-center justify-center border border-emerald-500/20 animate-bounce">
                  <CheckCircle className="w-10 h-10" />
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
                    disabled={!!isPaying}
                  >
                    <X className="w-5 h-5" />
                  </button>
                  <p className="text-[10px] text-teal-205 font-black uppercase tracking-widest mb-1">Secure Checkout</p>
                  <h3 className="text-lg font-black tracking-tight">Complete Invoice Payment</h3>
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
                    disabled={!!isPaying}
                  >
                    Cancel
                  </Button>
                  <Button 
                    type="submit"
                    variant="primary"
                    className="flex-1 rounded-xl text-xs py-2.5 font-bold bg-gradient-to-r from-primary-600 to-teal-650 hover:from-primary-750 hover:to-teal-750 text-white"
                    isLoading={!!isPaying}
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
}

