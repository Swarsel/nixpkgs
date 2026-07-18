{
  lib,
  fetchFromGitHub,
  aiohomematic,
  aiohttp,
  buildPythonPackage,
  openccu-loom-types,
  pydantic,
  pytest-asyncio,
  pytestCheckHook,
  python-slugify,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "openccu-loom-client";
  version = "2026.7.6";

  src = fetchFromGitHub {
    owner = "SukramJ";
    repo = "openccu-loom-client";
    tag = finalAttrs.version;
    hash = "sha256-zeWZYYu/TdGr0OpAmiu0HMsXjf79TDy8lPNPm8x5urY=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    aiohomematic
    aiohttp
    openccu-loom-types
    pydantic
    python-slugify
  ];

  pyproject = true;
  pythonImportsCheck = [ "openccu_loom_client" ];

  meta = {
    description = "Async Python REST + WebSocket client for the openccu-loom daemon";
    homepage = "https://github.com/SukramJ/openccu-loom-client";
    changelog = "https://github.com/SukramJ/openccu-loom-client/blob/${finalAttrs.src.tag}/changelog.md";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.dotlambda ];
  };
})
