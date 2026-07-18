{
  lib,
  buildPythonPackage,
  fetchPypi,
  pysocks,
  requests,
  stem,
}:

buildPythonPackage rec {
  pname = "torrequest";
  version = "0.1.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-N0XU6j/9qY16A0Njx4ets3qrd72rQAlKTZNzks1NroI=";
  };

  propagatedBuildInputs = [
    pysocks
    requests
    stem
  ];

  # This package does not contain any tests.
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "torrequest" ];

  meta = {
    description = "Simple Python interface for HTTP(s) requests over Tor";
    homepage = "https://github.com/erdiaker/torrequest";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ applePrincess ];
  };
}
