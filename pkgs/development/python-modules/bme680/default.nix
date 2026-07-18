{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatch-fancy-pypi-readme,
  # build-system
  hatchling,
  # checks
  mock,
  pytestCheckHook,
  # dependencies
  smbus2,
}:

buildPythonPackage rec {
  pname = "bme680";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "pimoroni";
    repo = "bme680-python";
    tag = "v${version}";
    hash = "sha256-ep0dnok/ycEoUAnOK4QmdqdO0r4ttzSoqHDl7aPengE=";
  };

  nativeCheckInputs = [
    mock
    pytestCheckHook
  ];

  build-system = [
    hatchling
    hatch-fancy-pypi-readme
  ];

  dependencies = [ smbus2 ];
  pyproject = true;
  pythonImportsCheck = [ "bme680" ];

  meta = {
    description = "Python library for driving the Pimoroni BME680 Breakout";
    homepage = "https://github.com/pimoroni/bme680-python";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mic92 ];
    platforms = lib.platforms.linux;
  };
}
