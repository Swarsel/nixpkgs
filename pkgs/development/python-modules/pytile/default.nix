{
  lib,
  fetchFromGitHub,
  aiohttp,
  aresponses,
  buildPythonPackage,
  certifi,
  poetry-core,
  pytest-aiohttp,
  pytest-asyncio,
  pytestCheckHook,
  yarl,
}:

buildPythonPackage rec {
  pname = "pytile";
  version = "2024.12.0";

  src = fetchFromGitHub {
    owner = "bachya";
    repo = "pytile";
    tag = version;
    hash = "sha256-6vcFGMj7E1xw01yHOq/WDpqMxd7OIiRBCmw5LForAR0=";
  };

  nativeBuildInputs = [ poetry-core ];

  propagatedBuildInputs = [
    aiohttp
    certifi
    yarl
  ];

  nativeCheckInputs = [
    aresponses
    pytest-aiohttp
    pytest-asyncio
    pytestCheckHook
  ];

  __darwinAllowLocalNetworking = true;

  disabledTestPaths = [
    # Ignore the examples as they are prefixed with test_
    "examples/"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pytile" ];

  meta = {
    description = "Python API for Tile Bluetooth trackers";

    longDescription = ''
      pytile is a simple Python library for retrieving information on Tile
      Bluetooth trackers (including last location and more).
    '';

    homepage = "https://github.com/bachya/pytile";
    changelog = "https://github.com/bachya/pytile/releases/tag/${version}";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
  };
}
