import { useQuery } from '@tanstack/react-query';
import { newsService } from '../../services';
import type { UseNewsListOptions, UseNewsListReturn } from './types';

/**
 * @hook useNewsList
 * @summary Hook for fetching and managing news list with filters
 * @domain news
 * @type domain-hook
 * @category data
 */
export const useNewsList = (options: UseNewsListOptions = {}): UseNewsListReturn => {
  const { filters, enabled = true } = options;

  const queryKey = ['news-list', filters];

  const { data, isLoading, error, refetch } = useQuery({
    queryKey,
    queryFn: () => newsService.listPublic(filters),
    enabled,
    staleTime: 2 * 60 * 1000,
  });

  return {
    news: data?.items || [],
    total: data?.total || 0,
    page: data?.page || 1,
    pageSize: data?.pageSize || 20,
    totalPages: data?.totalPages || 0,
    isLoading,
    error: error as Error | null,
    refetch,
  };
};
