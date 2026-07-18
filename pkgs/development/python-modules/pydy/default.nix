{
  lib,
  buildPythonPackage,
  cython,
  fetchPypi,
  nix-update-script,
  numpy,
  pytestCheckHook,
  scipy,
  setuptools,
  sympy,
}:

buildPythonPackage (finalAttrs: {
  pname = "pydy";
  version = "0.8.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-G3iqMzy/W3ctz/c4T3LqYyTTMVbly1GMkmMLi96mzMc=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    cython
  ];

  build-system = [ setuptools ];

  dependencies = [
    numpy
    scipy
    sympy
  ];

  pyproject = true;
  pythonImportsCheck = [ "pydy" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Python tool kit for multi-body dynamics";
    homepage = "http://pydy.org";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ sigmanificient ];
  };
})
