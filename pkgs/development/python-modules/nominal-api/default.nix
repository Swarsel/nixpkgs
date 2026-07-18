{
  lib,
  buildPythonPackage,
  conjure-python-client,
  fetchPypi,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "nominal-api";
  version = "0.1073.0";

  # nixpkgs-update: no auto update
  src = fetchPypi {
    inherit version;
    hash = "sha256-jumMX6YjQlmipCgaPPeG73OemP94otHvUUL2kq+QEQ4=";
    pname = "nominal_api";
  };

  build-system = [ setuptools ];

  dependencies = [
    requests
    conjure-python-client
  ];

  pyproject = true;
  pythonImportsCheck = [ "nominal_api" ];

  meta = {
    description = "Generated conjure client for the Nominal API";
    homepage = "https://pypi.org/project/nominal-api/";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ alkasm ];
  };
}
