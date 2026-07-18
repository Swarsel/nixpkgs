{
  lib,
  actdiag,
  blockdiag,
  buildPythonPackage,
  fetchPypi,
  sphinx,
}:

buildPythonPackage rec {
  pname = "sphinxcontrib-actdiag";
  version = "3.0.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-PFXUVP/Due/nwg8q2vAiGZuCVhLTLyAL6KSXqofg+B8=";
  };

  propagatedBuildInputs = [
    actdiag
    blockdiag
    sphinx
  ];

  format = "setuptools";
  pythonImportsCheck = [ "sphinxcontrib.actdiag" ];
  pythonNamespaces = [ "sphinxcontrib" ];

  meta = {
    description = "Sphinx actdiag extension";
    homepage = "https://github.com/blockdiag/sphinxcontrib-actdiag";
    license = lib.licenses.bsd2;
    maintainers = [ ];
  };
}
