{
  lib,
  fetchFromGitHub,
  aiohttp,
  aioresponses,
  buildPythonPackage,
  mashumaro,
  orjson,
  poetry-core,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  syrupy,
  yarl,
}:

buildPythonPackage rec {
  pname = "python-open-router";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "joostlek";
    repo = "python-open-router";
    tag = "v${version}";
    hash = "sha256-hf8Ay3/xXH262/1R07mN0iQpOlHFhHb6VUZoYQEq8YI=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
    pytest-cov-stub
    aioresponses
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
  pythonImportsCheck = [ "python_open_router" ];

  meta = {
    description = "Asynchronous Python client for Open Router";
    homepage = "https://github.com/joostlek/python-open-router";
    changelog = "https://github.com/joostlek/python-open-router/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}
