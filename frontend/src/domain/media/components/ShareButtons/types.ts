export interface ShareButtonsProps {
  mediaId: string;
  title: string;
  onShare?: (platform: string) => void;
}
