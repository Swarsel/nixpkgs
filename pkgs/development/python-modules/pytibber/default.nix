{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  gql,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
  websockets,
}:

buildPythonPackage (finalAttrs: {
  pname = "pytibber";
  version = "0.37.6";

  src = fetchFromGitHub {
    owner = "Danielhiversen";
    repo = "pyTibber";
    tag = finalAttrs.version;
    hash = "sha256-pyU8ju1T+AI4UvWq4/gtS8wV0a/cZfoRzlWpoK9eTtM=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    gql
    websockets
  ];

  disabledTestPaths = [
    # Tests access network
    "test/test_tibber.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "tibber" ];

  meta = {
    description = "Python library to communicate with Tibber";
    homepage = "https://github.com/Danielhiversen/pyTibber";
    changelog = "https://github.com/Danielhiversen/pyTibber/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
})
