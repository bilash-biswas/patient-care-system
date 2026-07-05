'use client';

import React from 'react';
import { Sidebar } from '@/presentation/components/Sidebar';

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="flex min-h-screen bg-secondary-50">
      <Sidebar />
      <main className="flex-1 p-8 ml-72 overflow-y-auto">
        <div className="max-w-7xl mx-auto">
          {children}
        </div>
      </main>
    </div>
  );
}
