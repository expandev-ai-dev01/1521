import type { NewsFiltersProps } from './types';

/**
 * @component NewsFilters
 * @summary Filter component for news list
 * @domain news
 * @type domain-component
 * @category form
 */
export const NewsFilters = ({ filters, onFiltersChange }: NewsFiltersProps) => {
  const handleSearchChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    onFiltersChange({
      ...filters,
      termo_busca: e.target.value || undefined,
    });
  };

  const handleOrderChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
    onFiltersChange({
      ...filters,
      ordenacao: e.target.value as any,
    });
  };

  return (
    <div className="bg-white p-4 rounded-lg shadow-md mb-6">
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label htmlFor="search" className="block text-sm font-medium text-gray-700 mb-2">
            Buscar notícias
          </label>
          <input
            id="search"
            type="text"
            value={filters.termo_busca || ''}
            onChange={handleSearchChange}
            placeholder="Digite para buscar..."
            className="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          />
        </div>
        <div>
          <label htmlFor="order" className="block text-sm font-medium text-gray-700 mb-2">
            Ordenar por
          </label>
          <select
            id="order"
            value={filters.ordenacao || 'mais_recentes'}
            onChange={handleOrderChange}
            className="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          >
            <option value="mais_recentes">Mais recentes</option>
            <option value="mais_antigas">Mais antigas</option>
            <option value="mais_lidas">Mais lidas</option>
            <option value="relevancia">Relevância</option>
          </select>
        </div>
      </div>
    </div>
  );
};
