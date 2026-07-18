{
  lib,
  fetchFromGitHub,
  aiohttp,
  aioresponses,
  buildPythonPackage,
  hatchling,
  mashumaro,
  orjson,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  syrupy,
  yarl,
}:

buildPythonPackage (finalAttrs: {
  pname = "zinvolt";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "joostlek";
    repo = "python-zinvolt";
    tag = "v${finalAttrs.version}";
    hash = "sha256-e4kbAEUxJzc2qOnXhtNMFUeDcsUc/G1Wo0LHwTQcgXs=";
  };

  nativeCheckInputs = [
    aioresponses
    pytest-asyncio
    pytest-cov-stub
    pytestCheckHook
    syrupy
  ];

  build-system = [ hatchling ];

  dependencies = [
    aiohttp
    mashumaro
    orjson
    yarl
  ];

  pyproject = true;
  pythonImportsCheck = [ "zinvolt" ];

  meta = {
    description = "Asynchronous Python client for Zinvolt";
    homepage = "https://github.com/joostlek/python-zinvolt";
    changelog = "https://github.com/joostlek/python-zinvolt/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
})
