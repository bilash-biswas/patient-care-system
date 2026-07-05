import React from 'react';
import { cn } from './Button';

interface CardProps {
  children: React.ReactNode;
  className?: string;
  title?: string;
  description?: string;
}

export const Card = ({ children, className, title, description }: CardProps) => {
  return (
    <div className={cn('glass-card rounded-2xl p-6', className)}>
      {title && (
        <div className="mb-4">
          <h3 className="text-lg font-bold tracking-tight text-gray-900 dark:text-white">{title}</h3>
          {description && <p className="text-xs text-gray-500 dark:text-gray-400 mt-1 font-medium">{description}</p>}
        </div>
      )}
      {children}
    </div>
  );
};
