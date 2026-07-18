{
  lib,
  buildPythonPackage,
  fetchPypi,
  flit-core,
}:

buildPythonPackage rec {
  pname = "sphinxcontrib-devhelp";
  version = "2.0.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-QR9dltRF0dc7tdUhMzd7QkjsedtceTzn2+WeB0tN0a0=";
    pname = "sphinxcontrib_devhelp";
  };

  nativeBuildInputs = [ flit-core ];
  doCheck = false;
  # Check is disabled due to circular dependency of sphinx
  dontCheckRuntimeDeps = true;
  pyproject = true;
  pythonNamespaces = [ "sphinxcontrib" ];

  meta = {
    description = "Sphinx extension which outputs Devhelp document";
    homepage = "https://github.com/sphinx-doc/sphinxcontrib-devhelp";
    license = lib.licenses.bsd2;
  };
}
