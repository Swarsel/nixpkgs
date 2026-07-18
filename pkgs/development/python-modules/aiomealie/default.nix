{
  lib,
  fetchFromGitHub,
  aiohttp,
  aioresponses,
  awesomeversion,
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
  pname = "aiomealie";
  version = "1.2.4";

  src = fetchFromGitHub {
    owner = "joostlek";
    repo = "python-mealie";
    tag = "v${finalAttrs.version}";
    hash = "sha256-OROL48v5SniYtzuCYZWt9mSXcFqMTO0JB2K+Ym3Ksz4=";
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
    awesomeversion
    mashumaro
    orjson
    yarl
  ];

  pyproject = true;
  pythonImportsCheck = [ "aiomealie" ];

  meta = {
    description = "Module to interact with Mealie";
    homepage = "https://github.com/joostlek/python-mealie";
    changelog = "https://github.com/joostlek/python-mealie/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
