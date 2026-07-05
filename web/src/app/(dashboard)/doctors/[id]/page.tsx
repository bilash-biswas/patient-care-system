'use client';

import { useParams } from 'next/navigation';
import { PeoplePage } from '@/presentation/components/PeoplePage';

export default function DoctorDetailPage() {
  const params = useParams();
  const id = params.id as string;

  return (
    <PeoplePage 
      title="Doctors" 
      role="Doctor" 
      description="View and connect with medical professionals across all departments." 
      selectedDoctorId={id}
    />
  );
}
