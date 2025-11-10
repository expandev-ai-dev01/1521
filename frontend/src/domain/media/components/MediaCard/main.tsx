import { format } from 'date-fns';
import { ptBR } from 'date-fns/locale';
import { getMediaCardClassName } from './variants';
import type { MediaCardProps } from './types';

/**
 * @component MediaCard
 * @summary Card component for displaying media summary
 * @domain media
 * @type domain-component
 * @category display
 */
export const MediaCard = ({ media, onClick }: MediaCardProps) => {
  const handleClick = () => {
    if (onClick) {
      onClick(media.id_midia);
    }
  };

  const formattedDate = format(new Date(media.data_captura), "dd 'de' MMMM 'de' yyyy", {
    locale: ptBR,
  });

  return (
    <article className={getMediaCardClassName()} onClick={handleClick}>
      <div className="relative h-48 overflow-hidden">
        <img
          src={media.url_thumbnail}
          alt={media.descricao_alternativa}
          className="w-full h-full object-cover transition-transform duration-300 hover:scale-105"
        />
        {media.tipo_midia === 'video' && (
          <div className="absolute inset-0 flex items-center justify-center">
            <div className="bg-black bg-opacity-60 rounded-full p-4">
              <svg className="w-8 h-8 text-white" fill="currentColor" viewBox="0 0 20 20">
                <path d="M6.3 2.841A1.5 1.5 0 004 4.11V15.89a1.5 1.5 0 002.3 1.269l9.344-5.89a1.5 1.5 0 000-2.538L6.3 2.84z" />
              </svg>
            </div>
          </div>
        )}
        {media.tipo_midia === 'video' && media.duracao && (
          <span className="absolute bottom-2 right-2 bg-black bg-opacity-75 text-white px-2 py-1 text-xs rounded">
            {media.duracao}
          </span>
        )}
      </div>
      <div className="p-4">
        <div className="flex items-center gap-2 mb-2">
          <span className="text-xs font-semibold text-blue-600 uppercase">{media.categoria}</span>
          {media.subcategoria && (
            <span className="text-xs text-gray-500">{media.subcategoria}</span>
          )}
        </div>
        <h3 className="text-lg font-bold text-gray-900 mb-2 line-clamp-2">{media.titulo}</h3>
        {media.descricao && (
          <p className="text-sm text-gray-600 mb-3 line-clamp-2">{media.descricao}</p>
        )}
        <div className="flex items-center justify-between text-xs text-gray-500">
          <span>{formattedDate}</span>
          <div className="flex items-center gap-3">
            <span>{media.contador_visualizacoes} visualizações</span>
            <span>{media.contador_compartilhamentos} compartilhamentos</span>
          </div>
        </div>
      </div>
    </article>
  );
};
