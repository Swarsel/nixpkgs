{
  lib,
  fetchFromGitHub,
  aiohttp,
  aresponses,
  backoff,
  buildPythonPackage,
  certifi,
  poetry-core,
  pytest-aiohttp,
  pytest-asyncio,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "pyopenuv";
  version = "2023.12.0";

  src = fetchFromGitHub {
    owner = "bachya";
    repo = "pyopenuv";
    tag = version;
    hash = "sha256-r+StbiU77/1dz41tCseleIWjiIvuvRveVgPNr3n4CEY=";
  };

  nativeBuildInputs = [ poetry-core ];

  propagatedBuildInputs = [
    aiohttp
    backoff
    certifi
  ];

  nativeCheckInputs = [
    aresponses
    pytest-asyncio
    pytest-aiohttp
    pytestCheckHook
  ];

  __darwinAllowLocalNetworking = true;

  disabledTestPaths = [
    # Ignore the examples as they are prefixed with test_
    "examples/"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyopenuv" ];

  meta = {
    description = "Python API to retrieve data from openuv.io";
    homepage = "https://github.com/bachya/pyopenuv";
    changelog = "https://github.com/bachya/pyopenuv/releases/tag/${version}";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
  };
}
