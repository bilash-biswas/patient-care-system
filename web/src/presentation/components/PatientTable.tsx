'use client';

import React, { useState } from 'react';
import { Patient } from '@/domain/entities';
import { 
  Search, 
  UserPlus, 
  ChevronLeft, 
  ChevronRight, 
  Filter, 
  Eye, 
  Edit2, 
  Trash2, 
  Calendar, 
  Droplets, 
  User, 
  ArrowUpDown,
  X,
  Phone
} from 'lucide-react';
import { Button, cn } from './Button';
import { Card } from './Card';

interface PatientTableProps {
  patients: Patient[];
  totalCount: number;
  isLoading: boolean;
  onSearch: (term: string) => void;
  onPageChange: (page: number) => void;
  currentPage: number;
  onAddClick?: () => void;
}

export const PatientTable = ({
  patients,
  totalCount,
  isLoading,
  onSearch,
  onPageChange,
  currentPage,
  onAddClick,
}: PatientTableProps) => {
  const totalPages = Math.ceil(totalCount / 10);
  const [selectedPatient, setSelectedPatient] = useState<Patient | null>(null);
  const [isViewModalOpen, setIsViewModalOpen] = useState(false);
  const [isFilterOpen, setIsFilterOpen] = useState(false);
  const [genderFilter, setGenderFilter] = useState('All');
  const [bloodFilter, setBloodFilter] = useState('All');

  const filteredPatients = patients.filter((p) => {
    const matchesGender = genderFilter === 'All' || p.gender?.toLowerCase() === genderFilter.toLowerCase();
    const matchesBlood = bloodFilter === 'All' || p.bloodGroup === bloodFilter;
    return matchesGender && matchesBlood;
  });

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

  return (
    <div className="space-y-6">
      {/* Table Header / Actions */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div className="relative flex-1 max-w-md group">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-secondary-450 group-focus-within:text-primary-500 transition-colors" />
          <input
            type="text"
            placeholder="Search patients by name or ID..."
            className="input-field w-full !pl-9 py-2 text-xs bg-white dark:bg-slate-900 shadow-sm"
            onChange={(e) => onSearch(e.target.value)}
          />
        </div>
        
        <div className="flex items-center gap-3">
          <Button 
            variant="outline" 
            size="sm" 
            onClick={() => setIsFilterOpen(!isFilterOpen)} 
            className={cn("flex items-center transition-all rounded-xl", isFilterOpen && "bg-primary-50 dark:bg-primary-950/20 border-primary-500 text-primary-600 dark:text-primary-400")}
          >
            <Filter className="w-4 h-4 mr-2" />
            Advanced Filters
          </Button>
          <Button variant="primary" size="sm" onClick={onAddClick} className="flex items-center rounded-xl shadow-md">
            <UserPlus className="w-4 h-4 mr-2" />
            Add Patient
          </Button>
        </div>
      </div>

      {/* Expandable Filter Panel */}
      {isFilterOpen && (
        <Card className="p-5 border border-secondary-200/50 dark:border-slate-800/60 bg-gradient-to-br from-white/80 to-secondary-50/30 dark:from-slate-950/80 dark:to-slate-900/30 shadow-md rounded-2xl grid grid-cols-1 md:grid-cols-3 gap-5 items-end">
          <div>
            <label className="block text-[10px] font-black text-secondary-400 dark:text-secondary-500 uppercase tracking-widest mb-2">Gender Option</label>
            <select 
              value={genderFilter} 
              onChange={(e) => setGenderFilter(e.target.value)}
              className="w-full bg-white dark:bg-slate-900 border border-secondary-200/60 dark:border-slate-800/60 rounded-xl px-3 py-2 text-xs font-semibold outline-none focus:border-primary-550 focus:ring-2 focus:ring-primary-500/10 transition-all text-secondary-900 dark:text-white"
            >
              <option value="All">All Genders</option>
              <option value="Male">Male</option>
              <option value="Female">Female</option>
            </select>
          </div>

          <div>
            <label className="block text-[10px] font-black text-secondary-400 dark:text-secondary-500 uppercase tracking-widest mb-2">Blood Group Type</label>
            <select 
              value={bloodFilter} 
              onChange={(e) => setBloodFilter(e.target.value)}
              className="w-full bg-white dark:bg-slate-900 border border-secondary-200/60 dark:border-slate-800/60 rounded-xl px-3 py-2 text-xs font-semibold outline-none focus:border-primary-550 focus:ring-2 focus:ring-primary-500/10 transition-all text-secondary-900 dark:text-white"
            >
              <option value="All">All Blood Groups</option>
              <option value="A+">A+</option>
              <option value="A-">A-</option>
              <option value="B+">B+</option>
              <option value="B-">B-</option>
              <option value="AB+">AB+</option>
              <option value="AB-">AB-</option>
              <option value="O+">O+</option>
              <option value="O-">O-</option>
            </select>
          </div>

          <div className="flex justify-end">
            <Button 
              variant="outline" 
              size="sm" 
              onClick={() => { setGenderFilter('All'); setBloodFilter('All'); }}
              className="text-xs font-bold text-secondary-500 hover:text-red-500 hover:border-red-200 dark:hover:border-red-950/30 rounded-xl py-2"
            >
              Reset Filters
            </Button>
          </div>
        </Card>
      )}

      {/* Standard Clean Table */}
      <div className="glass-card rounded-2xl overflow-hidden shadow-sm border border-secondary-200/40 dark:border-slate-905/40">
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse text-xs">
            <thead>
              <tr className="border-b border-secondary-200/30 dark:border-slate-900/50 bg-secondary-50/50 dark:bg-slate-900/30">
                <th className="px-6 py-4.5 font-bold text-secondary-500 dark:text-secondary-400 uppercase tracking-widest text-[10px]">
                  <div className="flex items-center space-x-1 cursor-pointer hover:text-secondary-900 dark:hover:text-white transition-colors">
                    <span>Patient profile</span>
                    <ArrowUpDown className="w-3.5 h-3.5" />
                  </div>
                </th>
                <th className="px-6 py-4.5 font-bold text-secondary-500 dark:text-secondary-400 uppercase tracking-widest text-[10px]">Demographics</th>
                <th className="px-6 py-4.5 font-bold text-secondary-500 dark:text-secondary-400 uppercase tracking-widest text-[10px]">Contact Info</th>
                <th className="px-6 py-4.5 font-bold text-secondary-500 dark:text-secondary-400 uppercase tracking-widest text-[10px]">Date Registered</th>
                <th className="px-6 py-4.5 font-bold text-secondary-500 dark:text-secondary-400 uppercase tracking-widest text-[10px] text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-secondary-100/50 dark:divide-slate-800/40">
              {isLoading ? (
                [...Array(5)].map((_, i) => (
                  <tr key={`skeleton-${i}`} className="bg-white/10">
                    <td className="px-6 py-4.5"><div className="h-10 rounded animate-shimmer w-full"></div></td>
                    <td className="px-6 py-4.5"><div className="h-4 rounded animate-shimmer w-1/2"></div></td>
                    <td className="px-6 py-4.5"><div className="h-4 rounded animate-shimmer w-1/2"></div></td>
                    <td className="px-6 py-4.5"><div className="h-4 rounded animate-shimmer w-1/3"></div></td>
                    <td className="px-6 py-4.5"><div className="h-8 rounded animate-shimmer w-24 ml-auto"></div></td>
                  </tr>
                ))
              ) : filteredPatients.length === 0 ? (
                <tr>
                  <td colSpan={5} className="px-6 py-16 text-center text-secondary-500">
                    <User className="w-10 h-10 mx-auto mb-3 text-secondary-300 dark:text-secondary-700" />
                    <p className="font-bold text-sm">No patients found</p>
                    <p className="text-xs text-secondary-400 mt-1">Try modifying search tags or filters</p>
                  </td>
                </tr>
              ) : (
                filteredPatients.map((patient) => (
                  <tr 
                    key={patient.id}
                    className="hover:bg-primary-50/10 dark:hover:bg-primary-950/5 transition-colors duration-200"
                  >
                    <td className="px-6 py-4.5">
                      <div className="flex items-center space-x-3.5">
                        <div className="w-11 h-11 rounded-2xl bg-gradient-to-br from-primary-500/10 to-teal-500/5 dark:from-primary-500/20 dark:to-teal-500/10 flex items-center justify-center text-primary-600 dark:text-primary-400 font-extrabold border border-primary-500/10 shadow-sm text-sm">
                          {(patient.firstName?.[0] || 'P')}{(patient.lastName?.[0] || '')}
                        </div>
                        <div>
                          <p className="font-extrabold text-secondary-900 dark:text-white text-sm leading-snug">
                            {patient.firstName || 'Patient'} {patient.lastName || ''}
                          </p>
                          <p className="text-[10px] text-secondary-400 font-bold mt-1 uppercase tracking-widest">ID: #{patient.id?.slice(0, 8) || ''}</p>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4.5">
                      <div className="flex flex-col space-y-1">
                        <span className="text-secondary-900 dark:text-slate-100 font-extrabold text-xs">
                          {patient.gender} • {new Date().getFullYear() - new Date(patient.dateOfBirth).getFullYear()} Yrs
                        </span>
                        <div className="flex items-center space-x-1.5 text-[10px] font-black text-secondary-400">
                          <Droplets className="w-3.5 h-3.5 text-red-500 fill-red-500" />
                          <span className="text-red-650 dark:text-red-400">{patient.bloodGroup}</span>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4.5">
                       <p className="text-secondary-900 dark:text-white font-extrabold text-xs">{patient.phone || '—'}</p>
                       <p className="text-[10px] text-secondary-400 font-semibold truncate max-w-[150px] mt-1" title={patient.address || ''}>
                         {patient.address || '—'}
                       </p>
                    </td>
                    <td className="px-6 py-4.5">
                       <div className="flex items-center space-x-2 text-secondary-900 dark:text-slate-100 font-extrabold text-xs">
                          <Calendar className="w-4 h-4 text-primary-500" />
                          <span>{new Date(patient.createdAt).toLocaleDateString()}</span>
                       </div>
                    </td>
                    <td className="px-6 py-4.5 text-right">
                      <div className="flex items-center justify-end space-x-2">
                        <button 
                          onClick={() => { setSelectedPatient(patient); setIsViewModalOpen(true); }}
                          className="p-2 text-secondary-400 hover:text-primary-600 dark:hover:text-primary-400 transition-colors rounded-xl hover:bg-secondary-100 dark:hover:bg-slate-800/60 cursor-pointer"
                        >
                          <Eye className="w-4 h-4" />
                        </button>
                        <button className="p-2 text-secondary-400 hover:text-blue-600 dark:hover:text-blue-400 transition-colors rounded-xl hover:bg-secondary-100 dark:hover:bg-slate-800/60 cursor-pointer">
                          <Edit2 className="w-4 h-4" />
                        </button>
                        <button className="p-2 text-secondary-400 hover:text-red-650 dark:hover:text-red-400 transition-colors rounded-xl hover:bg-secondary-100 dark:hover:bg-slate-800/60 cursor-pointer">
                          <Trash2 className="w-4 h-4" />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>

        {/* Pagination */}
        <div className="p-5 border-t border-secondary-200/30 dark:border-slate-800/50 flex flex-col sm:flex-row items-center justify-between bg-secondary-50/30 dark:bg-slate-900/20 gap-4">
          <p className="text-xs text-secondary-500 font-semibold">
            Showing <span className="font-extrabold text-secondary-950 dark:text-white">{patients.length}</span> of <span className="font-extrabold text-secondary-950 dark:text-white">{totalCount}</span> results
          </p>
          
          <div className="flex items-center space-x-1.5">
            <Button
              variant="ghost"
              size="sm"
              className="p-2 rounded-xl"
              disabled={currentPage === 1}
              onClick={() => onPageChange(currentPage - 1)}
            >
              <ChevronLeft className="w-4 h-4" />
            </Button>
            
            <div className="flex items-center space-x-1">
               {getPageNumbers().map((page, index) => {
                  if (page === '...') {
                    return (
                      <span key={`ellipsis-${index}`} className="px-2 text-xs font-bold text-secondary-400">
                        ...
                      </span>
                    );
                  }
                  return (
                    <button
                      key={page}
                      onClick={() => onPageChange(page as number)}
                      className={cn(
                        'w-8 h-8 rounded-xl text-xs font-bold transition-all duration-300 cursor-pointer',
                        currentPage === page 
                          ? 'bg-primary-600 text-white shadow-md' 
                          : 'text-secondary-500 hover:bg-secondary-100 dark:hover:bg-slate-800/60'
                      )}
                    >
                      {page}
                    </button>
                  );
               })}
            </div>

            <Button
              variant="ghost"
              size="sm"
              className="p-2 rounded-xl"
              disabled={currentPage === totalPages}
              onClick={() => onPageChange(currentPage + 1)}
            >
              <ChevronRight className="w-4 h-4" />
            </Button>
          </div>
        </div>
      </div>

      {/* Elegant Patient Details Modal */}
      {isViewModalOpen && selectedPatient && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
          <div 
            onClick={() => { setIsViewModalOpen(false); setSelectedPatient(null); }}
            className="fixed inset-0 bg-slate-950/40 backdrop-blur-md transition-opacity duration-300"
          />

          <Card className="w-full max-w-xl border-none shadow-2xl relative z-10 overflow-hidden bg-white/90 dark:bg-slate-950/90 backdrop-blur-xl rounded-3xl animate-scaleIn transform duration-350 p-0">
            {/* Header with patient initials */}
            <div className="h-32 bg-gradient-to-r from-primary-600 via-primary-750 to-teal-800 relative flex items-end px-6 pb-5">
              <button 
                onClick={() => { setIsViewModalOpen(false); setSelectedPatient(null); }}
                className="absolute top-4 right-4 p-2 rounded-xl bg-black/10 hover:bg-black/20 transition-colors text-white cursor-pointer"
              >
                <X className="w-4 h-4" />
              </button>
              
              <div className="flex items-center space-x-4">
                <div className="w-16 h-16 rounded-2xl bg-white/20 backdrop-blur-md border border-white/35 flex items-center justify-center text-white text-xl font-black shadow-inner">
                  {(selectedPatient?.firstName?.[0] || 'P')}{(selectedPatient?.lastName?.[0] || '')}
                </div>
                <div>
                  <h2 className="text-xl font-black text-white leading-tight">
                    {selectedPatient?.firstName || 'Patient'} {selectedPatient?.lastName || ''}
                  </h2>
                  <p className="text-[10px] font-black text-white/80 uppercase tracking-widest mt-1">
                    Patient Profile • ID: #{selectedPatient?.id?.slice(0, 8).toUpperCase() || ''}
                  </p>
                </div>
              </div>
            </div>

            <div className="p-6 space-y-6">
              {/* Demographics and Vitals Grid */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="p-4 bg-secondary-50/50 dark:bg-slate-900/30 border border-secondary-200/20 dark:border-slate-800/40 rounded-2xl space-y-3 shadow-inner">
                  <h4 className="text-[10px] font-black text-secondary-400 dark:text-secondary-500 uppercase tracking-widest">Demographics</h4>
                  <div className="grid grid-cols-2 gap-2 text-xs">
                    <div>
                      <span className="text-[9px] text-secondary-400 font-bold block uppercase tracking-wider">Gender</span>
                      <span className="font-extrabold text-secondary-900 dark:text-slate-100">{selectedPatient.gender}</span>
                    </div>
                    <div>
                      <span className="text-[9px] text-secondary-400 font-bold block uppercase tracking-wider">Date of Birth</span>
                      <span className="font-extrabold text-secondary-900 dark:text-slate-100">
                        {new Date(selectedPatient.dateOfBirth).toLocaleDateString(undefined, { year: 'numeric', month: 'short', day: 'numeric' })}
                      </span>
                    </div>
                  </div>
                </div>

                <div className="p-4 bg-secondary-50/50 dark:bg-slate-900/30 border border-secondary-200/20 dark:border-slate-800/40 rounded-2xl space-y-3 shadow-inner">
                  <h4 className="text-[10px] font-black text-secondary-400 dark:text-secondary-500 uppercase tracking-widest">Clinical Vitals</h4>
                  <div className="grid grid-cols-2 gap-2 text-xs">
                    <div>
                      <span className="text-[9px] text-secondary-400 font-bold block uppercase tracking-wider">Blood Group</span>
                      <span className="font-black text-red-650 dark:text-red-400 flex items-center">
                        <Droplets className="w-4 h-4 mr-1.5" />
                        {selectedPatient.bloodGroup}
                      </span>
                    </div>
                    <div>
                      <span className="text-[9px] text-secondary-400 font-bold block uppercase tracking-wider">Age</span>
                      <span className="font-extrabold text-secondary-900 dark:text-slate-100">
                        {new Date().getFullYear() - new Date(selectedPatient.dateOfBirth).getFullYear()} Years Old
                      </span>
                    </div>
                  </div>
                </div>
              </div>

              {/* Contact details */}
              <div className="p-4 bg-secondary-50/50 dark:bg-slate-900/30 border border-secondary-200/20 dark:border-slate-800/40 rounded-2xl space-y-3 shadow-inner">
                <h4 className="text-[10px] font-black text-secondary-400 dark:text-secondary-500 uppercase tracking-widest">Contact Information</h4>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-3 text-xs">
                  <div className="flex items-center text-secondary-700 dark:text-slate-300 font-bold">
                    <User className="w-4 h-4 mr-3 text-secondary-400 shrink-0" />
                    <span className="truncate">Emergency: {selectedPatient.emergencyContactName || 'None'}</span>
                  </div>
                  <div className="flex items-center text-secondary-700 dark:text-slate-300 font-bold">
                    <Calendar className="w-4 h-4 mr-3 text-secondary-400 shrink-0" />
                    <span>Registered: {new Date(selectedPatient.createdAt).toLocaleDateString()}</span>
                  </div>
                  <div className="flex items-center text-secondary-700 dark:text-slate-300 font-bold">
                    <Phone className="w-4 h-4 mr-3 text-secondary-400 shrink-0" />
                    <span>Phone: {selectedPatient.phone || 'None'}</span>
                  </div>
                  <div className="flex items-center text-secondary-700 dark:text-slate-300 font-bold col-span-1 md:col-span-2">
                    <Eye className="w-4 h-4 mr-3 text-secondary-400 shrink-0" />
                    <span className="truncate" title={selectedPatient.address || ''}>Address: {selectedPatient.address || 'None'}</span>
                  </div>
                </div>
              </div>
            </div>

            {/* Footer buttons */}
            <div className="p-5 border-t border-secondary-100 dark:border-slate-850 flex space-x-3 bg-secondary-50/30 dark:bg-slate-900/10">
              <button 
                onClick={() => { setIsViewModalOpen(false); setSelectedPatient(null); }}
                className="flex-1 py-3 rounded-2xl border border-secondary-200 dark:border-slate-800 hover:bg-secondary-50 dark:hover:bg-slate-900/50 text-xs font-bold text-secondary-700 dark:text-secondary-300 transition-colors cursor-pointer"
              >
                Close Profile
              </button>
              <button 
                className="flex-1 py-3 rounded-2xl bg-gradient-to-r from-primary-600 to-primary-700 hover:from-primary-500 hover:to-primary-600 text-xs font-extrabold text-white shadow-md shadow-primary-600/15 transition-all cursor-pointer"
              >
                Access Medical History
              </button>
            </div>
          </Card>
        </div>
      )}
    </div>
  );
};
