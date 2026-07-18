{
  lib,
  buildPythonPackage,
  fetchPypi,
  flit-core,
}:

buildPythonPackage rec {
  pname = "sphinxcontrib-serializinghtml";
  version = "2.0.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-6dkSgn+HLAKQF6U/DvIYCzJ8P3/SPIcin3qOi3ADHU0=";
    pname = "sphinxcontrib_serializinghtml";
  };

  nativeBuildInputs = [ flit-core ];
  doCheck = false;
  # Check is disabled due to circular dependency of sphinx
  dontCheckRuntimeDeps = true;
  pyproject = true;
  pythonNamespaces = [ "sphinxcontrib" ];

  meta = {
    description = "Sphinx extension which outputs \"serialized\" HTML files (json and pickle)";
    homepage = "https://github.com/sphinx-doc/sphinxcontrib-serializinghtml";
    license = lib.licenses.bsd2;
  };
}
