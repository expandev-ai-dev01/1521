import { useState } from 'react';
import { useMediaList } from '@/domain/media/hooks/useMediaList';
import { MediaCard } from '@/domain/media/components/MediaCard';
import { MediaFilters } from '@/domain/media/components/MediaFilters';
import { MediaViewer } from '@/domain/media/components/MediaViewer';
import { LoadingSpinner } from '@/core/components/LoadingSpinner';
import type { MediaListParams, Media } from '@/domain/media/types';
import type { MediaGalleryPageProps } from './types';

/**
 * @page MediaGalleryPage
 * @summary Media gallery page with photos and videos
 * @domain media
 * @type list-page
 * @category media-management
 */
export const MediaGalleryPage = (props: MediaGalleryPageProps) => {
  const [filters, setFilters] = useState<MediaListParams>({
    ordenacao: 'mais_recentes',
    visualizacao: 'grade',
    filtro_tipo_midia: ['foto', 'video'],
    itens_por_pagina: 20,
    pagina_atual: 1,
  });

  const [selectedMedia, setSelectedMedia] = useState<Media | null>(null);
  const [selectedIndex, setSelectedIndex] = useState<number>(-1);

  const { media, total, page, totalPages, isLoading, error } = useMediaList({ filters });

  const handleMediaClick = (mediaId: string) => {
    const index = media.findIndex((m) => m.id_midia === mediaId);
    if (index !== -1) {
      setSelectedMedia(media[index]);
      setSelectedIndex(index);
    }
  };

  const handleCloseViewer = () => {
    setSelectedMedia(null);
    setSelectedIndex(-1);
  };

  const handleNext = () => {
    if (selectedIndex < media.length - 1) {
      const nextIndex = selectedIndex + 1;
      setSelectedMedia(media[nextIndex]);
      setSelectedIndex(nextIndex);
    }
  };

  const handlePrevious = () => {
    if (selectedIndex > 0) {
      const prevIndex = selectedIndex - 1;
      setSelectedMedia(media[prevIndex]);
      setSelectedIndex(prevIndex);
    }
  };

  const handlePageChange = (newPage: number) => {
    setFilters({ ...filters, pagina_atual: newPage });
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  if (error) {
    return (
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="bg-red-50 border border-red-200 rounded-lg p-6 text-center">
          <h2 className="text-xl font-semibold text-red-900 mb-2">Erro ao carregar galeria</h2>
          <p className="text-red-700">{error.message}</p>
        </div>
      </div>
    );
  }

  const getGridClassName = () => {
    switch (filters.visualizacao) {
      case 'lista':
        return 'grid grid-cols-1 gap-6';
      case 'mosaico':
        return 'grid grid-cols-2 md:grid-cols-4 gap-4';
      default:
        return 'grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6';
    }
  };

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
      <h1 className="text-4xl font-bold text-gray-900 mb-8">Galeria Multimídia</h1>

      <MediaFilters filters={filters} onFiltersChange={setFilters} />

      {isLoading ? (
        <LoadingSpinner size="lg" />
      ) : (
        <>
          {media.length === 0 ? (
            <div className="text-center py-12">
              <p className="text-xl text-gray-600">Nenhum conteúdo encontrado</p>
            </div>
          ) : (
            <>
              <div className={getGridClassName() + ' mb-8'}>
                {media.map((item) => (
                  <MediaCard key={item.id_midia} media={item} onClick={handleMediaClick} />
                ))}
              </div>

              {totalPages > 1 && (
                <div className="flex justify-center items-center gap-2">
                  <button
                    onClick={() => handlePageChange(page - 1)}
                    disabled={page === 1}
                    className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 disabled:bg-gray-300 disabled:cursor-not-allowed"
                  >
                    Anterior
                  </button>
                  <span className="text-gray-700">
                    Página {page} de {totalPages}
                  </span>
                  <button
                    onClick={() => handlePageChange(page + 1)}
                    disabled={page === totalPages}
                    className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 disabled:bg-gray-300 disabled:cursor-not-allowed"
                  >
                    Próxima
                  </button>
                </div>
              )}

              <div className="text-center mt-4 text-sm text-gray-600">
                Mostrando {media.length} de {total} itens
              </div>
            </>
          )}
        </>
      )}

      {selectedMedia && (
        <MediaViewer
          media={selectedMedia}
          onClose={handleCloseViewer}
          onNext={selectedIndex < media.length - 1 ? handleNext : undefined}
          onPrevious={selectedIndex > 0 ? handlePrevious : undefined}
        />
      )}
    </div>
  );
};

export default MediaGalleryPage;
