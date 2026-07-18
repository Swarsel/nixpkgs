{
  lib,
  fetchFromGitHub,
  # dependencies
  aiohttp,
  # tests
  aioresponses,
  buildPythonPackage,
  # build-system
  poetry-core,
  pytest-aiohttp,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "dio-chacon-wifi-api";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "cnico";
    repo = "dio-chacon-wifi-api";
    tag = "v${version}";
    hash = "sha256-c91xCrlNpCutZZYO6y0pOaqPCF4exbr7xVxfsf5LI0Q=";
  };

  nativeCheckInputs = [
    aioresponses
    pytest-aiohttp
    pytestCheckHook
  ];

  build-system = [ poetry-core ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "dio_chacon_wifi_api" ];

  meta = {
    description = "Python API via wifi for DIO devices from Chacon. Useful for homeassistant or other automations";
    homepage = "https://github.com/cnico/dio-chacon-wifi-api";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
