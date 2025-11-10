import { authenticatedClient, publicClient } from '@/core/lib/api';
import type {
  News,
  NewsListParams,
  NewsListResponse,
  CreateNewsDto,
  UpdateNewsDto,
} from '../types';

/**
 * @service newsService
 * @summary News management service for authenticated and public endpoints
 * @domain news
 * @type rest-service
 * @apiContext internal/external
 */
export const newsService = {
  /**
   * @endpoint GET /api/v1/external/news
   * @summary Fetches list of published news with filters (public)
   */
  async listPublic(params?: NewsListParams): Promise<NewsListResponse> {
    const response = await publicClient.get('/news', { params });
    return response.data;
  },

  /**
   * @endpoint GET /api/v1/internal/news
   * @summary Fetches list of all news with filters (authenticated)
   */
  async list(params?: NewsListParams): Promise<NewsListResponse> {
    const response = await authenticatedClient.get('/news', { params });
    return response.data;
  },

  /**
   * @endpoint GET /api/v1/external/news/:id
   * @summary Fetches single published news by ID (public)
   */
  async getByIdPublic(id: string): Promise<News> {
    const response = await publicClient.get(`/news/${id}`);
    return response.data;
  },

  /**
   * @endpoint GET /api/v1/internal/news/:id
   * @summary Fetches single news by ID (authenticated)
   */
  async getById(id: string): Promise<News> {
    const response = await authenticatedClient.get(`/news/${id}`);
    return response.data;
  },

  /**
   * @endpoint POST /api/v1/internal/news
   * @summary Creates new news
   */
  async create(data: CreateNewsDto): Promise<News> {
    const response = await authenticatedClient.post('/news', data);
    return response.data;
  },

  /**
   * @endpoint PUT /api/v1/internal/news/:id
   * @summary Updates existing news
   */
  async update(id: string, data: UpdateNewsDto): Promise<News> {
    const response = await authenticatedClient.put(`/news/${id}`, data);
    return response.data;
  },

  /**
   * @endpoint DELETE /api/v1/internal/news/:id
   * @summary Deletes news
   */
  async delete(id: string): Promise<void> {
    await authenticatedClient.delete(`/news/${id}`);
  },

  /**
   * @endpoint GET /api/v1/external/news/:id/related
   * @summary Fetches related news
   */
  async getRelated(id: string): Promise<News[]> {
    const response = await publicClient.get(`/news/${id}/related`);
    return response.data;
  },

  /**
   * @endpoint POST /api/v1/external/news/:id/view
   * @summary Registers news view
   */
  async registerView(id: string): Promise<void> {
    await publicClient.post(`/news/${id}/view`);
  },
};
