import { useQuery } from '@tanstack/react-query';
import { useEffect } from 'react';
import { newsService } from '../../services';
import type { UseNewsDetailOptions, UseNewsDetailReturn } from './types';

/**
 * @hook useNewsDetail
 * @summary Hook for fetching news detail and related news
 * @domain news
 * @type domain-hook
 * @category data
 */
export const useNewsDetail = (options: UseNewsDetailOptions): UseNewsDetailReturn => {
  const { newsId, enabled = true } = options;

  const newsQuery = useQuery({
    queryKey: ['news-detail', newsId],
    queryFn: () => newsService.getByIdPublic(newsId),
    enabled: enabled && !!newsId,
    staleTime: 5 * 60 * 1000,
  });

  const relatedQuery = useQuery({
    queryKey: ['news-related', newsId],
    queryFn: () => newsService.getRelated(newsId),
    enabled: enabled && !!newsId && !!newsQuery.data,
    staleTime: 5 * 60 * 1000,
  });

  useEffect(() => {
    if (newsQuery.data && enabled) {
      newsService.registerView(newsId).catch(() => {});
    }
  }, [newsQuery.data, newsId, enabled]);

  return {
    news: newsQuery.data || null,
    relatedNews: relatedQuery.data || [],
    isLoading: newsQuery.isLoading || relatedQuery.isLoading,
    error: (newsQuery.error || relatedQuery.error) as Error | null,
    refetch: () => {
      newsQuery.refetch();
      relatedQuery.refetch();
    },
  };
};
