{
  lib,
  fetchFromGitHub,
  awesomeversion,
  buildPythonPackage,
  click,
  crcmod,
  getmac,
  intelhex,
  paho-mqtt,
  pyserial,
  pyserial-asyncio-fast,
  pytest-sugar,
  pytest-timeout,
  pytestCheckHook,
  setuptools,
  voluptuous,
}:

buildPythonPackage rec {
  pname = "pymysensors";
  version = "0.26.0";

  src = fetchFromGitHub {
    owner = "theolind";
    repo = "pymysensors";
    tag = version;
    hash = "sha256-iND3MEKEruqCdsqJJExm+SA4Z2e87I45fsI4wbnIPRc=";
  };

  nativeCheckInputs = [
    pytest-sugar
    pytest-timeout
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    awesomeversion
    click
    crcmod
    getmac
    intelhex
    pyserial
    pyserial-asyncio-fast
    voluptuous
  ];

  optional-dependencies = {
    mqtt-client = [ paho-mqtt ];
  };

  pyproject = true;
  pythonImportsCheck = [ "mysensors" ];

  meta = {
    description = "Python API for talking to a MySensors gateway";
    homepage = "https://github.com/theolind/pymysensors";
    changelog = "https://github.com/theolind/pymysensors/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "pymysensors";
  };
}
