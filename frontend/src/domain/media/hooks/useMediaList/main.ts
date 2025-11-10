import { useQuery } from '@tanstack/react-query';
import { mediaService } from '../../services';
import type { UseMediaListOptions, UseMediaListReturn } from './types';

/**
 * @hook useMediaList
 * @summary Hook for fetching and managing media list with filters
 * @domain media
 * @type domain-hook
 * @category data
 */
export const useMediaList = (options: UseMediaListOptions = {}): UseMediaListReturn => {
  const { filters, enabled = true } = options;

  const queryKey = ['media-list', filters];

  const { data, isLoading, error, refetch } = useQuery({
    queryKey,
    queryFn: () => mediaService.listPublic(filters),
    enabled,
    staleTime: 2 * 60 * 1000,
  });

  return {
    media: data?.items || [],
    total: data?.total || 0,
    page: data?.page || 1,
    pageSize: data?.pageSize || 20,
    totalPages: data?.totalPages || 0,
    isLoading,
    error: error as Error | null,
    refetch,
  };
};
