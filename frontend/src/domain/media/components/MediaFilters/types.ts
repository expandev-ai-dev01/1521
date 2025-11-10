import type { MediaListParams } from '../../types';

export interface MediaFiltersProps {
  filters: MediaListParams;
  onFiltersChange: (filters: MediaListParams) => void;
}
