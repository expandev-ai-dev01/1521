import type { Media } from '../../types';

export interface MediaViewerProps {
  media: Media;
  onClose: () => void;
  onNext?: () => void;
  onPrevious?: () => void;
}
