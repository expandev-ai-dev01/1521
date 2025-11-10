import { clsx } from 'clsx';

export function getMediaCardClassName(): string {
  return clsx(
    'bg-white rounded-lg shadow-md overflow-hidden',
    'transition-shadow duration-300 hover:shadow-xl',
    'cursor-pointer'
  );
}
