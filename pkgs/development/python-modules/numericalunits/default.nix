{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  pythonAtLeast,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "numericalunits";
  version = "1.26";

  src = fetchFromGitHub {
    owner = "sbyrnes321";
    repo = "numericalunits";
    tag = "numericalunits-${finalAttrs.version}";
    hash = "sha256-vPB1r+j+p9n+YLnBjHuk2t+QSr+adEOjyC45QSbeb4M=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  # AttributeError: module 'ast' has no attribute 'Num'
  disabled = pythonAtLeast "3.14";

  enabledTestPaths = [
    "tests/tests.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "numericalunits" ];

  meta = {
    description = "Package that lets you define quantities with unit";
    homepage = "http://pypi.org/pypi/numericalunits/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nickcao ];
  };
})
