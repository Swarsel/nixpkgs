{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "autoskope-client";
  version = "1.4.1";

  src = fetchFromGitHub {
    owner = "mcisk";
    repo = "autoskope_client";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ThrI5BzjxVg4K1fvRZvPfDycAh4A9rm226FSpk3a/zs=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  dependencies = [ aiohttp ];

  disabledTestMarks = [
    "integration"
  ];

  pyproject = true;
  pythonImportsCheck = [ "autoskope_client" ];

  meta = {
    description = "Python client library for the Autoskope API";
    homepage = "https://github.com/mcisk/autoskope_client";
    changelog = "https://github.com/mcisk/autoskope_client/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ jamiemagee ];
  };
})
