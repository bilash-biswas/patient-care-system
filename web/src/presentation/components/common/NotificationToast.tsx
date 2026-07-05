'use client';

import { useEffect, useState, useCallback } from 'react';
import { useAppDispatch, useAppSelector } from '@/presentation/store/hooks';
import { markAsRead, NotificationItem } from '@/presentation/store/slices/chatSlice';
import { Bell, X } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';

export const NotificationToast = () => {
  const dispatch = useAppDispatch();
  const { notifications } = useAppSelector((state) => state.chat);
  const [current, setCurrent] = useState<NotificationItem | null>(null);

  const handleClose = useCallback(() => {
    if (current) {
      dispatch(markAsRead(current.id));
    }
    setCurrent(null);
  }, [current, dispatch]);

  useEffect(() => {
    const unread = notifications.find((n) => !n.isRead);
    
    // Only display if we have an unread item and it is different from the current toast
    if (unread && (!current || current.id !== unread.id)) {
      setCurrent(unread);
      const timer = setTimeout(() => {
        dispatch(markAsRead(unread.id));
        setCurrent(null);
      }, 5000);
      return () => clearTimeout(timer);
    }
  }, [notifications, current, dispatch]);

  return (
    <AnimatePresence>
      {current && (
        <motion.div
          initial={{ opacity: 0, y: 50, scale: 0.9 }}
          animate={{ opacity: 1, y: 0, scale: 1 }}
          exit={{ opacity: 0, scale: 0.9, transition: { duration: 0.2 } }}
          className="fixed bottom-8 right-8 z-[100] w-96"
        >
          <div className="bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 rounded-2xl shadow-2xl p-4 flex items-start space-x-4">
            <div className="p-2 rounded-xl bg-blue-50 dark:bg-blue-900/20 text-blue-600 dark:text-blue-400">
              <Bell className="w-5 h-5" />
            </div>
            <div className="flex-1">
              <div className="flex justify-between items-start">
                <h4 className="text-sm font-bold text-gray-900 dark:text-white">New Notification</h4>
                <button onClick={handleClose} className="text-gray-400 hover:text-gray-600 dark:hover:text-gray-200 cursor-pointer">
                  <X className="w-4 h-4" />
                </button>
              </div>
              <p className="text-sm text-gray-500 dark:text-gray-400 mt-1 leading-relaxed">
                {current.message}
              </p>
            </div>
          </div>
        </motion.div>
      )}
    </AnimatePresence>
  );
};
