{
  lib,
  fetchFromGitHub,
  aiohttp,
  aresponses,
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
  pname = "powerfox";
  version = "2.1.2";

  src = fetchFromGitHub {
    owner = "klaasnicolaas";
    repo = "python-powerfox";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Uki9yIRac2V3v85f+v+Qzle7bAxlmHz2MZOsIntN8Sw=";
  };

  nativeCheckInputs = [
    aresponses
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
  pythonImportsCheck = [ "powerfox" ];

  meta = {
    description = "Asynchronous Python client for the Powerfox devices";
    homepage = "https://github.com/klaasnicolaas/python-powerfox";
    changelog = "https://github.com/klaasnicolaas/python-powerfox/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
