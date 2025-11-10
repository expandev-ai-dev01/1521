import type { MediaFiltersProps } from './types';

/**
 * @component MediaFilters
 * @summary Filter component for media gallery
 * @domain media
 * @type domain-component
 * @category form
 */
export const MediaFilters = ({ filters, onFiltersChange }: MediaFiltersProps) => {
  const handleCategoryChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
    onFiltersChange({
      ...filters,
      filtro_categoria: e.target.value || undefined,
      filtro_subcategoria: undefined,
    });
  };

  const handleOrderChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
    onFiltersChange({
      ...filters,
      ordenacao: e.target.value as any,
    });
  };

  const handleMediaTypeChange = (type: 'foto' | 'video') => {
    const currentTypes = filters.filtro_tipo_midia || ['foto', 'video'];
    const newTypes = currentTypes.includes(type)
      ? currentTypes.filter((t) => t !== type)
      : [...currentTypes, type];

    onFiltersChange({
      ...filters,
      filtro_tipo_midia: newTypes.length > 0 ? newTypes : undefined,
    });
  };

  const handleViewModeChange = (mode: 'grade' | 'lista' | 'mosaico') => {
    onFiltersChange({
      ...filters,
      visualizacao: mode,
    });
  };

  return (
    <div className="bg-white p-4 rounded-lg shadow-md mb-6">
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div>
          <label htmlFor="category" className="block text-sm font-medium text-gray-700 mb-2">
            Categoria
          </label>
          <select
            id="category"
            value={filters.filtro_categoria || ''}
            onChange={handleCategoryChange}
            className="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          >
            <option value="">Todas</option>
            <option value="times">Times</option>
            <option value="campeonatos">Campeonatos</option>
            <option value="jogadores">Jogadores</option>
            <option value="eventos">Eventos</option>
          </select>
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
            <option value="mais_antigos">Mais antigos</option>
            <option value="mais_visualizados">Mais visualizados</option>
            <option value="mais_compartilhados">Mais compartilhados</option>
          </select>
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">Tipo de mídia</label>
          <div className="flex gap-4">
            <label className="flex items-center">
              <input
                type="checkbox"
                checked={(filters.filtro_tipo_midia || ['foto', 'video']).includes('foto')}
                onChange={() => handleMediaTypeChange('foto')}
                className="mr-2"
              />
              <span className="text-sm">Fotos</span>
            </label>
            <label className="flex items-center">
              <input
                type="checkbox"
                checked={(filters.filtro_tipo_midia || ['foto', 'video']).includes('video')}
                onChange={() => handleMediaTypeChange('video')}
                className="mr-2"
              />
              <span className="text-sm">Vídeos</span>
            </label>
          </div>
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">Visualização</label>
          <div className="flex gap-2">
            <button
              onClick={() => handleViewModeChange('grade')}
              className={`px-3 py-2 rounded-md ${
                filters.visualizacao === 'grade' || !filters.visualizacao
                  ? 'bg-blue-600 text-white'
                  : 'bg-gray-200 text-gray-700'
              }`}
            >
              Grade
            </button>
            <button
              onClick={() => handleViewModeChange('lista')}
              className={`px-3 py-2 rounded-md ${
                filters.visualizacao === 'lista'
                  ? 'bg-blue-600 text-white'
                  : 'bg-gray-200 text-gray-700'
              }`}
            >
              Lista
            </button>
            <button
              onClick={() => handleViewModeChange('mosaico')}
              className={`px-3 py-2 rounded-md ${
                filters.visualizacao === 'mosaico'
                  ? 'bg-blue-600 text-white'
                  : 'bg-gray-200 text-gray-700'
              }`}
            >
              Mosaico
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};
