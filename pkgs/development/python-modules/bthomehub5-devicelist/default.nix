{
  lib,
  buildPythonPackage,
  fetchPypi,
  html-table-parser-python3,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "bthomehub5-devicelist";
  version = "0.1.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-bWMwLbFGdMRcZLIVbOptWMOOFzVBm2KxQ9jwqvAU6zA=";
  };

  # No tests in the package
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    html-table-parser-python3
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "bthomehub5_devicelist" ];
  pythonRelaxDeps = [ "html-table-parser-python3" ];

  meta = {
    description = "Returns a list of devices currently connected to a BT Home Hub 5";
    homepage = "https://github.com/ahobsonsayers/bthomehub5-devicelist";
    license = lib.licenses.bsd2;
    maintainers = [ ];
  };
}
