{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  requests,
  setuptools,
  urllib3,
}:

buildPythonPackage rec {
  pname = "xs1-api-client";
  version = "3.0.1";

  src = fetchFromGitHub {
    owner = "markusressel";
    repo = "xs1-api-client";
    tag = "v${version}";
    hash = "sha256-bAxrqtjoJaPkTzeeOeXSTpJN3rPszi5W4q6Q7ZRo0hc=";
  };

  build-system = [ setuptools ];

  dependencies = [
    requests
    urllib3
  ];

  pyproject = true;
  pythonImportsCheck = [ "xs1_api_client" ];

  meta = {
    description = "Python library for accessing actuator and sensor data on the EZcontrol XS1 Gateway";
    homepage = "https://github.com/markusressel/xs1-api-client";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}
