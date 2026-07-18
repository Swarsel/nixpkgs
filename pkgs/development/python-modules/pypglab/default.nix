{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  paho-mqtt,
  voluptuous,
}:

buildPythonPackage rec {
  pname = "pypglab";
  version = "0.0.5";

  src = fetchFromGitHub {
    owner = "pglab-electronics";
    repo = "pypglab";
    tag = version;
    hash = "sha256-nnLGFVV+aWkaE7RnAzLHji/tKxIiA9qJS/BUTv3KNeo=";
  };

  # tests require physical hardware
  doCheck = false;
  build-system = [ hatchling ];

  dependencies = [
    voluptuous
    paho-mqtt
  ];

  pyproject = true;
  pythonImportsCheck = [ "pypglab" ];

  meta = {
    description = "Asynchronous Python library to communicate with PG LAB Electronics devices over MQTT";
    homepage = "https://github.com/pglab-electronics/pypglab";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
