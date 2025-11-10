import type { News } from '../../types';

export interface UseNewsDetailOptions {
  newsId: string;
  enabled?: boolean;
}

export interface UseNewsDetailReturn {
  news: News | null;
  relatedNews: News[];
  isLoading: boolean;
  error: Error | null;
  refetch: () => void;
}
