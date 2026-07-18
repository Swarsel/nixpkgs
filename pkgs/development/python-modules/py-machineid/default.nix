{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "py-machineid";
  version = "1.0.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-ipAqAProxtZDP0Y2l8IdxM6YxuVaLgU1wCczGaywBHo=";
    pname = "py_machineid";
  };

  # Tests are not present in Pypi archive
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "machineid" ];

  meta = {
    description = "Get the unique machine ID of any host (without admin privileges)";
    homepage = "https://github.com/keygen-sh/py-machineid";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
}
