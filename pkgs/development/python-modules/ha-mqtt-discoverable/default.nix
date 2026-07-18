{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  gitlike-commands,
  paho-mqtt,
  poetry-core,
  pyaml,
  pydantic,
}:

buildPythonPackage rec {
  pname = "ha-mqtt-discoverable";
  version = "0.24.2";

  src = fetchFromGitHub {
    owner = "unixorn";
    repo = "ha-mqtt-discoverable";
    tag = "v${version}";
    hash = "sha256-8UgYtWB6CsTF9yCpwwjeYIyjfFH8IM3M0sZpvrSqb3M=";
  };

  # Test require a running Mosquitto instance
  doCheck = false;
  build-system = [ poetry-core ];

  dependencies = [
    gitlike-commands
    paho-mqtt
    pyaml
    pydantic
  ];

  pyproject = true;
  pythonImportsCheck = [ "ha_mqtt_discoverable" ];

  pythonRelaxDeps = [
    "paho-mqtt"
    "pyaml"
    "pydantic"
  ];

  meta = {
    description = "Python module to create MQTT entities that are automatically discovered by Home Assistant";
    homepage = "https://github.com/unixorn/ha-mqtt-discoverable";
    changelog = "https://github.com/unixorn/ha-mqtt-discoverable/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}
