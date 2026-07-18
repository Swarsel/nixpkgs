{
  lib,
  fetchFromGitHub,
  bleak,
  bleak-retry-connector,
  bluetooth-data-tools,
  bluetooth-sensor-state-data,
  buildPythonPackage,
  miauth,
  setuptools,
  wheel,
}:

buildPythonPackage rec {
  pname = "ninebot-ble";
  version = "0.0.6";

  src = fetchFromGitHub {
    owner = "ownbee";
    repo = "ninebot-ble";
    tag = version;
    hash = "sha256-gA3VTs45vVpO0Iy8MbvvDf9j99vsFzrkADaJEslx6y0=";
  };

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  propagatedBuildInputs = [
    bleak
    bleak-retry-connector
    bluetooth-data-tools
    bluetooth-sensor-state-data
    miauth
  ];

  # Module has no test
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "ninebot_ble" ];

  meta = {
    description = "Ninebot scooter BLE client";
    homepage = "https://github.com/ownbee/ninebot-ble";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "ninebot-ble";
  };
}
