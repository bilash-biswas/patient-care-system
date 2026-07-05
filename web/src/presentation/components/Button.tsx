import React from 'react';
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'outline' | 'ghost';
  size?: 'sm' | 'md' | 'lg';
  isLoading?: boolean;
}

export const Button = ({
  className,
  variant = 'primary',
  size = 'md',
  isLoading,
  children,
  ...props
}: ButtonProps) => {
  const variants = {
    primary: 'bg-gradient-to-r from-primary-600 to-primary-700 hover:from-primary-500 hover:to-primary-600 text-white shadow-md shadow-primary-600/15 hover:shadow-lg hover:shadow-primary-600/25 border border-primary-600/10',
    secondary: 'bg-secondary-100 hover:bg-secondary-200 text-secondary-900 dark:bg-secondary-800 dark:hover:bg-secondary-700 dark:text-secondary-100 shadow-sm border border-secondary-200/10',
    outline: 'border border-secondary-200 hover:bg-secondary-50 text-secondary-700 dark:border-secondary-800 dark:hover:bg-secondary-900 dark:text-secondary-300 shadow-sm',
    ghost: 'hover:bg-secondary-100 text-secondary-700 dark:hover:bg-secondary-800 dark:text-secondary-300',
  };

  const sizes = {
    sm: 'px-4 py-2 text-xs font-bold tracking-wide uppercase',
    md: 'px-5 py-2.5 text-sm font-bold',
    lg: 'px-7 py-3.5 text-base font-extrabold tracking-tight',
  };

  return (
    <button
      className={cn(
        'inline-flex items-center justify-center rounded-xl transition-all duration-300 cursor-pointer disabled:opacity-50 disabled:pointer-events-none active:scale-[0.97] hover:-translate-y-[1px]',
        variants[variant],
        sizes[size],
        className
      )}
      disabled={isLoading}
      {...props}
    >
      {isLoading ? (
        <svg className="animate-spin h-5 w-5 mr-3" viewBox="0 0 24 24">
          <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" fill="none" />
          <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" />
        </svg>
      ) : null}
      {children}
    </button>
  );
};
