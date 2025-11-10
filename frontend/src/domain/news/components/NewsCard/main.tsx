import { format } from 'date-fns';
import { ptBR } from 'date-fns/locale';
import { getNewsCardClassName } from './variants';
import type { NewsCardProps } from './types';

/**
 * @component NewsCard
 * @summary Card component for displaying news summary
 * @domain news
 * @type domain-component
 * @category display
 */
export const NewsCard = ({ news, onClick }: NewsCardProps) => {
  const handleClick = () => {
    if (onClick) {
      onClick(news.id_noticia);
    }
  };

  const formattedDate = format(new Date(news.data_publicacao), "dd 'de' MMMM 'de' yyyy", {
    locale: ptBR,
  });

  return (
    <article className={getNewsCardClassName()} onClick={handleClick}>
      <div className="relative h-48 overflow-hidden">
        <img
          src={news.imagem_destaque}
          alt={news.titulo}
          className="w-full h-full object-cover transition-transform duration-300 hover:scale-105"
        />
        {news.destaque && (
          <span className="absolute top-2 right-2 bg-red-600 text-white px-2 py-1 text-xs font-bold rounded">
            DESTAQUE
          </span>
        )}
      </div>
      <div className="p-4">
        <div className="flex items-center gap-2 mb-2">
          {news.categorias.slice(0, 2).map((categoria) => (
            <span key={categoria} className="text-xs font-semibold text-blue-600 uppercase">
              {categoria}
            </span>
          ))}
        </div>
        <h3 className="text-lg font-bold text-gray-900 mb-2 line-clamp-2">{news.titulo}</h3>
        {news.subtitulo && (
          <p className="text-sm text-gray-600 mb-3 line-clamp-2">{news.subtitulo}</p>
        )}
        <div className="flex items-center justify-between text-xs text-gray-500">
          <span>{formattedDate}</span>
          <div className="flex items-center gap-3">
            <span>{news.tempo_leitura} min</span>
            <span>{news.contador_visualizacoes} visualizações</span>
          </div>
        </div>
      </div>
    </article>
  );
};
