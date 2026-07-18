{
  lib,
  bleak,
  bleak-retry-connector,
  buildPythonPackage,
  fetchPypi,
  poetry-core,
}:

buildPythonPackage rec {
  pname = "medcom-ble";
  version = "0.1.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-PQ0ZOFLGVllz/Jxw2CN6D5Ypza5/Ck3dtk3DuB+eHiA=";
    pname = "medcom_ble";
  };

  # Package has no tests
  doCheck = false;

  build-system = [
    poetry-core
  ];

  dependencies = [
    bleak
    bleak-retry-connector
  ];

  pyproject = true;

  pythonImportsCheck = [
    "medcom_ble"
  ];

  meta = {
    description = "Library to communicate with Medcom BLE radiation monitors";
    homepage = "https://github.com/elafargue/medcom-ble";
    changelog = "https://github.com/elafargue/medcom-ble/blob/main/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}
