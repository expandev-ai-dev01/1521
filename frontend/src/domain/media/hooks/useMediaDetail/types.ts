import type { Media } from '../../types';

export interface UseMediaDetailOptions {
  mediaId: string;
  enabled?: boolean;
}

export interface UseMediaDetailReturn {
  media: Media | null;
  isLoading: boolean;
  error: Error | null;
  refetch: () => void;
}
