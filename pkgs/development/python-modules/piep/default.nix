{
  lib,
  buildPythonPackage,
  fetchPypi,
  pygments,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "piep";
  version = "0.10.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-aM7KQJZr1P0Hs2ReyRj2ItGUo+fRJ+TU3lLAU2Mu8KA=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ pygments ];
  pyproject = true;
  pythonImportsCheck = [ "piep" ];

  meta = {
    description = "Bringing the power of python to stream editing";
    homepage = "https://github.com/timbertson/piep";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ timbertson ];
    mainProgram = "piep";
  };
}
