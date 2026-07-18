{
  lib,
  buildPythonPackage,
  fetchPypi,
  sphinx,
  sphinxcontrib-tikz,
}:

buildPythonPackage rec {
  pname = "sphinxcontrib-bayesnet";
  version = "0.4";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-+M+K8WzQqxQUGgAgGPK+isf3gKK7HOrdI6nNW/V8Wv0=";
  };

  propagatedBuildInputs = [
    sphinx
    sphinxcontrib-tikz
  ];

  # No tests
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "sphinxcontrib.bayesnet" ];
  pythonNamespaces = [ "sphinxcontrib" ];

  meta = {
    description = "Bayesian networks and factor graphs in Sphinx using TikZ syntax";
    homepage = "https://github.com/jluttine/sphinx-bayesnet";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ jluttine ];
  };
}
