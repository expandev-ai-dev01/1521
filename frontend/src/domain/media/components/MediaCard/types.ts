import type { Media } from '../../types';

export interface MediaCardProps {
  media: Media;
  onClick?: (mediaId: string) => void;
}
