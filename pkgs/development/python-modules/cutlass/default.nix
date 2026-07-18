{
  lib,
  buildPythonPackage,
  fetchPypi,
  # optional-dependencies
  matplotlib,
  # dependencies
  numpy,
  pandas,
  # tests
  pytestCheckHook,
  # build-system
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "cutlass";
  version = "0.5.0";

  # No tags on GitHub
  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-dAxt/1EROwJix/Sz889XJ9MXfN1FBFQYSNeB3H43g7E=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  __structuredAttrs = true;

  build-system = [
    setuptools
  ];

  dependencies = [
    numpy
    pandas
  ];

  optional-dependencies = {
    plots = [
      matplotlib
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "cutlass" ];

  meta = {
    description = "Rectified L1 logistic regression with CUTLASS critical range encoding";
    homepage = "https://github.com/jworender/cutlass";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
