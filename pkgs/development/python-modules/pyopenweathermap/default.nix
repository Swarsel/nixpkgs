{
  lib,
  fetchFromGitHub,
  # dependencies
  aiohttp,
  buildPythonPackage,
  # build-system
  poetry-core,
  # tests
  pytest-asyncio,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "pyopenweathermap";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "freekode";
    repo = "pyopenweathermap";
    # https://github.com/freekode/pyopenweathermap/issues/2
    tag = "v${version}";
    hash = "sha256-i/oqjrViATNR+HuG72ZdPMJF9TJf7B1pi+wqCth34OU=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ poetry-core ];
  dependencies = [ aiohttp ];

  disabledTestMarks = [
    "network"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyopenweathermap" ];

  meta = {
    description = "Python library for OpenWeatherMap API for Home Assistant";
    homepage = "https://github.com/freekode/pyopenweathermap";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
