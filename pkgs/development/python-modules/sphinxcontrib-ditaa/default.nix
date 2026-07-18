{
  lib,
  buildPythonPackage,
  ditaa,
  fetchPypi,
  setuptools,
  sphinx,
}:

buildPythonPackage rec {
  pname = "sphinxcontrib-ditaa";
  version = "1.0.3";

  src = fetchPypi {
    inherit version;
    hash = "sha256-8O74Gyb4KxER/VlFQWwHKQQjiYNU1ch5n6eLneVHTCg=";
    pname = "sphinxcontrib_ditaa";
  };

  # no tests provided
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    sphinx
    ditaa
  ];

  pyproject = true;
  # ? needs docutils exported as runtime dep
  #pythonImportsCheck = [ "sphinxcontrib.ditaa" ];
  pythonNamespaces = [ "sphinxcontrib" ];

  meta = {
    description = "Sphinx ditaa extension";
    homepage = "https://pypi.org/project/sphinxcontrib-ditaa";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ rconybea ];
  };
}
