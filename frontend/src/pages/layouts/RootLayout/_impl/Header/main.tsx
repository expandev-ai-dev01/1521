import { Link } from 'react-router-dom';

/**
 * @component Header
 * @summary Application header with navigation.
 * @domain core
 * @type layout-component
 * @category navigation
 */
export const Header = () => {
  return (
    <header className="bg-white shadow-sm">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between items-center h-16">
          <Link to="/" className="flex items-center">
            <h1 className="text-2xl font-bold text-blue-600">Portal da Bola</h1>
          </Link>
          <nav className="flex space-x-8">
            <Link
              to="/"
              className="text-gray-700 hover:text-blue-600 px-3 py-2 text-sm font-medium"
            >
              Início
            </Link>
          </nav>
        </div>
      </div>
    </header>
  );
};
