{
  lib,
  buildPythonPackage,
  fetchPypi,
  mscgen,
  sphinx,
}:

buildPythonPackage rec {
  pname = "sphinxcontrib-mscgen";
  version = "0.6";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-AXfSWRq3CepT/jNOgHxiYT7vkdKZejPu/LeUqxZ8T5A=";
  };

  propagatedBuildInputs = [
    mscgen
    sphinx
  ];

  # There are no unit tests
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "sphinxcontrib.mscgen" ];
  pythonNamespaces = [ "sphinxcontrib" ];

  meta = {
    description = "Sphinx extension using mscgen to render diagrams";
    homepage = "https://github.com/sphinx-contrib/mscgen";
    license = lib.licenses.bola11;
    maintainers = [ ];
  };
}
