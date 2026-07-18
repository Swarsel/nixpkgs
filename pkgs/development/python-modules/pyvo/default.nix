{
  lib,
  astropy,
  buildPythonPackage,
  fetchPypi,
  pillow,
  pytest-astropy,
  pytestCheckHook,
  requests,
  requests-mock,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyvo";
  version = "1.8.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-08xgqj00FtIsieRloE36n1IQhf3VIozOLP/S/uOp5wk=";
  };

  nativeCheckInputs = [
    pillow
    pytestCheckHook
    pytest-astropy
    requests-mock
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    astropy
    requests
  ];

  disabledTestPaths = [
    # touches network
    "pyvo/dal/tests/test_datalink.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyvo" ];

  meta = {
    description = "Astropy affiliated package for accessing Virtual Observatory data and services";
    homepage = "https://github.com/astropy/pyvo";
    changelog = "https://github.com/astropy/pyvo/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ smaret ];
  };
})
