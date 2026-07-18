{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "circuit-webhook";
  version = "1.0.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-NhePKBfzdkw7iVHmVrOxf8ZcQrb1Sq2xMIfu4P9+Ppw=";
  };

  # Module has no tests
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "circuit_webhook" ];

  meta = {
    description = "Module for Unify Circuit API webhooks";
    homepage = "https://github.com/braam/unify/tree/master/circuit-webhook-python";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
