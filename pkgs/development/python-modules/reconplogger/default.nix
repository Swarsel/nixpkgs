{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flask,
  logmatic-python,
  pytestCheckHook,
  pyyaml,
  requests,
  setuptools,
  testfixtures,
}:

buildPythonPackage (finalAttrs: {
  pname = "reconplogger";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "omni-us";
    repo = "reconplogger";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/+nPLji8iGTBpWTCR83JRfxMltMYjP62KrB+HRTQQE8=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    testfixtures
  ];

  build-system = [ setuptools ];

  dependencies = [
    logmatic-python
    pyyaml
  ];

  enabledTestPaths = [ "reconplogger_tests.py" ];

  optional-dependencies = {
    all = [
      flask
      requests
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "reconplogger" ];

  meta = {
    description = "Module to ease the standardization of logging within omni:us";
    homepage = "https://github.com/omni-us/reconplogger";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
