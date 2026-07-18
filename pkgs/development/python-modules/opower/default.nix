{
  lib,
  fetchFromGitHub,
  aiohttp,
  aiozoneinfo,
  arrow,
  buildPythonPackage,
  cryptography,
  pyotp,
  pytest-asyncio,
  pytestCheckHook,
  python-dotenv,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "opower";
  version = "0.18.6";

  src = fetchFromGitHub {
    owner = "tronikos";
    repo = "opower";
    tag = "v${finalAttrs.version}";
    hash = "sha256-lOmd/eyU0XDPbAjW2ur9lSlq5ECv80/1FZXjLaZ92e4=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
    python-dotenv
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    aiozoneinfo
    arrow
    cryptography
    pyotp
  ];

  disabledTestPaths = [
    # network access
    "tests/test_opower.py"
  ];

  disabledTests = [
    # Tests require network access
    "test_invalid_auth"
  ];

  pyproject = true;
  pythonImportsCheck = [ "opower" ];

  meta = {
    description = "Module for getting historical and forecasted usage/cost from utilities that use opower.com";
    homepage = "https://github.com/tronikos/opower";
    changelog = "https://github.com/tronikos/opower/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
