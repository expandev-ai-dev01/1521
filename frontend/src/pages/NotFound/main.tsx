import { Link } from 'react-router-dom';

/**
 * @page NotFoundPage
 * @summary 404 error page for non-existent routes.
 * @domain core
 * @type error-page
 * @category public
 */
export const NotFoundPage = () => {
  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50">
      <div className="text-center">
        <h1 className="text-6xl font-bold text-gray-900 mb-4">404</h1>
        <p className="text-xl text-gray-600 mb-8">Página não encontrada</p>
        <Link
          to="/"
          className="inline-block px-6 py-3 bg-blue-600 text-white rounded-md hover:bg-blue-700"
        >
          Voltar para o início
        </Link>
      </div>
    </div>
  );
};

export default NotFoundPage;
