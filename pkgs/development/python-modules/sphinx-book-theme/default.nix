{
  lib,
  buildPythonPackage,
  fetchPypi,
  jupyter-book,
  pydata-sphinx-theme,
  sphinx,
}:

buildPythonPackage rec {
  pname = "sphinx-book-theme";
  version = "1.2.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-cJYF0wjhmRxe8M8ZxIHb6QhLYoUuMX+vq3Q4Kg7nzPo=";
    dist = "py3";
    format = "wheel";
    pname = "sphinx_book_theme";
    python = "py3";
  };

  dependencies = [
    pydata-sphinx-theme
    sphinx
  ];

  format = "wheel";
  pythonImportsCheck = [ "sphinx_book_theme" ];

  passthru.tests = {
    inherit jupyter-book;
  };

  meta = {
    description = "Clean book theme for scientific explanations and documentation with Sphinx";
    homepage = "https://github.com/executablebooks/sphinx-book-theme";
    changelog = "https://github.com/executablebooks/sphinx-book-theme/raw/v${version}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
