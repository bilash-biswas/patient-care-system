'use client';

import { useEffect, useState } from 'react';
import { useRouter, usePathname } from 'next/navigation';
import { useAppSelector, useAppDispatch } from '@/presentation/store/hooks';
import { Sidebar } from '@/presentation/components/Sidebar';
import { signalRService } from '@/core/services/SignalRService';
import { Bell, Search, MessageSquare, Calendar, Info, CheckCheck, Trash2 } from 'lucide-react';
import { NotificationToast } from '@/presentation/components/common/NotificationToast';
import { markAsRead, markAllAsRead, clearNotifications } from '@/presentation/store/slices/chatSlice';

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const router = useRouter();
  const pathname = usePathname();
  const dispatch = useAppDispatch();
  const { isAuthenticated, user } = useAppSelector((state) => state.auth);
  const { notifications } = useAppSelector((state) => state.chat);
  const [mounted, setMounted] = useState(false);
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  const unreadCount = notifications.filter((n) => !n.isRead).length;

  useEffect(() => {
    setTimeout(() => {
      setMounted(true);
    }, 0);
    const token = typeof window !== 'undefined' ? localStorage.getItem('token') : null;
    if (!isAuthenticated && !token) {
      router.push('/login');
    } else if (token) {
      signalRService.startConnections(token);
    }

    return () => {
      signalRService.stopConnections();
    };
  }, [isAuthenticated, router]);

  if (!mounted || (!isAuthenticated && (typeof window !== 'undefined' && !localStorage.getItem('token')))) {
    return (
      <div className="flex h-screen w-screen items-center justify-center bg-[var(--background)]">
        <div className="animate-shimmer w-8 h-8 rounded-full"></div>
      </div>
    );
  }

  const getPageTitle = () => {
    const paths = pathname.split('/').filter(p => p);
    if (paths.length === 0) return 'Dashboard';
    
    const lastSegment = paths[paths.length - 1];
    const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
    
    if (uuidRegex.test(lastSegment)) {
      const parent = paths[paths.length - 2];
      if (parent === 'doctors') return 'Doctor Profile';
      if (parent === 'nurses') return 'Nurse Profile';
      if (parent === 'patients') return 'Patient Profile';
      return 'Details';
    }
    
    const title = lastSegment;
    return title.charAt(0).toUpperCase() + title.slice(1).replace('-', ' ');
  };

  return (
    <div className="flex min-h-screen bg-[var(--background)]">
      <Sidebar />
      
      <div className="flex-1 ml-64 flex flex-col min-h-screen">
        {/* Minimal TopBar */}
        <header className="h-20 border-b border-secondary-200/30 dark:border-slate-900/50 px-8 flex items-center justify-between sticky top-0 z-30 bg-white/70 dark:bg-slate-950/70 backdrop-blur-md transition-all duration-300">
          <div className="flex items-center space-x-4">
            <h1 className="text-2xl font-black text-secondary-900 dark:text-white tracking-tight">
              {getPageTitle()}
            </h1>
          </div>

          <div className="flex items-center space-x-4">
            <div className="relative hidden md:block group">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-secondary-400 group-focus-within:text-primary-500 transition-colors" />
              <input 
                type="text" 
                placeholder="Search anything..." 
                className="input-field !pl-9 py-2 text-xs w-64 bg-secondary-50/50 dark:bg-slate-900/50 border-secondary-200/50 dark:border-slate-800/60 focus:w-80 shadow-inner"
              />
            </div>
            
            <div className="relative">
              <button 
                onClick={() => setIsDropdownOpen(!isDropdownOpen)}
                className="relative p-2.5 text-secondary-500 hover:text-primary-600 dark:hover:text-primary-400 hover:bg-primary-50 dark:hover:bg-primary-950/20 transition-all rounded-xl cursor-pointer"
              >
                <Bell className="w-5 h-5" />
                {unreadCount > 0 && (
                  <span className="absolute top-2 right-2 px-1.5 py-0.5 text-[9px] font-bold text-white bg-red-500 rounded-full leading-none flex items-center justify-center min-w-[16px] min-h-[16px] border border-white dark:border-slate-950">
                    {unreadCount}
                  </span>
                )}
              </button>

              {isDropdownOpen && (
                <>
                  <div 
                    className="fixed inset-0 z-40" 
                    onClick={() => setIsDropdownOpen(false)}
                  />
                  <div className="absolute right-0 mt-3 w-80 md:w-96 bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 rounded-2xl shadow-2xl z-50 overflow-hidden transform origin-top-right transition-all duration-300">
                    <div className="px-4 py-3.5 border-b border-slate-200 dark:border-slate-800 flex items-center justify-between bg-slate-50 dark:bg-slate-900/50">
                      <h3 className="text-sm font-extrabold text-secondary-900 dark:text-white flex items-center">
                        <Bell className="w-4 h-4 mr-2 text-primary-500" />
                        Notifications
                      </h3>
                      {unreadCount > 0 && (
                        <button 
                          onClick={() => dispatch(markAllAsRead())}
                          className="text-xs font-bold text-primary-600 dark:text-primary-400 hover:underline flex items-center cursor-pointer"
                        >
                          <CheckCheck className="w-3.5 h-3.5 mr-1" />
                          Read all
                        </button>
                      )}
                    </div>
                    
                    <div className="max-h-[320px] overflow-y-auto">
                      {notifications.length === 0 ? (
                        <div className="px-4 py-8 text-center text-secondary-400 dark:text-slate-500">
                          <Bell className="w-8 h-8 mx-auto mb-2 opacity-40" />
                          <p className="text-xs font-semibold">No notifications yet</p>
                        </div>
                      ) : (
                        notifications.map((item) => {
                          const isChat = item.message.toLowerCase().includes('message') || item.message.toLowerCase().includes('chat');
                          const isAppt = item.message.toLowerCase().includes('appointment') || item.message.toLowerCase().includes('schedule');
                          
                          return (
                            <div 
                              key={item.id}
                              onClick={() => !item.isRead && dispatch(markAsRead(item.id))}
                              className={`px-4 py-3 border-b border-slate-100 dark:border-slate-800/50 flex items-start space-x-3 transition-colors cursor-pointer hover:bg-slate-50 dark:hover:bg-slate-800/30 ${
                                !item.isRead ? 'bg-primary-50/20 dark:bg-primary-950/5' : ''
                              }`}
                            >
                              <div className={`p-2 rounded-lg shrink-0 ${
                                isChat 
                                  ? 'bg-green-50 dark:bg-green-950/20 text-green-600 dark:text-green-400' 
                                  : isAppt 
                                    ? 'bg-blue-50 dark:bg-blue-950/20 text-blue-600 dark:text-blue-400' 
                                    : 'bg-primary-50 dark:bg-primary-950/20 text-primary-600 dark:text-primary-400'
                              }`}>
                                {isChat ? <MessageSquare className="w-4 h-4" /> : isAppt ? <Calendar className="w-4 h-4" /> : <Info className="w-4 h-4" />}
                              </div>
                              <div className="flex-1 min-w-0">
                                <p className={`text-xs leading-normal ${!item.isRead ? 'font-bold text-slate-900 dark:text-white' : 'text-slate-500 dark:text-slate-400'}`}>
                                  {item.message}
                                </p>
                                <span className="text-[10px] text-slate-400 dark:text-slate-500 mt-1 block font-medium">
                                  {new Date(item.sentAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                                </span>
                              </div>
                              {!item.isRead && (
                                <div className="w-2 h-2 rounded-full bg-primary-500 mt-1.5 shrink-0" />
                              )}
                            </div>
                          );
                        })
                      )}
                    </div>

                    {notifications.length > 0 && (
                      <div className="px-4 py-2 border-t border-slate-200 dark:border-slate-800 bg-slate-50 dark:bg-slate-900/50 flex justify-center">
                        <button 
                          onClick={() => dispatch(clearNotifications())}
                          className="text-xs font-bold text-red-600 dark:text-red-400 hover:underline flex items-center cursor-pointer py-1"
                        >
                          <Trash2 className="w-3.5 h-3.5 mr-1" />
                          Clear all
                        </button>
                      </div>
                    )}
                  </div>
                </>
              )}
            </div>
 
            <div className="flex items-center space-x-3 pl-4 border-l border-secondary-200/50 dark:border-slate-800/60">
               <div className="text-right hidden sm:block">
                  <p className="text-sm font-extrabold text-secondary-900 dark:text-white leading-tight">
                    {user?.firstName} {user?.lastName}
                  </p>
                  <p className="text-[10px] font-black text-primary-600 dark:text-primary-400 uppercase tracking-widest mt-0.5">
                    {user?.role}
                  </p>
               </div>
               <div className="w-9 h-9 rounded-xl bg-gradient-to-br from-primary-500 to-primary-600 flex items-center justify-center text-white font-black text-sm shadow-md shadow-primary-500/10">
                  {user?.firstName?.[0] || 'U'}
               </div>
            </div>
          </div>
        </header>

        {/* Main Content Area */}
        <main className="flex-1 p-8">
          <div className="max-w-7xl mx-auto">
            {children}
          </div>
        </main>
        
        <NotificationToast />
      </div>
    </div>
  );
}
