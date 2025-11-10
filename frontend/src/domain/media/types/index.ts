export interface Media {
  id_midia: string;
  tipo_midia: 'foto' | 'video';
  titulo: string;
  descricao?: string;
  data_captura: string;
  local?: string;
  creditos: string;
  tags?: string[];
  categoria: string;
  subcategoria?: string;
  url_arquivo: string;
  url_thumbnail: string;
  resolucao: string;
  duracao?: string;
  formato?: string;
  descricao_alternativa: string;
  contador_visualizacoes: number;
  contador_compartilhamentos: number;
  galerias_tematicas?: string[];
  status: 'publicado' | 'rascunho' | 'em_moderacao' | 'rejeitado';
}

export interface MediaListParams {
  filtro_categoria?: string;
  filtro_subcategoria?: string;
  filtro_data_inicio?: string;
  filtro_data_fim?: string;
  filtro_tipo_midia?: ('foto' | 'video')[];
  filtro_tags?: string[];
  galeria_tematica?: string;
  ordenacao?: 'mais_recentes' | 'mais_antigos' | 'mais_visualizados' | 'mais_compartilhados';
  visualizacao?: 'grade' | 'lista' | 'mosaico';
  itens_por_pagina?: number;
  pagina_atual?: number;
}

export interface MediaListResponse {
  items: Media[];
  total: number;
  page: number;
  pageSize: number;
  totalPages: number;
}

export type MediaType = 'foto' | 'video';

export type MediaCategory = 'times' | 'campeonatos' | 'jogadores' | 'eventos';

export interface ThematicGallery {
  id_galeria: string;
  titulo: string;
  slug: string;
  descricao: string;
  imagem_capa: string;
  status: 'publicada' | 'rascunho' | 'arquivada';
  destaque: boolean;
  ordem_destaque?: number;
  contador_visualizacoes: number;
}
