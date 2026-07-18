{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyw215";
  version = "0.8.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-AQRGXpuduHRMozEZQMNLX5f5GtJa3T/5rHIGqGvWUP4=";
  };

  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "pyW215" ];

  meta = {
    description = "Python library for interfacing with D-Link W215 Smart Plugs";
    homepage = "https://github.com/linuxchristian/pyW215";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}
