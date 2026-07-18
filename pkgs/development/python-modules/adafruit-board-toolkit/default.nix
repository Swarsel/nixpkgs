{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  pyserial,
  # build-system
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "adafruit-board-toolkit";
  version = "1.1.2";

  src = fetchFromGitHub {
    owner = "adafruit";
    repo = "Adafruit_Board_Toolkit";
    tag = version;
    hash = "sha256-xpz4+dGFcO/R/aBHub00N0oFS4w0prJl304PnbUKvAI=";
  };

  # Project has not published tests yet
  doCheck = false;

  build-system = [
    setuptools-scm
  ];

  dependencies = [
    pyserial
  ];

  pyproject = true;
  pythonImportsCheck = [ "adafruit_board_toolkit" ];

  meta = {
    description = "CircuitPython board identification and information";
    homepage = "https://github.com/adafruit/Adafruit_Board_Toolkit";
    changelog = "https://github.com/adafruit/Adafruit_Board_Toolkit/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ talhaHavadar ];
  };
}
