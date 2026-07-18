{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  numpy,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyfastnoiselite";
  version = "0.0.7";

  src = fetchFromGitHub {
    owner = "tizilogic";
    repo = "PyFastNoiseLite";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Dyi7FeNnlX3EA8qSylapvZJ4/02ayQC5EBtRY6KBJRA=";
    fetchSubmodules = true;
  };

  # has no tests
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ numpy ];
  pyproject = true;
  pythonImportsCheck = [ "pyfastnoiselite" ];

  meta = {
    description = "Wrapper for Auburns' FastNoise Lite noise generation library";
    homepage = "https://github.com/tizilogic/PyFastNoiseLite";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ SuperSandro2000 ];
  };
})
