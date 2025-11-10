/**
 * @module media
 * @summary Media gallery domain with photos, videos, and multimedia content management
 * @domain functional
 * @dependencies @tanstack/react-query, axios, date-fns
 * @version 1.0.0
 */

export * from './components/MediaCard';
export * from './components/MediaFilters';
export * from './components/MediaViewer';
export * from './components/VideoPlayer';
export * from './components/ShareButtons';
export * from './hooks/useMediaList';
export * from './hooks/useMediaDetail';
export * from './services/mediaService';
export * from './types';

export const moduleMetadata = {
  name: 'media',
  domain: 'functional',
  version: '1.0.0',
  publicComponents: ['MediaCard', 'MediaFilters', 'MediaViewer', 'VideoPlayer', 'ShareButtons'],
  publicHooks: ['useMediaList', 'useMediaDetail'],
  publicServices: ['mediaService'],
  dependencies: {
    internal: ['@/core/lib/api', '@/core/components'],
    external: ['react', 'react-router-dom', '@tanstack/react-query', 'axios', 'date-fns'],
    domains: [],
  },
  exports: {
    components: ['MediaCard', 'MediaFilters', 'MediaViewer', 'VideoPlayer', 'ShareButtons'],
    hooks: ['useMediaList', 'useMediaDetail'],
    services: ['mediaService'],
    types: ['Media', 'MediaListParams', 'MediaType', 'MediaCategory'],
  },
} as const;
