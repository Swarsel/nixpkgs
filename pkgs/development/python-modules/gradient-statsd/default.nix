{
  lib,
  buildPythonPackage,
  certifi,
  chardet,
  datadog,
  decorator,
  fetchPypi,
  idna,
  requests,
  urllib3,
}:

buildPythonPackage rec {
  pname = "gradient-statsd";
  version = "1.0.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-iWlNX43ZtvU73wz4+8DgDulQNOnssJGxTBkvAaLj530=";
    pname = "gradient_statsd";
  };

  propagatedBuildInputs = [
    certifi
    chardet
    datadog
    decorator
    idna
    requests
    urllib3
  ];

  # Pypi does not contain tests
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "gradient_statsd" ];

  meta = {
    description = "Wrapper around the DogStatsd client";
    homepage = "https://paperspace.com";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
}
