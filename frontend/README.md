# Portal da Bola

Página de notícias de futebol, com links atualizados e fotos atuais.

## Tecnologias

- React 19.2.0
- TypeScript 5.6.3
- Vite 5.4.11
- TailwindCSS 3.4.14
- React Router DOM 7.9.3
- TanStack Query 5.90.2
- Axios 1.12.2
- Zustand 5.0.8

## Estrutura do Projeto

```
src/
├── app/                    # Configuração da aplicação
│   ├── App.tsx            # Componente raiz
│   ├── providers.tsx      # Provedores globais
│   └── router.tsx         # Configuração de rotas
├── pages/                 # Páginas da aplicação
│   ├── layouts/          # Layouts compartilhados
│   ├── Home/             # Página inicial
│   └── NotFound/         # Página 404
├── domain/               # Domínios de negócio
├── core/                 # Componentes e utilitários compartilhados
│   ├── components/       # Componentes genéricos
│   └── lib/             # Bibliotecas e configurações
└── assets/              # Recursos estáticos
    └── styles/          # Estilos globais
```

## Scripts Disponíveis

- `npm run dev` - Inicia o servidor de desenvolvimento
- `npm run build` - Compila o projeto para produção
- `npm run preview` - Visualiza a build de produção
- `npm run lint` - Executa o linter

## Configuração

1. Copie `.env.example` para `.env`
2. Configure as variáveis de ambiente:
   - `VITE_API_URL` - URL da API backend
   - `VITE_API_VERSION` - Versão da API (padrão: v1)
   - `VITE_API_TIMEOUT` - Timeout das requisições (padrão: 30000ms)

## Desenvolvimento

```bash
# Instalar dependências
npm install

# Iniciar servidor de desenvolvimento
npm run dev
```

## Build

```bash
# Compilar para produção
npm run build

# Visualizar build
npm run preview
```