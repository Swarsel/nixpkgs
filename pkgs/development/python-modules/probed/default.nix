{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "probed";
  version = "0.0.11";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-LaTMF1pNbXsbqp/LMT9NTWHYYfNr1Su15AB+UXBwAzw=";
  };

  #- Module has no tests
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "probed" ];

  meta = {
    description = "Module to check data collections";
    homepage = "https://github.com/pyrustic/probed";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
