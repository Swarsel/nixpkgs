{
  lib,
  fetchFromGitHub,
  bluetooth-sensor-state-data,
  buildPythonPackage,
  sensor-state-data,
  setuptools,
  victron-ble,
}:

buildPythonPackage rec {
  pname = "victron-ble-ha-parser";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "rajlaud";
    repo = "victron-ble-ha-parser";
    tag = "v${version}";
    hash = "sha256-WbJ0OQHTWigszOQ03427Nk6xfKqTHcPQ63tcSvG3x/k=";
  };

  # upstream has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    bluetooth-sensor-state-data
    sensor-state-data
    victron-ble
  ];

  pyproject = true;
  pythonImportsCheck = [ "victron_ble_ha_parser" ];

  meta = {
    description = "Parser for Victron BLE messages suitable for use with Home Assistant";
    homepage = "https://github.com/rajlaud/victron-ble-ha-parser";
    changelog = "https://github.com/rajlaud/victron-ble-ha-parser/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}
