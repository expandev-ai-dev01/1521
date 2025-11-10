import type { NewsListParams, News } from '../../types';

export interface UseNewsListOptions {
  filters?: NewsListParams;
  enabled?: boolean;
}

export interface UseNewsListReturn {
  news: News[];
  total: number;
  page: number;
  pageSize: number;
  totalPages: number;
  isLoading: boolean;
  error: Error | null;
  refetch: () => void;
}
