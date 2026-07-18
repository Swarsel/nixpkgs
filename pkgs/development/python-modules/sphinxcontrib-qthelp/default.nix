{
  lib,
  buildPythonPackage,
  fetchPypi,
  flit-core,
}:

buildPythonPackage rec {
  pname = "sphinxcontrib-qthelp";
  version = "2.0.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-T+fQrI/BcQRb5iOro+Ko9hP4aCcx+RU7suQOzha5u6s=";
    pname = "sphinxcontrib_qthelp";
  };

  nativeBuildInputs = [ flit-core ];
  doCheck = false;
  # Check is disabled due to circular dependency of sphinx
  dontCheckRuntimeDeps = true;
  pyproject = true;
  pythonNamespaces = [ "sphinxcontrib" ];

  meta = {
    description = "Sphinx extension which outputs QtHelp document";
    homepage = "https://github.com/sphinx-doc/sphinxcontrib-qthelp";
    license = lib.licenses.bsd2;
  };
}
