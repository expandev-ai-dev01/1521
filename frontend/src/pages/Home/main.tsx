import { Link } from 'react-router-dom';

/**
 * @page HomePage
 * @summary Home page displaying welcome message and introduction.
 * @domain core
 * @type landing-page
 * @category public
 */
export const HomePage = () => {
  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
      <div className="text-center">
        <h1 className="text-4xl font-bold text-gray-900 mb-4">Bem-vindo ao Portal da Bola</h1>
        <p className="text-xl text-gray-600 mb-8">
          Notícias atualizadas de futebol, fotos e vídeos dos principais jogos e eventos.
        </p>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8 mt-12">
          <div className="bg-white p-6 rounded-lg shadow-md">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">Notícias</h2>
            <p className="text-gray-600 mb-4">
              Acompanhe as últimas notícias sobre times, campeonatos e jogadores.
            </p>
            <Link
              to="/noticias"
              className="inline-block px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700"
            >
              Ver notícias
            </Link>
          </div>
          <div className="bg-white p-6 rounded-lg shadow-md">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">Galeria</h2>
            <p className="text-gray-600 mb-4">
              Fotos e vídeos recentes de jogos, jogadores e eventos esportivos.
            </p>
            <button
              disabled
              className="inline-block px-4 py-2 bg-gray-300 text-gray-600 rounded-md cursor-not-allowed"
            >
              Em breve
            </button>
          </div>
          <div className="bg-white p-6 rounded-lg shadow-md">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">Busca</h2>
            <p className="text-gray-600 mb-4">
              Sistema avançado de busca e recomendação de conteúdo relacionado.
            </p>
            <button
              disabled
              className="inline-block px-4 py-2 bg-gray-300 text-gray-600 rounded-md cursor-not-allowed"
            >
              Em breve
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default HomePage;
