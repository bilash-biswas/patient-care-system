'use client';

import { useState, useEffect, useRef } from 'react';
import { useAppDispatch, useAppSelector } from '@/presentation/store/hooks';
import { fetchConversations, fetchMessages, fetchDirectory, setActiveConversation, addMessage } from '@/presentation/store/slices/chatSlice';
import { signalRService } from '@/core/services/SignalRService';
import { Send, User as UserIcon, Paperclip, Search, MoreVertical, MessageSquare, Users } from 'lucide-react';
import { Card } from '@/presentation/components/Card';
import { Button } from '@/presentation/components/Button';

export default function ChatPage() {
  const dispatch = useAppDispatch();
  const { conversations, directory, directoryPagination, messages, activeConversationId, isOnline, isLoading } = useAppSelector((state) => state.chat);
  const { user } = useAppSelector((state) => state.auth);
  const [input, setInput] = useState('');
  const [view, setView] = useState<'recent' | 'directory'>('recent');
  const [chatSearch, setChatSearch] = useState('');
  const [dirPage, setDirPage] = useState(1);
  const scrollRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    dispatch(fetchConversations());
  }, [dispatch]);

  useEffect(() => {
    dispatch(fetchDirectory({ search: chatSearch, page: dirPage, pageSize: 8 }));
  }, [dispatch, chatSearch, dirPage]);

  useEffect(() => {
    if (activeConversationId) {
      dispatch(fetchMessages(activeConversationId));
    }
  }, [dispatch, activeConversationId]);

  useEffect(() => {
    scrollRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages, activeConversationId]);

  const handleSend = async () => {
    if (!input.trim() || !activeConversationId) return;
    
    try {
      await signalRService.sendMessage(activeConversationId, input);
      
      // Optimitically add message to local state
      dispatch(addMessage({
        id: Math.random().toString(), // Temp ID
        senderId: user!.id,
        receiverId: activeConversationId,
        content: input,
        sentAt: new Date().toISOString(),
        isRead: false
      }));
      
      setInput('');
    } catch (err) {
      console.error('Failed to send message', err);
    }
  };

  const activeMessages = activeConversationId ? (messages[activeConversationId] || []) : [];
  const activeContact = [...conversations, ...directory].find(c => c.id === activeConversationId);

  const displayList = view === 'recent' ? conversations : directory;

  return (
    <div className="flex h-[calc(100vh-12rem)] border border-secondary-200/40 dark:border-slate-805/40 bg-white/70 dark:bg-slate-900/60 backdrop-blur-md rounded-3xl overflow-hidden shadow-xl animate-fadeIn duration-300">
      {/* Sidebar */}
      <div className="w-80 border-r border-secondary-200/40 dark:border-slate-805/40 flex flex-col bg-secondary-50/20 dark:bg-slate-950/20">
        <div className="p-4.5 border-b border-secondary-200/40 dark:border-slate-805/40 space-y-4">
          <div className="flex p-1 bg-secondary-100/50 dark:bg-slate-950/50 rounded-2xl border border-secondary-200/20 dark:border-slate-805/40">
             <button 
               onClick={() => setView('recent')}
               className={`flex-1 flex items-center justify-center space-x-2 py-2 text-xs font-black rounded-xl transition-all cursor-pointer ${view === 'recent' ? 'bg-white dark:bg-slate-900 text-primary-600 dark:text-primary-400 shadow-sm border border-secondary-200/10 dark:border-slate-850/10' : 'text-secondary-400 hover:text-secondary-600 dark:hover:text-secondary-200'}`}
             >
               <MessageSquare className="w-4 h-4" />
               <span className="uppercase tracking-wider">Recent</span>
             </button>
             <button 
               onClick={() => setView('directory')}
               className={`flex-1 flex items-center justify-center space-x-2 py-2 text-xs font-black rounded-xl transition-all cursor-pointer ${view === 'directory' ? 'bg-white dark:bg-slate-900 text-primary-600 dark:text-primary-400 shadow-sm border border-secondary-200/10 dark:border-slate-850/10' : 'text-secondary-400 hover:text-secondary-600 dark:hover:text-secondary-200'}`}
             >
               <Users className="w-4 h-4" />
               <span className="uppercase tracking-wider">Directory</span>
             </button>
          </div>
          <div className="relative">
            <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-4.5 h-4.5 text-secondary-400" />
            <input 
              type="text" 
              value={chatSearch}
              onChange={(e) => { setChatSearch(e.target.value); setDirPage(1); }}
              placeholder={view === 'recent' ? "Search conversations..." : "Search directory..."}
              className="w-full bg-white dark:bg-slate-950/40 pl-11 pr-4 py-3 rounded-2xl text-xs focus:outline-none focus:ring-2 focus:ring-primary-500/10 border border-secondary-200/60 dark:border-slate-805/65 focus:border-primary-500 dark:text-white placeholder-secondary-400 font-bold transition-all shadow-inner"
            />
          </div>
        </div>
        
        <div className="flex-1 overflow-y-auto flex flex-col justify-between">
          <div className="divide-y divide-secondary-100/30 dark:divide-slate-805/20">
            {displayList.map((contact) => (
              <button 
                key={contact.id}
                onClick={() => {
                  dispatch(setActiveConversation(contact.id));
                  if (view === 'directory') setView('recent');
                }}
                className={`w-full p-4 flex items-center space-x-3.5 hover:bg-secondary-100/30 dark:hover:bg-slate-950/40 transition-colors cursor-pointer border-r-3 ${activeConversationId === contact.id ? 'bg-primary-500/5 dark:bg-primary-500/10 border-primary-500' : 'border-transparent'}`}
              >
                <div className="relative shrink-0">
                  <div className="w-11 h-11 rounded-2xl bg-secondary-100 dark:bg-slate-800 border border-secondary-200/40 dark:border-slate-850/40 flex items-center justify-center">
                    <UserIcon className="w-5.5 h-5.5 text-secondary-400" />
                  </div>
                  {isOnline && <div className="absolute -right-0.5 -bottom-0.5 w-3 h-3 rounded-full bg-emerald-500 border-2 border-white dark:border-slate-900 shadow-sm animate-pulse"></div>}
                </div>
                <div className="flex-1 text-left min-w-0">
                  <h4 className="text-xs font-black text-slate-800 dark:text-slate-200 truncate">{contact.firstName} {contact.lastName}</h4>
                  <p className="text-[9px] font-black text-primary-600 dark:text-primary-400 uppercase tracking-wider mt-0.5">{contact.role}</p>
                </div>
              </button>
            ))}
            
            {displayList.length === 0 && !isLoading && (
              <div className="p-8 text-center text-xs text-secondary-400 font-bold uppercase tracking-wider italic">
                {view === 'recent' ? 'No recent chats' : 'No contacts found'}
              </div>
            )}
          </div>

          {view === 'directory' && directoryPagination && directoryPagination.totalPages > 1 && (
            <div className="p-3 bg-white dark:bg-slate-900 border-t border-secondary-200/40 dark:border-slate-805/40 flex items-center justify-between sticky bottom-0 z-10 shadow-sm">
              <button
                disabled={dirPage === 1}
                onClick={() => setDirPage(dirPage - 1)}
                className="px-3 py-1.5 text-[9px] font-black uppercase tracking-wider border border-secondary-200 dark:border-slate-800 rounded-xl hover:bg-secondary-50 dark:hover:bg-slate-950 disabled:opacity-50 text-secondary-600 dark:text-secondary-400 transition-all cursor-pointer"
              >
                Prev
              </button>
              <span className="text-[10px] text-secondary-400 dark:text-secondary-500 font-bold">
                {dirPage} / {directoryPagination.totalPages}
              </span>
              <button
                disabled={dirPage === directoryPagination.totalPages}
                onClick={() => setDirPage(dirPage + 1)}
                className="px-3 py-1.5 text-[9px] font-black uppercase tracking-wider border border-secondary-200 dark:border-slate-800 rounded-xl hover:bg-secondary-50 dark:hover:bg-slate-950 disabled:opacity-50 text-secondary-600 dark:text-secondary-400 transition-all cursor-pointer"
              >
                Next
              </button>
            </div>
          )}
        </div>
      </div>

      {/* Main Chat Area */}
      <div className="flex-1 flex flex-col bg-secondary-50/10 dark:bg-slate-950/10">
        {activeConversationId ? (
          <>
            {/* Chat Header */}
            <div className="h-16 px-6 border-b border-secondary-200/40 dark:border-slate-805/40 flex items-center justify-between bg-white/70 dark:bg-slate-900/60 backdrop-blur-md">
              <div className="flex items-center space-x-3.5">
                <div className="w-10 h-10 rounded-xl bg-primary-500/10 border border-primary-500/20 flex items-center justify-center">
                  <UserIcon className="w-5 h-5 text-primary-500 dark:text-primary-400" />
                </div>
                <div>
                  <h3 className="text-xs font-black text-slate-800 dark:text-slate-100">{activeContact?.firstName} {activeContact?.lastName}</h3>
                  <p className="text-[9px] text-emerald-500 font-bold uppercase tracking-wider flex items-center mt-0.5">
                    <span className="w-1.5 h-1.5 rounded-full bg-emerald-500 mr-1.5 animate-pulse"></span>
                    Online
                  </p>
                </div>
              </div>
              <button className="p-2 rounded-xl text-secondary-400 hover:text-secondary-600 dark:hover:text-secondary-200 hover:bg-secondary-100/50 dark:hover:bg-slate-950/40 border border-transparent transition-all cursor-pointer">
                <MoreVertical className="w-5 h-5" />
              </button>
            </div>

            {/* Messages */}
            <div className="flex-1 overflow-y-auto p-6 space-y-4">
              {activeMessages.map((msg) => (
                <div key={msg.id} className={`flex flex-col ${msg.senderId === user?.id ? 'items-end ml-auto' : 'items-start'} space-y-1.5 max-w-[70%]`}>
                  <div className={`p-4 rounded-2xl text-xs font-semibold leading-relaxed shadow-sm ${msg.senderId === user?.id ? 'bg-gradient-to-br from-primary-600 to-primary-750 text-white rounded-tr-none shadow-primary-500/10' : 'bg-white dark:bg-slate-900 border border-secondary-200/30 dark:border-slate-805/30 text-slate-800 dark:text-slate-200 rounded-tl-none shadow-sm'}`}>
                    {msg.content}
                  </div>
                  <span className="text-[9px] text-secondary-400 dark:text-secondary-500 font-bold tracking-wide uppercase px-1">{new Date(msg.sentAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}</span>
                </div>
              ))}
              <div ref={scrollRef} />
            </div>

            {/* Input */}
            <div className="p-4 bg-white/70 dark:bg-slate-900/60 backdrop-blur-md border-t border-secondary-200/40 dark:border-slate-805/40">
              <div className="flex items-center space-x-3 bg-secondary-100/50 dark:bg-slate-950/40 rounded-2xl px-4 py-2 border border-secondary-200/40 dark:border-slate-850/40 focus-within:ring-2 focus-within:ring-primary-500/10 focus-within:border-primary-500 transition-all">
                <button className="text-secondary-400 hover:text-secondary-600 dark:hover:text-secondary-200 cursor-pointer">
                  <Paperclip className="w-5 h-5" />
                </button>
                <input 
                  type="text" 
                  value={input}
                  onChange={(e) => setInput(e.target.value)}
                  onKeyDown={(e) => e.key === 'Enter' && handleSend()}
                  placeholder="Type your message..." 
                  className="bg-transparent border-none focus:outline-none flex-1 py-2 text-xs font-semibold text-slate-800 dark:text-slate-200 placeholder-secondary-400"
                />
                <Button 
                  onClick={handleSend}
                  className="p-2.5 rounded-xl shrink-0"
                >
                  <Send className="w-4 h-4" />
                </Button>
              </div>
            </div>
          </>
        ) : (
          <div className="flex-1 flex flex-col items-center justify-center text-center p-12">
            <div className="w-20 h-20 rounded-3xl bg-primary-500/10 border border-primary-500/20 flex items-center justify-center mb-5 animate-pulse">
              <MessageSquare className="w-9 h-9 text-primary-500 dark:text-primary-400" />
            </div>
            <h3 className="text-base font-black text-slate-900 dark:text-white uppercase tracking-wider">Start Messaging</h3>
            <p className="text-xs font-semibold text-secondary-400 dark:text-secondary-500 max-w-xs mt-2 leading-relaxed">Select a clinician or team member from the sidebar to establish a secure channels workflow.</p>
          </div>
        )}
      </div>
    </div>
  );
}

