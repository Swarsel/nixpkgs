{
  lib,
  bleak,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pycycling";
  version = "0.4.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-7vOjkXZ/IrsJ9JyqkbaeNcB59ZyfHQJLit5yPHoBUH4=";
  };

  propagatedBuildInputs = [
    bleak
  ];

  build-system = [ setuptools ];
  format = "setuptools";
  pythonImportsCheck = [ pname ];

  meta = {
    description = "Package for interacting with Bluetooth Low Energy (BLE) compatible bike trainers, power meters, radars and heart rate monitors";
    homepage = "https://github.com/zacharyedwardbull/pycycling";
    changelog = "https://github.com/zacharyedwardbull/pycycling/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ viraptor ];
  };
}
