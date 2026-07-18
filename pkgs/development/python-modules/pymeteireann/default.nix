{
  lib,
  fetchFromGitHub,
  aiohttp,
  async-timeout,
  buildPythonPackage,
  pytz,
  setuptools,
  xmltodict,
}:

buildPythonPackage rec {
  pname = "pymeteireann";
  version = "2024.11.0";

  src = fetchFromGitHub {
    owner = "DylanGore";
    repo = "PyMetEireann";
    tag = version;
    sha256 = "sha256-b59I2h9A3QoXEBUYhbR0vsGGpQpOvFrqhHZnVCS8fLo=";
  };

  # Project has no tests
  doCheck = false;

  build-system = [
    setuptools
  ];

  dependencies = [
    xmltodict
    aiohttp
    async-timeout
    pytz
  ];

  pyproject = true;
  pythonImportsCheck = [ "meteireann" ];

  meta = {
    description = "Python module to communicate with the Met Éireann Public Weather Forecast API";
    homepage = "https://github.com/DylanGore/PyMetEireann/";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
  };
}
