{
  lib,
  fetchFromGitHub,
  # dependencies
  aiohttp,
  aioresponses,
  buildPythonPackage,
  mashumaro,
  orjson,
  # build-system
  poetry-core,
  pytest-asyncio,
  pytest-cov-stub,
  # tests
  pytestCheckHook,
  syrupy,
  yarl,
}:

buildPythonPackage rec {
  pname = "python-homeassistant-analytics";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "joostlek";
    repo = "python-homeassistant-analytics";
    tag = "v${version}";
    hash = "sha256-Deh3pZKpqdrlgv6LQk3NHuATz3porWiM8dewjbdbR7M=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    aioresponses
    pytest-cov-stub
    pytest-asyncio
    syrupy
  ];

  build-system = [ poetry-core ];

  dependencies = [
    aiohttp
    yarl
    mashumaro
    orjson
  ];

  pyproject = true;
  pythonImportsCheck = [ "python_homeassistant_analytics" ];

  meta = {
    description = "Asynchronous Python client for Home Assistant Analytics";
    homepage = "https://github.com/joostlek/python-homeassistant-analytics";
    changelog = "https://github.com/joostlek/python-homeassistant-analytics/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jamiemagee ];
  };
}
