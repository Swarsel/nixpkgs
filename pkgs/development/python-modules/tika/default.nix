{
  lib,
  buildPythonPackage,
  fetchPypi,
  pyyaml,
  requests,
}:

buildPythonPackage rec {
  pname = "tika";
  version = "3.1.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-TDpATD2EZDfJQtam/Xtx1QKFaQ+uVImqim8A/5zND8c=";
  };

  propagatedBuildInputs = [
    pyyaml
    requests
  ];

  # Requires network
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ pname ];

  meta = {
    description = "Python binding to the Apache Tika™ REST services";
    homepage = "https://github.com/chrismattmann/tika-python";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ Flakebi ];
    mainProgram = "tika-python";
  };
}
