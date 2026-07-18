{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cryptography,
  paho-mqtt,
  psutil,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pysrdaligateway";
  version = "0.21.0";

  src = fetchFromGitHub {
    owner = "maginawin";
    repo = "PySrDaliGateway";
    tag = "v${version}";
    hash = "sha256-X9XLwlS4WAkNMghrs0AtHl2vwt/R2BEWPsqPY8gZNUs=";
  };

  # upstream "relies on manual integration testing with physical DALI hardware"
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    cryptography
    paho-mqtt
    psutil
  ];

  pyproject = true;
  pythonImportsCheck = [ "PySrDaliGateway" ];

  meta = {
    description = "Python library for Sunricher DALI Gateway (EDA)";
    homepage = "https://github.com/maginawin/PySrDaliGateway";
    changelog = "https://github.com/maginawin/PySrDaliGateway/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.dotlambda ];
  };
}
