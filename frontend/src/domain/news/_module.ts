/**
 * @module news
 * @summary News management domain with listing, filtering, and detail views
 * @domain functional
 * @dependencies @tanstack/react-query, axios, date-fns
 * @version 1.0.0
 */

export * from './components/NewsCard';
export * from './components/NewsFilters';
export * from './hooks/useNewsList';
export * from './hooks/useNewsDetail';
export * from './services/newsService';
export * from './types';

export const moduleMetadata = {
  name: 'news',
  domain: 'functional',
  version: '1.0.0',
  publicComponents: ['NewsCard', 'NewsFilters'],
  publicHooks: ['useNewsList', 'useNewsDetail'],
  publicServices: ['newsService'],
  dependencies: {
    internal: ['@/core/lib/api', '@/core/components'],
    external: ['react', 'react-router-dom', '@tanstack/react-query', 'axios', 'date-fns'],
    domains: [],
  },
  exports: {
    components: ['NewsCard', 'NewsFilters'],
    hooks: ['useNewsList', 'useNewsDetail'],
    services: ['newsService'],
    types: ['News', 'NewsListParams', 'CreateNewsDto', 'UpdateNewsDto', 'Category', 'Entity'],
  },
} as const;
