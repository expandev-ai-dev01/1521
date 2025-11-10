import type { NewsListParams } from '../../types';

export interface NewsFiltersProps {
  filters: NewsListParams;
  onFiltersChange: (filters: NewsListParams) => void;
}
