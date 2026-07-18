{
  lib,
  buildPythonPackage,
  fetchPypi,
  pyserial,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pykwb";
  version = "0.0.21";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-53or6KOjZujOIq9yZ30Ph704I8T93AX/EoJZeVS3ihI=";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ pyserial ];
  pyproject = true;
  pythonImportsCheck = [ "pykwb" ];

  meta = {
    description = "Library for interacting with KWB Easyfire Pellet Central Heating Units";
    homepage = "https://github.com/bimbar/pykwb";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
