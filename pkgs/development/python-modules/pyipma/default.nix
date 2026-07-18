{
  lib,
  fetchFromGitHub,
  aiohttp,
  aioresponses,
  buildPythonPackage,
  freezegun,
  geopy,
  mock,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyipma";
  version = "3.0.10";

  src = fetchFromGitHub {
    owner = "dgomes";
    repo = "pyipma";
    tag = "v${finalAttrs.version}";
    hash = "sha256-f1V+8So8TmR9Cu2fjD3B7EqeJd9e1G9cgCNytGul2Eo=";
  };

  nativeCheckInputs = [
    aioresponses
    freezegun
    mock
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    geopy
  ];

  disabledTestPaths = [
    # Tests require network access
    "tests/test_auxiliar.py"
    "tests/test_location.py"
    "tests/test_sea_forecast.py"
  ];

  disabledTests = [
    # Test requires network access
    "test_retrieve_returns_json_response_from_api"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyipma" ];

  meta = {
    description = "Library to retrieve information from Instituto Português do Mar e Atmosfera";
    homepage = "https://github.com/dgomes/pyipma";
    changelog = "https://github.com/dgomes/pyipma/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
