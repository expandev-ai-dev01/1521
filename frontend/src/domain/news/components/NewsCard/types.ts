import type { News } from '../../types';

export interface NewsCardProps {
  news: News;
  onClick?: (newsId: string) => void;
}
