{
  lib,
  buildPythonPackage,
  fetchPypi,
  matplotlib,
  numpy,
  scipy,
  setuptools,
  unittestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "baycomp";
  version = "1.0.3";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-MrJa17FtWyUd259hEKMtezlTuYcJbaHSXvJ3k10l2uw=";
  };

  nativeCheckInputs = [ unittestCheckHook ];
  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    numpy
    scipy
    matplotlib
  ];

  pyproject = true;
  pythonImportsCheck = [ "baycomp" ];

  meta = {
    description = "Library for Bayesian comparison of classifiers";
    homepage = "https://github.com/janezd/baycomp";
    license = [ lib.licenses.mit ];
    maintainers = [ ];
  };
})
