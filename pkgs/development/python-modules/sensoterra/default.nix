{
  lib,
  buildPythonPackage,
  fetchPypi,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "sensoterra";
  version = "2.0.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-WfjTOns5OPU8+ufDeFdDGjURhBWUFfw/qRSHQazBL04=";
  };

  # Test require network access
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ requests ];
  pyproject = true;
  pythonImportsCheck = [ "sensoterra" ];

  meta = {
    description = "Query Sensoterra probes using the Customer API";
    homepage = "https://gitlab.com/sensoterra/public/python";
    changelog = "https://gitlab.com/sensoterra/public/python/-/blob/main/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
