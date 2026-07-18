{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  click,
  hatchling,
  influxdb,
  influxdb3-python,
  jsonpath-ng,
  paho-mqtt,
  py-expression-eval,
  pyaml,
  pycron,
  pydantic,
  pytestCheckHook,
  schema,
}:

buildPythonPackage rec {
  pname = "mqtt2influxdb";
  version = "2.0.6";

  src = fetchFromGitHub {
    owner = "hardwario";
    repo = "bch-mqtt2influxdb";
    tag = "v${version}";
    hash = "sha256-DS1k3JcTUK0yXRkJSFMeIZHSXpiIgSXJPZb3+72Wqko=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ hatchling ];

  dependencies = [
    influxdb
    jsonpath-ng
    paho-mqtt
    py-expression-eval
    pyaml
    pycron
    schema
    click
    influxdb3-python
    pydantic
  ];

  pyproject = true;
  pythonImportsCheck = [ "mqtt2influxdb" ];

  meta = {
    description = "Flexible MQTT to InfluxDB Bridge";
    homepage = "https://github.com/hardwario/bch-mqtt2influxdb";
    changelog = "https://github.com/hardwario/bch-mqtt2influxdb/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ cynerd ];
    mainProgram = "mqtt2influxdb";
  };
}
