import { authenticatedClient, publicClient } from '@/core/lib/api';
import type { Media, MediaListParams, MediaListResponse } from '../types';

/**
 * @service mediaService
 * @summary Media gallery service for photos and videos
 * @domain media
 * @type rest-service
 * @apiContext internal/external
 */
export const mediaService = {
  /**
   * @endpoint GET /api/v1/external/media
   * @summary Fetches list of published media with filters (public)
   */
  async listPublic(params?: MediaListParams): Promise<MediaListResponse> {
    const response = await publicClient.get('/media', { params });
    return response.data;
  },

  /**
   * @endpoint GET /api/v1/internal/media
   * @summary Fetches list of all media with filters (authenticated)
   */
  async list(params?: MediaListParams): Promise<MediaListResponse> {
    const response = await authenticatedClient.get('/media', { params });
    return response.data;
  },

  /**
   * @endpoint GET /api/v1/external/media/:id
   * @summary Fetches single published media by ID (public)
   */
  async getByIdPublic(id: string): Promise<Media> {
    const response = await publicClient.get(`/media/${id}`);
    return response.data;
  },

  /**
   * @endpoint GET /api/v1/internal/media/:id
   * @summary Fetches single media by ID (authenticated)
   */
  async getById(id: string): Promise<Media> {
    const response = await authenticatedClient.get(`/media/${id}`);
    return response.data;
  },

  /**
   * @endpoint POST /api/v1/external/media/:id/view
   * @summary Registers media view
   */
  async registerView(id: string): Promise<void> {
    await publicClient.post(`/media/${id}/view`);
  },

  /**
   * @endpoint POST /api/v1/external/media/:id/share
   * @summary Registers media share
   */
  async registerShare(id: string, platform: string): Promise<void> {
    await publicClient.post(`/media/${id}/share`, { platform });
  },

  /**
   * @endpoint GET /api/v1/external/media/galleries
   * @summary Fetches list of thematic galleries
   */
  async getGalleries(): Promise<any[]> {
    const response = await publicClient.get('/media/galleries');
    return response.data;
  },

  /**
   * @endpoint GET /api/v1/external/media/galleries/:id
   * @summary Fetches media from specific gallery
   */
  async getGalleryMedia(id: string): Promise<Media[]> {
    const response = await publicClient.get(`/media/galleries/${id}`);
    return response.data;
  },
};
