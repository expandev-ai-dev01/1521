import { mediaService } from '../../services';
import type { ShareButtonsProps } from './types';

/**
 * @component ShareButtons
 * @summary Social media share buttons for media content
 * @domain media
 * @type domain-component
 * @category interaction
 */
export const ShareButtons = ({ mediaId, title, onShare }: ShareButtonsProps) => {
  const handleShare = async (platform: string, url: string) => {
    try {
      await mediaService.registerShare(mediaId, platform);
      if (onShare) {
        onShare(platform);
      }
      window.open(url, '_blank', 'noopener,noreferrer');
    } catch (error: unknown) {
      console.error('Error registering share:', error);
    }
  };

  const shareUrls = {
    whatsapp: `https://wa.me/?text=${encodeURIComponent(title + ' - ' + window.location.href)}`,
    facebook: `https://www.facebook.com/sharer/sharer.php?u=${encodeURIComponent(
      window.location.href
    )}`,
    twitter: `https://twitter.com/intent/tweet?text=${encodeURIComponent(
      title
    )}&url=${encodeURIComponent(window.location.href)}`,
    telegram: `https://t.me/share/url?url=${encodeURIComponent(
      window.location.href
    )}&text=${encodeURIComponent(title)}`,
  };

  const handleCopyLink = async () => {
    try {
      await navigator.clipboard.writeText(window.location.href);
      await mediaService.registerShare(mediaId, 'link');
      if (onShare) {
        onShare('link');
      }
      alert('Link copiado para a área de transferência!');
    } catch (error: unknown) {
      console.error('Error copying link:', error);
    }
  };

  return (
    <div className="flex gap-2">
      <button
        onClick={() => handleShare('whatsapp', shareUrls.whatsapp)}
        className="px-4 py-2 bg-green-600 text-white rounded-md hover:bg-green-700 text-sm"
      >
        WhatsApp
      </button>
      <button
        onClick={() => handleShare('facebook', shareUrls.facebook)}
        className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 text-sm"
      >
        Facebook
      </button>
      <button
        onClick={() => handleShare('twitter', shareUrls.twitter)}
        className="px-4 py-2 bg-sky-500 text-white rounded-md hover:bg-sky-600 text-sm"
      >
        Twitter
      </button>
      <button
        onClick={() => handleShare('telegram', shareUrls.telegram)}
        className="px-4 py-2 bg-blue-500 text-white rounded-md hover:bg-blue-600 text-sm"
      >
        Telegram
      </button>
      <button
        onClick={handleCopyLink}
        className="px-4 py-2 bg-gray-600 text-white rounded-md hover:bg-gray-700 text-sm"
      >
        Copiar Link
      </button>
    </div>
  );
};
