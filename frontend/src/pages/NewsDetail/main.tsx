import { useParams, useNavigate } from 'react-router-dom';
import { format } from 'date-fns';
import { ptBR } from 'date-fns/locale';
import DOMPurify from 'dompurify';
import { useNewsDetail } from '@/domain/news/hooks/useNewsDetail';
import { NewsCard } from '@/domain/news/components/NewsCard';
import { LoadingSpinner } from '@/core/components/LoadingSpinner';
import type { NewsDetailPageProps } from './types';

/**
 * @page NewsDetailPage
 * @summary News detail page with full content and related news
 * @domain news
 * @type detail-page
 * @category news-management
 */
export const NewsDetailPage = (props: NewsDetailPageProps) => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();

  const { news, relatedNews, isLoading, error } = useNewsDetail({
    newsId: id!,
    enabled: !!id,
  });

  const handleRelatedClick = (newsId: string) => {
    navigate(`/noticias/${newsId}`);
  };

  if (isLoading) {
    return (
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <LoadingSpinner size="lg" />
      </div>
    );
  }

  if (error || !news) {
    return (
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="bg-red-50 border border-red-200 rounded-lg p-6 text-center">
          <h2 className="text-xl font-semibold text-red-900 mb-2">Notícia não encontrada</h2>
          <p className="text-red-700 mb-4">
            {error?.message || 'A notícia solicitada não está disponível'}
          </p>
          <button
            onClick={() => navigate('/noticias')}
            className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700"
          >
            Voltar para notícias
          </button>
        </div>
      </div>
    );
  }

  const formattedDate = format(
    new Date(news.data_publicacao),
    "dd 'de' MMMM 'de' yyyy 'às' HH:mm",
    {
      locale: ptBR,
    }
  );

  const sanitizedContent = DOMPurify.sanitize(news.conteudo);

  const shareUrls = {
    whatsapp: `https://wa.me/?text=${encodeURIComponent(
      news.titulo + ' - ' + window.location.href
    )}`,
    facebook: `https://www.facebook.com/sharer/sharer.php?u=${encodeURIComponent(
      window.location.href
    )}`,
    twitter: `https://twitter.com/intent/tweet?text=${encodeURIComponent(
      news.titulo
    )}&url=${encodeURIComponent(window.location.href)}`,
    telegram: `https://t.me/share/url?url=${encodeURIComponent(
      window.location.href
    )}&text=${encodeURIComponent(news.titulo)}`,
  };

  return (
    <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
      <article>
        <header className="mb-8">
          <div className="flex items-center gap-2 mb-4">
            {news.categorias.map((categoria) => (
              <span key={categoria} className="text-sm font-semibold text-blue-600 uppercase">
                {categoria}
              </span>
            ))}
          </div>
          <h1 className="text-4xl font-bold text-gray-900 mb-4">{news.titulo}</h1>
          {news.subtitulo && <p className="text-xl text-gray-600 mb-4">{news.subtitulo}</p>}
          <div className="flex items-center justify-between text-sm text-gray-500 border-b border-gray-200 pb-4">
            <div>
              <span className="font-medium">Por {news.autor.nome}</span>
              <span className="mx-2">•</span>
              <span>{formattedDate}</span>
            </div>
            <div className="flex items-center gap-4">
              <span>{news.tempo_leitura} min de leitura</span>
              <span>{news.contador_visualizacoes} visualizações</span>
            </div>
          </div>
        </header>

        <div className="mb-8">
          <img
            src={news.imagem_destaque}
            alt={news.titulo}
            className="w-full h-auto rounded-lg shadow-lg"
          />
        </div>

        {news.conteudo_sensivel && (
          <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-4 mb-8">
            <p className="text-yellow-900 font-medium">⚠️ Esta notícia contém conteúdo sensível</p>
          </div>
        )}

        <div
          className="prose prose-lg max-w-none mb-8"
          dangerouslySetInnerHTML={{ __html: sanitizedContent }}
        />

        {news.fonte_externa && (
          <div className="bg-gray-50 border border-gray-200 rounded-lg p-4 mb-8">
            <p className="text-sm text-gray-700">
              Fonte:{' '}
              <a
                href={news.fonte_externa.url}
                target="_blank"
                rel="noopener noreferrer"
                className="text-blue-600 hover:underline"
              >
                {news.fonte_externa.nome}
              </a>
            </p>
          </div>
        )}

        {news.tags && news.tags.length > 0 && (
          <div className="mb-8">
            <h3 className="text-sm font-semibold text-gray-700 mb-2">Tags:</h3>
            <div className="flex flex-wrap gap-2">
              {news.tags.map((tag) => (
                <span
                  key={tag}
                  className="px-3 py-1 bg-gray-100 text-gray-700 text-sm rounded-full"
                >
                  {tag}
                </span>
              ))}
            </div>
          </div>
        )}

        <div className="border-t border-gray-200 pt-6 mb-8">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Compartilhar</h3>
          <div className="flex gap-4">
            <a
              href={shareUrls.whatsapp}
              target="_blank"
              rel="noopener noreferrer"
              className="px-4 py-2 bg-green-600 text-white rounded-md hover:bg-green-700"
            >
              WhatsApp
            </a>
            <a
              href={shareUrls.facebook}
              target="_blank"
              rel="noopener noreferrer"
              className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700"
            >
              Facebook
            </a>
            <a
              href={shareUrls.twitter}
              target="_blank"
              rel="noopener noreferrer"
              className="px-4 py-2 bg-sky-500 text-white rounded-md hover:bg-sky-600"
            >
              Twitter
            </a>
            <a
              href={shareUrls.telegram}
              target="_blank"
              rel="noopener noreferrer"
              className="px-4 py-2 bg-blue-500 text-white rounded-md hover:bg-blue-600"
            >
              Telegram
            </a>
          </div>
        </div>
      </article>

      {relatedNews.length > 0 && (
        <section className="border-t border-gray-200 pt-8">
          <h2 className="text-2xl font-bold text-gray-900 mb-6">Notícias relacionadas</h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {relatedNews.map((item) => (
              <NewsCard key={item.id_noticia} news={item} onClick={handleRelatedClick} />
            ))}
          </div>
        </section>
      )}
    </div>
  );
};

export default NewsDetailPage;
