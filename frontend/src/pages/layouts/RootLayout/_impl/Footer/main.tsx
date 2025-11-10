/**
 * @component Footer
 * @summary Application footer with copyright and links.
 * @domain core
 * @type layout-component
 * @category layout
 */
export const Footer = () => {
  const currentYear = new Date().getFullYear();

  return (
    <footer className="bg-gray-800 text-white">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="text-center">
          <p className="text-sm">© {currentYear} Portal da Bola. Todos os direitos reservados.</p>
        </div>
      </div>
    </footer>
  );
};
