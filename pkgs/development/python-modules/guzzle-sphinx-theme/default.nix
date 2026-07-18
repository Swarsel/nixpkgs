{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  sphinx,
}:

buildPythonPackage rec {
  pname = "guzzle-sphinx-theme";
  version = "0.7.11";

  src = fetchPypi {
    inherit version;
    hash = "sha256-m4wWOcNDwCw/PbffZg3fb1M7VFTukqX3sC7apXP+0+Y=";
    pname = "guzzle_sphinx_theme";
  };

  nativeBuildInputs = [ setuptools ];
  propagatedBuildInputs = [ sphinx ];
  doCheck = false; # no tests
  pyproject = true;
  pythonImportsCheck = [ "guzzle_sphinx_theme" ];

  meta = {
    description = "Sphinx theme used by Guzzle: http://guzzlephp.org";
    homepage = "https://github.com/guzzle/guzzle_sphinx_theme/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ flokli ];
  };
}
