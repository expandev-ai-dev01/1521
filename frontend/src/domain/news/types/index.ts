export interface News {
  id_noticia: string;
  titulo: string;
  subtitulo?: string;
  conteudo: string;
  data_publicacao: string;
  data_atualizacao?: string;
  autor: {
    id: string;
    nome: string;
  };
  imagem_destaque: string;
  status:
    | 'rascunho'
    | 'em_revisao'
    | 'em_revisao_sensivel'
    | 'aprovado_parcial'
    | 'aprovado'
    | 'publicado'
    | 'arquivado'
    | 'rejeitado';
  categorias: string[];
  tags?: string[];
  times_relacionados?: string[];
  campeonatos_relacionados?: string[];
  jogadores_relacionados?: string[];
  destaque: boolean;
  fonte_externa?: {
    nome: string;
    url: string;
  };
  conteudo_sensivel: boolean;
  criterios_sensibilidade?: string[];
  contador_visualizacoes: number;
  tempo_leitura: number;
}

export interface NewsListParams {
  filtro_categoria?: string[];
  filtro_time?: string[];
  filtro_campeonato?: string[];
  filtro_jogador?: string[];
  filtro_data_inicio?: string;
  filtro_data_fim?: string;
  termo_busca?: string;
  ordenacao?: 'mais_recentes' | 'mais_antigas' | 'mais_lidas' | 'relevancia';
  itens_por_pagina?: number;
  pagina_atual?: number;
}

export interface NewsListResponse {
  items: News[];
  total: number;
  page: number;
  pageSize: number;
  totalPages: number;
}

export interface CreateNewsDto {
  titulo: string;
  subtitulo?: string;
  conteudo: string;
  imagem_destaque: string;
  categorias: string[];
  tags?: string[];
  times_relacionados?: string[];
  campeonatos_relacionados?: string[];
  jogadores_relacionados?: string[];
  destaque?: boolean;
  fonte_externa_nome?: string;
  fonte_externa_url?: string;
  conteudo_sensivel?: boolean;
  criterios_sensibilidade?: string[];
}

export interface UpdateNewsDto extends Partial<CreateNewsDto> {
  status?: News['status'];
}

export interface Category {
  id_categoria: string;
  nome: string;
  descricao?: string;
  slug: string;
  icone?: string;
  cor?: string;
  ordem: number;
  ativa: boolean;
  categoria_pai?: string;
}

export interface Entity {
  id_entidade: string;
  tipo_entidade: 'time' | 'campeonato' | 'jogador';
  nome: string;
  slug: string;
  descricao?: string;
  imagem?: string;
  pais: string;
  ativo: boolean;
}
