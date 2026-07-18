{
  lib,
  buildPythonPackage,
  cogapp,
  fetchPypi,
  mock,
  pytestCheckHook,
  setuptools,
  six,
  virtualenv,
}:

buildPythonPackage rec {
  pname = "paver";
  version = "1.3.4";

  src = fetchPypi {
    inherit version;
    hash = "sha256-0+ZJiIFIWrdQ7+QMUniYKpNDvGJ+E3sRrc7WJ3GTCMc=";
    pname = "Paver";
  };

  checkInputs = [
    cogapp
    mock
    pytestCheckHook
    virtualenv
  ];

  build-system = [ setuptools ];
  dependencies = [ six ];

  disabledTestPaths = [
    # Tests depend on distutils
    "paver/tests/test_setuputils.py"
    "paver/tests/test_doctools.py"
    "paver/tests/test_tasks.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "paver" ];

  meta = {
    description = "Python-based build/distribution/deployment scripting tool";
    homepage = "https://github.com/paver/paver";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    mainProgram = "paver";
  };
}
