{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "ecpy";
  version = "1.2.5";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-ljXP+5tuz3/X9yrqFmWCmsdKHScgBtAFfUWmIariAig=";
    pname = "ECPy";
  };

  # No tests implemented
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "ecpy" ];

  meta = {
    description = "Pure Python Elliptic Curve Library";
    homepage = "https://github.com/ubinity/ECPy";
    changelog = "https://github.com/cslashm/ECPy/releases/tag/${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
})
