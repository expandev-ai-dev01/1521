import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useNewsList } from '@/domain/news/hooks/useNewsList';
import { NewsCard } from '@/domain/news/components/NewsCard';
import { NewsFilters } from '@/domain/news/components/NewsFilters';
import { LoadingSpinner } from '@/core/components/LoadingSpinner';
import type { NewsListParams } from '@/domain/news/types';
import type { NewsListPageProps } from './types';

/**
 * @page NewsListPage
 * @summary News listing page with filters and pagination
 * @domain news
 * @type list-page
 * @category news-management
 */
export const NewsListPage = (props: NewsListPageProps) => {
  const navigate = useNavigate();
  const [filters, setFilters] = useState<NewsListParams>({
    ordenacao: 'mais_recentes',
    itens_por_pagina: 20,
    pagina_atual: 1,
  });

  const { news, total, page, totalPages, isLoading, error } = useNewsList({ filters });

  const handleNewsClick = (newsId: string) => {
    navigate(`/noticias/${newsId}`);
  };

  const handlePageChange = (newPage: number) => {
    setFilters({ ...filters, pagina_atual: newPage });
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  if (error) {
    return (
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="bg-red-50 border border-red-200 rounded-lg p-6 text-center">
          <h2 className="text-xl font-semibold text-red-900 mb-2">Erro ao carregar notícias</h2>
          <p className="text-red-700">{error.message}</p>
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
      <h1 className="text-4xl font-bold text-gray-900 mb-8">Notícias</h1>

      <NewsFilters filters={filters} onFiltersChange={setFilters} />

      {isLoading ? (
        <LoadingSpinner size="lg" />
      ) : (
        <>
          {news.length === 0 ? (
            <div className="text-center py-12">
              <p className="text-xl text-gray-600">Nenhuma notícia encontrada</p>
            </div>
          ) : (
            <>
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mb-8">
                {news.map((item) => (
                  <NewsCard key={item.id_noticia} news={item} onClick={handleNewsClick} />
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
                Mostrando {news.length} de {total} notícias
              </div>
            </>
          )}
        </>
      )}
    </div>
  );
};

export default NewsListPage;
