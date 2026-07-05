'use client';

import React, { useEffect, useState } from 'react';
import { Card } from '@/presentation/components/Card';
import { 
  User, 
  Search, 
  Filter, 
  Mail, 
  Phone, 
  BadgeCheck, 
  ChevronLeft, 
  ChevronRight, 
  X, 
  Calendar, 
  ShieldAlert, 
  Clock,
  Activity
} from 'lucide-react';
import api from '@/core/api';

interface Nurse {
  id: string;
  firstName: string;
  lastName: string;
  email: string;
  phoneNumber: string | null;
  role: string;
  isActive: boolean;
  createdAt: string;
  lastLogin: string | null;
}

export default function NursesPage() {
  const [nurses, setNurses] = useState<Nurse[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState<'all' | 'active' | 'inactive'>('all');
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [totalCount, setTotalCount] = useState(0);
  const [selectedNurse, setSelectedNurse] = useState<Nurse | null>(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const pageSize = 6;

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

  useEffect(() => {
    const fetchNurses = async () => {
      setLoading(true);
      try {
        const params: any = {
          page: currentPage,
          pageSize: pageSize,
        };

        if (search) {
          params.search = search;
        }

        if (statusFilter !== 'all') {
          params.isActive = statusFilter === 'active';
        }

        const res = await api.get('/nurses', { params });
        if (res.data && res.data.success) {
          setNurses(res.data.data);
          setTotalPages(res.data.pagination.totalPages);
          setTotalCount(res.data.pagination.totalCount);
        }
      } catch (err) {
        console.error('Error fetching nurses:', err);
      } finally {
        setLoading(false);
      }
    };

    const timer = setTimeout(() => {
      fetchNurses();
    }, 300);

    return () => clearTimeout(timer);
  }, [search, statusFilter, currentPage]);

  const handleSearchChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setSearch(e.target.value);
    setCurrentPage(1); // Reset to page 1 on new search
  };

  const handleFilterChange = (filter: 'all' | 'active' | 'inactive') => {
    setStatusFilter(filter);
    setCurrentPage(1); // Reset to page 1 on filter change
  };

  const openProfile = (nurse: Nurse) => {
    setSelectedNurse(nurse);
    setIsModalOpen(true);
  };

  const closeProfile = () => {
    setIsModalOpen(false);
    setSelectedNurse(null);
  };

  return (
    <div className="space-y-8 animate-fadeIn pb-12">
      {/* Header section */}
      <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
        <div>
          <h1 className="text-4xl font-black text-gray-900 dark:text-white tracking-tight">
            Nurses Explorer
          </h1>
          <p className="text-gray-500 mt-1 font-medium text-sm md:text-base italic opacity-75">
            Manage and connect with our dedicated clinical nursing staff.
          </p>
        </div>
        <div className="flex items-center space-x-2 bg-primary-50 dark:bg-primary-950/20 px-4 py-2 rounded-2xl border border-primary-100 dark:border-primary-900/50">
          <Activity className="w-5 h-5 text-primary-600 dark:text-primary-400 animate-pulse" />
          <span className="text-xs font-bold text-primary-800 dark:text-primary-300">
            {totalCount} Total Support Staff
          </span>
        </div>
      </div>

      {/* Filter and Search controls */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-4 items-center">
        {/* Search input */}
        <Card className="lg:col-span-2 p-3 border-none shadow-sm flex items-center bg-white/70 dark:bg-gray-900/70 backdrop-blur-md">
          <div className="relative w-full">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
            <input 
              type="text" 
              placeholder="Search nurses by name, email, or department..." 
              value={search}
              onChange={handleSearchChange}
              className="w-full bg-transparent pl-11 pr-4 py-2 text-sm focus:outline-none dark:text-white placeholder-gray-400 font-medium"
            />
          </div>
        </Card>

        {/* Tab Filters */}
        <Card className="p-1.5 border-none shadow-sm flex bg-gray-100 dark:bg-gray-800 rounded-2xl">
          <button 
            onClick={() => handleFilterChange('all')}
            className={`flex-1 py-2 text-xs font-bold rounded-xl transition-all ${statusFilter === 'all' ? 'bg-white dark:bg-gray-900 text-gray-900 dark:text-white shadow-sm' : 'text-gray-500 dark:text-gray-400 hover:text-gray-900 dark:hover:text-white'}`}
          >
            All
          </button>
          <button 
            onClick={() => handleFilterChange('active')}
            className={`flex-1 py-2 text-xs font-bold rounded-xl transition-all ${statusFilter === 'active' ? 'bg-white dark:bg-gray-900 text-emerald-600 dark:text-emerald-400 shadow-sm' : 'text-gray-500 dark:text-gray-400 hover:text-emerald-600'}`}
          >
            Active
          </button>
          <button 
            onClick={() => handleFilterChange('inactive')}
            className={`flex-1 py-2 text-xs font-bold rounded-xl transition-all ${statusFilter === 'inactive' ? 'bg-white dark:bg-gray-900 text-red-600 dark:text-red-400 shadow-sm' : 'text-gray-500 dark:text-gray-400 hover:text-red-600'}`}
          >
            Inactive
          </button>
        </Card>
      </div>

      {/* Nurses Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {loading ? (
          [1, 2, 3, 4, 5, 6].map(i => (
            <div key={i} className="h-64 animate-shimmer rounded-3xl bg-gray-100 dark:bg-gray-800/40 border border-gray-200/50 dark:border-gray-700/30" />
          ))
        ) : nurses.length === 0 ? (
          <div className="col-span-full py-16 text-center">
            <ShieldAlert className="w-12 h-12 text-gray-300 dark:text-gray-700 mx-auto mb-4" />
            <p className="text-gray-400 dark:text-gray-500 font-bold italic text-base">No support nurses found matching your query.</p>
          </div>
        ) : (
          nurses.map((nurse) => (
            <Card 
              key={nurse.id} 
              className="p-6 border-none shadow-sm hover:shadow-lg transition-all duration-300 group hover:-translate-y-1 relative overflow-hidden bg-white dark:bg-gray-900"
            >
              <div className="absolute top-0 right-0 w-24 h-24 bg-primary-500/5 rounded-full blur-2xl group-hover:bg-primary-500/10 transition-colors" />
              
              <div className="flex items-start justify-between">
                <div className="w-14 h-14 rounded-2xl bg-primary-50 dark:bg-primary-950/30 flex items-center justify-center text-primary-600 dark:text-primary-400 group-hover:scale-110 transition-transform duration-300">
                  <User className="w-7 h-7" />
                </div>
                <div className={`px-2.5 py-1 rounded-full text-[10px] font-extrabold uppercase tracking-wider ${nurse.isActive ? 'bg-emerald-50 text-emerald-700 border border-emerald-200 dark:bg-emerald-950/20 dark:text-emerald-400 dark:border-emerald-800/50' : 'bg-red-50 text-red-700 border border-red-200 dark:bg-red-950/20 dark:text-red-400 dark:border-red-800/50'}`}>
                  {nurse.isActive ? 'Active' : 'Inactive'}
                </div>
              </div>

              <div className="mt-4">
                <h3 className="text-xl font-bold text-gray-900 dark:text-white group-hover:text-primary-600 dark:group-hover:text-primary-400 transition-colors">
                  {nurse.firstName} {nurse.lastName}
                </h3>
                <p className="text-xs text-gray-500 dark:text-gray-400 font-bold mt-1">
                  Nurse • Hospital ID: #{nurse.id.slice(0, 8).toUpperCase()}
                </p>
              </div>

              <div className="mt-6 pt-5 border-t border-gray-50 dark:border-gray-800/60 space-y-3">
                <div className="flex items-center text-xs font-medium text-gray-600 dark:text-gray-400">
                  <Mail className="w-4 h-4 mr-3 text-gray-400" />
                  {nurse.email}
                </div>
                <div className="flex items-center text-xs font-medium text-gray-600 dark:text-gray-400">
                  <Phone className="w-4 h-4 mr-3 text-gray-400" />
                  {nurse.phoneNumber || 'Not provided'}
                </div>
              </div>

              <button 
                onClick={() => openProfile(nurse)}
                className="w-full mt-6 py-3 rounded-2xl bg-gray-50 hover:bg-primary-600 dark:bg-gray-800/40 dark:hover:bg-primary-600 text-xs font-black text-gray-700 dark:text-gray-300 hover:text-white transition-all duration-300 shadow-sm"
              >
                View Full Profile
              </button>
            </Card>
          ))
        )}
      </div>

      {/* Pagination Controls */}
      {totalPages > 1 && (
        <div className="flex items-center justify-center space-x-2 pt-6">
          <button 
            onClick={() => setCurrentPage(prev => Math.max(prev - 1, 1))}
            disabled={currentPage === 1}
            className="p-2.5 rounded-2xl border border-gray-200 dark:border-gray-800 bg-white dark:bg-gray-900 disabled:opacity-40 hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors"
          >
            <ChevronLeft className="w-5 h-5 text-gray-600 dark:text-gray-400" />
          </button>
          
          {getPageNumbers().map((page, index) => {
            if (page === '...') {
              return (
                <span key={`ellipsis-${index}`} className="px-3 text-sm font-bold text-gray-400 dark:text-gray-600">
                  ...
                </span>
              );
            }
            return (
              <button 
                key={page}
                onClick={() => setCurrentPage(page as number)}
                className={`w-10 h-10 rounded-2xl font-black text-xs transition-all ${currentPage === page ? 'bg-primary-600 text-white shadow-md' : 'border border-gray-200 dark:border-gray-800 bg-white dark:bg-gray-900 text-gray-600 dark:text-gray-400 hover:bg-gray-50 dark:hover:bg-gray-800'}`}
              >
                {page}
              </button>
            );
          })}

          <button 
            onClick={() => setCurrentPage(prev => Math.min(prev + 1, totalPages))}
            disabled={currentPage === totalPages}
            className="p-2.5 rounded-2xl border border-gray-200 dark:border-gray-800 bg-white dark:bg-gray-900 disabled:opacity-40 hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors"
          >
            <ChevronRight className="w-5 h-5 text-gray-600 dark:text-gray-400" />
          </button>
        </div>
      )}

      {/* Elegant Profile Modal */}
      {isModalOpen && selectedNurse && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
          {/* Backdrop glassmorphism */}
          <div 
            onClick={closeProfile}
            className="fixed inset-0 bg-gray-950/40 backdrop-blur-md transition-opacity duration-300"
          />

          {/* Modal Content */}
          <Card className="w-full max-w-lg border-none shadow-2xl relative z-10 overflow-hidden bg-white dark:bg-gray-900 rounded-3xl animate-scaleIn transform duration-300">
            {/* Modal Header styling */}
            <div className="h-28 bg-gradient-to-r from-primary-600 to-indigo-600 relative">
              <button 
                onClick={closeProfile}
                className="absolute top-4 right-4 p-2 rounded-full bg-black/10 hover:bg-black/20 transition-colors text-white"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            {/* Profile Avatar & Title */}
            <div className="px-6 pb-6 relative">
              <div className="absolute -top-12 left-6 w-24 h-24 rounded-3xl border-4 border-white dark:border-gray-900 bg-primary-50 dark:bg-primary-950/50 flex items-center justify-center text-primary-600 dark:text-primary-400 shadow-md">
                <User className="w-12 h-12" />
              </div>

              <div className="pt-16">
                <div className="flex items-center space-x-3">
                  <h2 className="text-2xl font-black text-gray-900 dark:text-white">
                    {selectedNurse.firstName} {selectedNurse.lastName}
                  </h2>
                  <div className={`px-2.5 py-0.5 rounded-full text-[9px] font-extrabold uppercase tracking-wider ${selectedNurse.isActive ? 'bg-emerald-100 text-emerald-800 dark:bg-emerald-950/30 dark:text-emerald-400' : 'bg-red-100 text-red-800 dark:bg-red-950/30 dark:text-red-400'}`}>
                    {selectedNurse.isActive ? 'Active' : 'Inactive'}
                  </div>
                </div>
                <p className="text-xs font-bold text-gray-500 dark:text-gray-400 mt-1 uppercase tracking-wider">
                  Senior Support Nurse • Medical Staff Group
                </p>
              </div>

              {/* Nurse Info Panels */}
              <div className="mt-6 space-y-4">
                {/* Contact Panel */}
                <div className="p-4 bg-gray-50 dark:bg-gray-800/40 rounded-2xl space-y-3">
                  <h4 className="text-xs font-extrabold text-gray-400 uppercase tracking-widest">Contact Information</h4>
                  <div className="flex items-center text-sm font-semibold text-gray-700 dark:text-gray-300">
                    <Mail className="w-4 h-4 mr-3 text-gray-400" />
                    {selectedNurse.email}
                  </div>
                  <div className="flex items-center text-sm font-semibold text-gray-700 dark:text-gray-300">
                    <Phone className="w-4 h-4 mr-3 text-gray-400" />
                    {selectedNurse.phoneNumber || 'Not provided'}
                  </div>
                </div>

                {/* Account Details Panel */}
                <div className="p-4 bg-gray-50 dark:bg-gray-800/40 rounded-2xl space-y-3">
                  <h4 className="text-xs font-extrabold text-gray-400 uppercase tracking-widest">System Details</h4>
                  <div className="flex items-center text-xs font-semibold text-gray-700 dark:text-gray-300">
                    <Calendar className="w-4 h-4 mr-3 text-gray-400" />
                    <span>Registered on {new Date(selectedNurse.createdAt).toLocaleDateString(undefined, { year: 'numeric', month: 'long', day: 'numeric' })}</span>
                  </div>
                  <div className="flex items-center text-xs font-semibold text-gray-700 dark:text-gray-300">
                    <Clock className="w-4 h-4 mr-3 text-gray-400" />
                    <span>Last Login: {selectedNurse.lastLogin ? new Date(selectedNurse.lastLogin).toLocaleString() : 'Never logged in'}</span>
                  </div>
                </div>
              </div>

              {/* Action Buttons */}
              <div className="mt-6 flex space-x-3">
                <button 
                  onClick={closeProfile}
                  className="flex-1 py-3.5 rounded-2xl border border-gray-200 dark:border-gray-800 hover:bg-gray-50 dark:hover:bg-gray-800 text-xs font-bold text-gray-700 dark:text-gray-300 transition-colors"
                >
                  Close Details
                </button>
                <button 
                  className="flex-1 py-3.5 rounded-2xl bg-primary-600 hover:bg-primary-700 text-xs font-extrabold text-white shadow-md hover:shadow-lg transition-all"
                >
                  Contact Staff
                </button>
              </div>
            </div>
          </Card>
        </div>
      )}
    </div>
  );
}
