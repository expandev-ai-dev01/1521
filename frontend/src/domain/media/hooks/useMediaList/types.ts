import type { MediaListParams, Media } from '../../types';

export interface UseMediaListOptions {
  filters?: MediaListParams;
  enabled?: boolean;
}

export interface UseMediaListReturn {
  media: Media[];
  total: number;
  page: number;
  pageSize: number;
  totalPages: number;
  isLoading: boolean;
  error: Error | null;
  refetch: () => void;
}
