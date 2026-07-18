{
  lib,
  buildPythonPackage,
  distutils,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "css-html-js-minify";
  version = "2.5.5";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Sp8R9+BJb1KE0SER87pP9f8gI9EvFdGVycSL2XATdGw=";
    extension = "zip";
  };

  # Tests are useless and broken
  doCheck = false;

  build-system = [
    distutils
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "css_html_js_minify" ];

  meta = {
    description = "StandAlone Async cross-platform Minifier for the Web";
    homepage = "https://github.com/juancarlospaco/css-html-js-minify";

    license = with lib.licenses; [
      gpl3Plus
      lgpl3Plus
      mit
    ];

    maintainers = with lib.maintainers; [ FlorianFranzen ];
    mainProgram = "css-html-js-minify";
  };
}
