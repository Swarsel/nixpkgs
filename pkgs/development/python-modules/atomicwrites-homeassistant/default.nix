{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools,
}:

let
  pname = "atomicwrites-homeassistant";
  version = "1.4.1";
in

buildPythonPackage {
  inherit pname version;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-JWpnIQbxZ0VEUijZZiQLd7VfRqCW0gMFkBpXql0fTC8=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "atomicwrites" ];

  meta = {
    description = "Atomic file writes";
    homepage = "https://pypi.org/project/atomicwrites-homeassistant/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
