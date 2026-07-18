{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  click,
  modbus-tk,
  poetry-core,
  pyserial,
  setuptools,
}:

buildPythonPackage rec {
  pname = "riden";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "geeksville";
    repo = "riden";
    tag = version;
    hash = "sha256-uR1CsVsGn/QC4krHaxl6GqRnTPbFdRaqyMEl2RVMHPU=";
  };

  # Module has no tests
  doCheck = false;

  build-system = [
    poetry-core
    setuptools
  ];

  dependencies = [
    click
    modbus-tk
    pyserial
  ];

  pyproject = true;
  pythonImportsCheck = [ "riden" ];

  meta = {
    description = "Module for Riden RD power supplies";
    homepage = "https://github.com/geeksville/riden";
    changelog = "https://github.com/geeksville/Riden/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
