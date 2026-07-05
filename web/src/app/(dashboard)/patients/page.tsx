'use client';

import React, { useEffect, useState } from 'react';
import { PatientTable } from '@/presentation/components/PatientTable';
import { AddPatientModal } from '@/presentation/components/AddPatientModal';
import { useAppDispatch, useAppSelector } from '@/presentation/store/hooks';
import { fetchPatients } from '@/presentation/store/slices/patientSlice';

export default function PatientsPage() {
  const dispatch = useAppDispatch();
  const { patients, totalCount, isLoading } = useAppSelector((state) => state.patients);
  const [currentPage, setCurrentPage] = useState(1);
  const [searchTerm, setSearchTerm] = useState('');
  const [isModalOpen, setIsModalOpen] = useState(false);

  const loadPatients = () => {
    dispatch(fetchPatients({ search: searchTerm, page: currentPage }));
  };

  useEffect(() => {
    loadPatients();
  }, [dispatch, currentPage, searchTerm]);

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-3xl font-bold text-secondary-900">Patient Explorer</h1>
        <p className="text-secondary-500 mt-2">Manage and view detailed records of all your patients.</p>
      </div>

      <PatientTable
        patients={patients}
        totalCount={totalCount}
        isLoading={isLoading}
        currentPage={currentPage}
        onPageChange={setCurrentPage}
        onSearch={setSearchTerm}
        onAddClick={() => setIsModalOpen(true)}
      />

      <AddPatientModal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        onSuccess={loadPatients}
      />
    </div>
  );
}
