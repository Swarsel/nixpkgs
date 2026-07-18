{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  hatchling,
  lxml,
  mocket,
  pytest-asyncio,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "pyblu";
  version = "2.0.8";

  src = fetchFromGitHub {
    owner = "LouisChrist";
    repo = "pyblu";
    tag = "v${version}";
    hash = "sha256-uYYiu0V491eHg47Rc9HGEiddONnFqGuPj34Mkfk5Gnk=";
  };

  nativeCheckInputs = [
    mocket
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    aiohttp
    lxml
  ];

  disabledTestPaths = [
    # all tests fail with:
    #  aiohttp.client_exceptions.ClientConnectorDNSError: Cannot connect to host node:11000 ssl:default [Could not contact DNS servers]
    "tests/test_player.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyblu" ];
  pythonRelaxDeps = [ "aiohttp" ];

  meta = {
    description = "BluOS API client";
    homepage = "https://github.com/LouisChrist/pyblu";
    changelog = "https://github.com/LouisChrist/pyblu/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
