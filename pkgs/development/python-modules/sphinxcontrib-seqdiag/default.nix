{
  lib,
  blockdiag,
  buildPythonPackage,
  fetchPypi,
  seqdiag,
  sphinx,
}:

buildPythonPackage rec {
  pname = "sphinxcontrib-seqdiag";
  version = "3.0.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-QH5IeXZz9x2Ujp/6BHFsrB2ZqeyPYW3jdk1C0DNBZXQ=";
  };

  propagatedBuildInputs = [
    blockdiag
    seqdiag
    sphinx
  ];

  format = "setuptools";
  pythonImportsCheck = [ "sphinxcontrib.seqdiag" ];
  pythonNamespaces = [ "sphinxcontrib" ];

  meta = {
    description = "Sphinx seqdiag extension";
    homepage = "https://github.com/blockdiag/sphinxcontrib-seqdiag";
    license = lib.licenses.bsd2;
    maintainers = [ ];
  };
}
