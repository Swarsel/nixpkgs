{
  lib,
  buildPythonPackage,
  fetchPypi,
  nulltype,
  python-dateutil,
  setuptools,
  urllib3,
}:

buildPythonPackage (finalAttrs: {
  pname = "plaid-python";
  version = "40.1.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-y5EmVNyPLQGBPGF45Yny1fIT92daC9tlOhTBcnxFkqY=";
    pname = "plaid_python";
  };

  # Tests require a Client IP
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    nulltype
    python-dateutil
    urllib3
  ];

  pyproject = true;
  pythonImportsCheck = [ "plaid" ];

  meta = {
    description = "Python client library for the Plaid API and Link";
    homepage = "https://github.com/plaid/plaid-python";
    changelog = "https://github.com/plaid/plaid-python/blob/master/CHANGELOG.md";
    license = lib.licenses.mit;
  };
})
