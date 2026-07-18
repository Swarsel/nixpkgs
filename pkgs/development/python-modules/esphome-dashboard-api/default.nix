{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  orjson,
  setuptools,
}:

buildPythonPackage rec {
  pname = "esphome-dashboard-api";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "esphome";
    repo = "dashboard-api";
    tag = version;
    hash = "sha256-b3PnMzlA9N8NH6R5ed6wf5QF45i887iQk2QgH7e755k=";
  };

  doCheck = false; # no tests
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    orjson
  ];

  pyproject = true;
  pythonImportsCheck = [ "esphome_dashboard_api" ];

  meta = {
    description = "API to interact with ESPHome Dashboard";
    homepage = "https://github.com/esphome/dashboard-api";
    changelog = "https://github.com/esphome/dashboard-api/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
