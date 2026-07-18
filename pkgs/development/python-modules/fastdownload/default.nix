{
  lib,
  buildPythonPackage,
  fastcore,
  fastprogress,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "fastdownload";
  version = "0.0.7";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-IFB+246JQGofvXd15uKj2BpN1jPdUGsOnPDhYT6DHWo=";
  };

  propagatedBuildInputs = [
    fastprogress
    fastcore
  ];

  # no real tests
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "fastdownload" ];

  meta = {
    description = "Easily download, verify, and extract archives";
    homepage = "https://github.com/fastai/fastdownload";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ rxiao ];
  };
}
