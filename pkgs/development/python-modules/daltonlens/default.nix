{
  lib,
  buildPythonPackage,
  fetchPypi,
  numpy,
  pillow,
  pytestCheckHook,
  setuptools,
}:
buildPythonPackage rec {
  pname = "daltonlens";
  version = "0.1.5";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-T7fXlRdFtcVw5WURPqZhCmulUi1ZnCfCXgcLtTHeNas=";
  };

  postPatch = ''
    substituteInPlace setup.cfg \
      --replace-fail "setup_requires = setuptools_git" ""
  '';

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    numpy
    pillow
  ];

  disabledTestPaths = [
    "tests/test_generate.py"
  ];

  enabledTestPaths = [
    "tests/"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "daltonlens"
  ];

  meta = {
    description = "R&D companion package for the desktop application DaltonLens";
    homepage = "https://github.com/DaltonLens/DaltonLens-Python";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ aleksana ];
  };
}
