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

buildPythonPackage (finalAttrs: {
  pname = "trmnl";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "joostlek";
    repo = "python-trmnl";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Gpyhp+d27/IxDOTFxcN9ltYbOJOg9scf17qVb/ArBw0=";
  };

  nativeCheckInputs = [
    aioresponses
    pytest-asyncio
    pytest-cov-stub
    pytestCheckHook
    syrupy
  ];

  build-system = [ poetry-core ];

  dependencies = [
    aiohttp
    mashumaro
    orjson
    yarl
  ];

  pyproject = true;
  pythonImportsCheck = [ "trmnl" ];

  meta = {
    description = "Asynchronous Python client for TRMNL";
    homepage = "https://github.com/joostlek/python-trmnl";
    changelog = "https://github.com/joostlek/python-trmnl/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jamiemagee ];
  };
})
