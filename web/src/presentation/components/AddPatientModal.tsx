'use client';

import React, { useState } from 'react';

import { Button } from './Button';
import { X, User, Calendar, MapPin, Phone, Droplets } from 'lucide-react';

interface AddPatientModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSuccess: () => void;
}

export const AddPatientModal = ({ isOpen, onClose, onSuccess }: AddPatientModalProps) => {
  const [formData, setFormData] = useState({
    firstName: '',
    lastName: '',
    gender: 'Male',
    dateOfBirth: '',
    bloodGroup: 'A+',
    address: '',
    phone: '',
  });
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSubmitting(true);
    try {
      await new Promise(resolve => setTimeout(resolve, 1000));
      onSuccess();
      onClose();
    } catch (err) {
      alert('Failed to add patient');
    } finally {
      setIsSubmitting(false);
    }
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 sm:p-6">
      <div 
        className="absolute inset-0 bg-slate-950/40 backdrop-blur-md transition-opacity duration-300"
        onClick={onClose}
      />
      
      <div className="relative w-full max-w-2xl bg-white/90 dark:bg-slate-950/90 backdrop-blur-xl border border-secondary-200/40 dark:border-slate-805/40 rounded-3xl shadow-2xl overflow-hidden flex flex-col max-h-[90vh] transform scale-100 animate-scaleIn duration-350">
        {/* Header */}
        <div className="px-8 py-5 bg-gradient-to-r from-primary-600 via-primary-750 to-teal-850 flex items-center justify-between text-white">
          <div>
            <h2 className="text-lg font-black tracking-tight">Add New Patient</h2>
            <p className="text-xs text-white/80 font-medium mt-1">Register the patient&apos;s personal and medical information.</p>
          </div>
          <button 
            onClick={onClose} 
            className="p-2 hover:bg-white/10 text-white rounded-xl transition-colors cursor-pointer"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Form Body */}
        <div className="p-8 overflow-y-auto flex-1 bg-white/20 dark:bg-slate-950/20">
          <form id="add-patient-form" onSubmit={handleSubmit} className="space-y-6">
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-5">
              <div className="space-y-1.5">
                <label className="text-[10px] font-black text-secondary-400 dark:text-secondary-500 uppercase tracking-widest mb-1.5 block">First Name</label>
                <div className="relative group">
                  <User className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-secondary-400 group-focus-within:text-primary-500 transition-colors" />
                  <input
                    type="text"
                    required
                    placeholder="e.g. John"
                    className="input-field w-full !pl-9 shadow-inner bg-secondary-50/30 dark:bg-slate-900/30 border-secondary-200/60 dark:border-slate-800/60 text-xs"
                    value={formData.firstName}
                    onChange={(e) => setFormData({...formData, firstName: e.target.value})}
                  />
                </div>
              </div>
              <div className="space-y-1.5">
                <label className="text-[10px] font-black text-secondary-400 dark:text-secondary-500 uppercase tracking-widest mb-1.5 block">Last Name</label>
                <div className="relative group">
                  <User className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-secondary-400 group-focus-within:text-primary-500 transition-colors" />
                  <input
                    type="text"
                    required
                    placeholder="e.g. Doe"
                    className="input-field w-full !pl-9 shadow-inner bg-secondary-50/30 dark:bg-slate-900/30 border-secondary-200/60 dark:border-slate-800/60 text-xs"
                    value={formData.lastName}
                    onChange={(e) => setFormData({...formData, lastName: e.target.value})}
                  />
                </div>
              </div>

              <div className="space-y-1.5">
                <label className="text-[10px] font-black text-secondary-400 dark:text-secondary-500 uppercase tracking-widest mb-1.5 block">Gender</label>
                <select
                  className="input-field w-full appearance-none shadow-inner bg-secondary-50/30 dark:bg-slate-900/30 border-secondary-200/60 dark:border-slate-800/60 text-xs cursor-pointer"
                  value={formData.gender}
                  onChange={(e) => setFormData({...formData, gender: e.target.value})}
                >
                  <option>Male</option>
                  <option>Female</option>
                  <option>Other</option>
                </select>
              </div>

              <div className="space-y-1.5">
                <label className="text-[10px] font-black text-secondary-400 dark:text-secondary-500 uppercase tracking-widest mb-1.5 block">Date of Birth</label>
                <div className="relative group">
                  <Calendar className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-secondary-400 group-focus-within:text-primary-500 transition-colors" />
                  <input
                    type="date"
                    required
                    className="input-field w-full !pl-9 shadow-inner bg-secondary-50/30 dark:bg-slate-900/30 border-secondary-200/60 dark:border-slate-800/60 text-xs cursor-pointer"
                    value={formData.dateOfBirth}
                    onChange={(e) => setFormData({...formData, dateOfBirth: e.target.value})}
                  />
                </div>
              </div>

              <div className="space-y-1.5">
                <label className="text-[10px] font-black text-secondary-400 dark:text-secondary-500 uppercase tracking-widest mb-1.5 block">Blood Group</label>
                <div className="relative group">
                  <Droplets className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-secondary-400 group-focus-within:text-primary-500 transition-colors" />
                  <select
                    className="input-field w-full !pl-9 appearance-none shadow-inner bg-secondary-50/30 dark:bg-slate-900/30 border-secondary-200/60 dark:border-slate-800/60 text-xs cursor-pointer"
                    value={formData.bloodGroup}
                    onChange={(e) => setFormData({...formData, bloodGroup: e.target.value})}
                  >
                    {['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'].map(bg => (
                      <option key={bg} value={bg}>{bg}</option>
                    ))}
                  </select>
                </div>
              </div>

              <div className="space-y-1.5">
                <label className="text-[10px] font-black text-secondary-400 dark:text-secondary-500 uppercase tracking-widest mb-1.5 block">Phone Number</label>
                <div className="relative group">
                  <Phone className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-secondary-400 group-focus-within:text-primary-500 transition-colors" />
                  <input
                    type="tel"
                    placeholder="e.g. +1 (555) 000-0000"
                    className="input-field w-full !pl-9 shadow-inner bg-secondary-50/30 dark:bg-slate-900/30 border-secondary-200/60 dark:border-slate-800/60 text-xs"
                    value={formData.phone}
                    onChange={(e) => setFormData({...formData, phone: e.target.value})}
                  />
                </div>
              </div>
            </div>

            <div className="space-y-1.5">
              <label className="text-[10px] font-black text-secondary-400 dark:text-secondary-500 uppercase tracking-widest mb-1.5 block">Address</label>
              <div className="relative group">
                <MapPin className="absolute left-3 top-3.5 w-4 h-4 text-secondary-400 group-focus-within:text-primary-500 transition-colors" />
                <textarea
                  rows={3}
                  placeholder="Street Address, City, Zip Code..."
                  className="input-field w-full !pl-9 resize-none shadow-inner bg-secondary-50/30 dark:bg-slate-900/30 border-secondary-200/60 dark:border-slate-800/60 text-xs"
                  value={formData.address}
                  onChange={(e) => setFormData({...formData, address: e.target.value})}
                />
              </div>
            </div>
          </form>
        </div>

        {/* Footer */}
        <div className="px-8 py-5 border-t border-secondary-100 dark:border-slate-850 bg-secondary-50/20 dark:bg-slate-900/10 flex justify-end gap-3.5">
          <Button
            type="button"
            variant="outline"
            onClick={onClose}
            className="rounded-xl border border-secondary-200 py-2.5 px-4 font-bold text-xs"
          >
            Cancel
          </Button>
          <Button
            type="submit"
            form="add-patient-form"
            isLoading={isSubmitting}
            className="rounded-xl py-2.5 px-5 font-extrabold text-xs shadow-md shadow-primary-600/15"
          >
            Save Patient
          </Button>
        </div>
      </div>
    </div>
  );
};
