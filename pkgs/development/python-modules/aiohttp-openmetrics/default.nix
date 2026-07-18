{
  lib,
  aiohttp,
  buildPythonPackage,
  fetchPypi,
  prometheus-client,
  setuptools,
}:

buildPythonPackage rec {
  pname = "aiohttp-openmetrics";
  version = "0.0.12";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-/ZRngcMlroCVTvIl+30DR4SI8LsSnTovuzg3YduWgWA=";
  };

  # no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    prometheus-client
  ];

  pyproject = true;
  pythonImportsCheck = [ "aiohttp_openmetrics" ];

  meta = {
    description = "OpenMetrics provider for aiohttp";
    homepage = "https://github.com/jelmer/aiohttp-openmetrics/";
    changelog = "https://github.com/jelmer/aiohttp-openmetrics/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
