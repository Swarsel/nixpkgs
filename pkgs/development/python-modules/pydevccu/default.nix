{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  orjson,
  pytest-asyncio,
  pytestCheckHook,
  pythonOlder,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pydevccu";
  version = "0.2.5";

  src = fetchFromGitHub {
    owner = "SukramJ";
    repo = "pydevccu";
    tag = finalAttrs.version;
    hash = "sha256-Sf8XBvkf6dRuA6daJ48WJHuVYBhznDcPWLl+4xm46n0=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  dependencies = [ aiohttp ];
  disabled = pythonOlder "3.13";

  optional-dependencies = {
    fast = [ orjson ];
  };

  pyproject = true;
  pythonImportsCheck = [ "pydevccu" ];

  meta = {
    description = "HomeMatic CCU XML-RPC Server with fake devices";
    homepage = "https://github.com/SukramJ/pydevccu";
    changelog = "https://github.com/SukramJ/pydevccu/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
