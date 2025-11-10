import { useState, useEffect } from 'react';
import { format } from 'date-fns';
import { ptBR } from 'date-fns/locale';
import { ShareButtons } from '../ShareButtons';
import type { MediaViewerProps } from './types';

/**
 * @component MediaViewer
 * @summary Full-screen media viewer with zoom and navigation
 * @domain media
 * @type domain-component
 * @category display
 */
export const MediaViewer = ({ media, onClose, onNext, onPrevious }: MediaViewerProps) => {
  const [zoom, setZoom] = useState(100);

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape') {
        onClose();
      } else if (e.key === 'ArrowRight' && onNext) {
        onNext();
      } else if (e.key === 'ArrowLeft' && onPrevious) {
        onPrevious();
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [onClose, onNext, onPrevious]);

  const handleZoomIn = () => {
    setZoom((prev) => Math.min(prev + 25, 400));
  };

  const handleZoomOut = () => {
    setZoom((prev) => Math.max(prev - 25, 100));
  };

  const formattedDate = format(new Date(media.data_captura), "dd 'de' MMMM 'de' yyyy", {
    locale: ptBR,
  });

  return (
    <div className="fixed inset-0 z-50 bg-black bg-opacity-95 flex flex-col">
      <div className="flex items-center justify-between p-4 bg-black bg-opacity-75">
        <div className="flex items-center gap-4">
          <button onClick={onClose} className="text-white hover:text-gray-300" aria-label="Fechar">
            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M6 18L18 6M6 6l12 12"
              />
            </svg>
          </button>
          <h2 className="text-white text-lg font-semibold">{media.titulo}</h2>
        </div>
        <div className="flex items-center gap-4">
          {media.tipo_midia === 'foto' && (
            <>
              <button
                onClick={handleZoomOut}
                disabled={zoom === 100}
                className="text-white hover:text-gray-300 disabled:opacity-50"
                aria-label="Diminuir zoom"
              >
                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0zM13 10H7"
                  />
                </svg>
              </button>
              <span className="text-white text-sm">{zoom}%</span>
              <button
                onClick={handleZoomIn}
                disabled={zoom === 400}
                className="text-white hover:text-gray-300 disabled:opacity-50"
                aria-label="Aumentar zoom"
              >
                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0zM10 7v6m3-3H7"
                  />
                </svg>
              </button>
            </>
          )}
        </div>
      </div>

      <div className="flex-1 flex items-center justify-center overflow-auto p-4">
        {onPrevious && (
          <button
            onClick={onPrevious}
            className="absolute left-4 text-white hover:text-gray-300 bg-black bg-opacity-50 rounded-full p-2"
            aria-label="Anterior"
          >
            <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M15 19l-7-7 7-7"
              />
            </svg>
          </button>
        )}

        {media.tipo_midia === 'foto' ? (
          <img
            src={media.url_arquivo}
            alt={media.descricao_alternativa}
            style={{ transform: `scale(${zoom / 100})` }}
            className="max-w-full max-h-full object-contain transition-transform"
          />
        ) : (
          <video
            src={media.url_arquivo}
            controls
            className="max-w-full max-h-full"
            poster={media.url_thumbnail}
          >
            Seu navegador não suporta a reprodução de vídeos.
          </video>
        )}

        {onNext && (
          <button
            onClick={onNext}
            className="absolute right-4 text-white hover:text-gray-300 bg-black bg-opacity-50 rounded-full p-2"
            aria-label="Próximo"
          >
            <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
            </svg>
          </button>
        )}
      </div>

      <div className="bg-black bg-opacity-75 p-4">
        <div className="max-w-4xl mx-auto">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
            <div>
              {media.descricao && <p className="text-white text-sm mb-2">{media.descricao}</p>}
              <div className="text-gray-400 text-xs space-y-1">
                <p>Data: {formattedDate}</p>
                {media.local && <p>Local: {media.local}</p>}
                <p>Créditos: {media.creditos}</p>
                {media.tipo_midia === 'foto' && <p>Resolução: {media.resolucao}</p>}
                {media.tipo_midia === 'video' && media.duracao && <p>Duração: {media.duracao}</p>}
              </div>
            </div>
            <div>
              <div className="flex items-center justify-between mb-2">
                <span className="text-gray-400 text-xs">
                  {media.contador_visualizacoes} visualizações • {media.contador_compartilhamentos}{' '}
                  compartilhamentos
                </span>
              </div>
              {media.tags && media.tags.length > 0 && (
                <div className="flex flex-wrap gap-2 mb-4">
                  {media.tags.map((tag) => (
                    <span key={tag} className="px-2 py-1 bg-gray-700 text-gray-300 text-xs rounded">
                      {tag}
                    </span>
                  ))}
                </div>
              )}
              <ShareButtons mediaId={media.id_midia} title={media.titulo} />
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
