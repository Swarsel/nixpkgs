{
  lib,
  fetchFromGitHub,
  aiohttp,
  aresponses,
  buildPythonPackage,
  certifi,
  numpy,
  poetry-core,
  pygments,
  pysmb,
  pytest-aiohttp,
  pytest-asyncio,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "pyairvisual";
  version = "2023.12.0";

  src = fetchFromGitHub {
    owner = "bachya";
    repo = "pyairvisual";
    tag = version;
    hash = "sha256-uN31LeHYmg4V6Ln3EQp765nOsN5v56TxjYSS/g6TUCY=";
  };

  nativeBuildInputs = [ poetry-core ];

  propagatedBuildInputs = [
    aiohttp
    certifi
    numpy
    pygments
    pysmb
  ];

  nativeCheckInputs = [
    aresponses
    pytest-aiohttp
    pytest-asyncio
    pytestCheckHook
    pytestCheckHook
  ];

  # this lets tests bind to localhost in sandbox mode on macOS
  __darwinAllowLocalNetworking = true;

  disabledTestPaths = [
    # Ignore the examples directory as the files are prefixed with test_.
    "examples/"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyairvisual" ];

  meta = {
    description = "Python library for interacting with AirVisual";
    homepage = "https://github.com/bachya/pyairvisual";
    changelog = "https://github.com/bachya/pyairvisual/releases/tag/${version}";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
  };
}
