import { useQuery } from '@tanstack/react-query';
import { useEffect } from 'react';
import { mediaService } from '../../services';
import type { UseMediaDetailOptions, UseMediaDetailReturn } from './types';

/**
 * @hook useMediaDetail
 * @summary Hook for fetching media detail
 * @domain media
 * @type domain-hook
 * @category data
 */
export const useMediaDetail = (options: UseMediaDetailOptions): UseMediaDetailReturn => {
  const { mediaId, enabled = true } = options;

  const mediaQuery = useQuery({
    queryKey: ['media-detail', mediaId],
    queryFn: () => mediaService.getByIdPublic(mediaId),
    enabled: enabled && !!mediaId,
    staleTime: 5 * 60 * 1000,
  });

  useEffect(() => {
    if (mediaQuery.data && enabled) {
      mediaService.registerView(mediaId).catch(() => {});
    }
  }, [mediaQuery.data, mediaId, enabled]);

  return {
    media: mediaQuery.data || null,
    isLoading: mediaQuery.isLoading,
    error: mediaQuery.error as Error | null,
    refetch: mediaQuery.refetch,
  };
};
