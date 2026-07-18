{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "pytest-archon";
  version = "0.0.7";

  src = fetchFromGitHub {
    owner = "jwbargsten";
    repo = "pytest-archon";
    tag = "v${version}";
    hash = "sha256-0YBujBUBpW/FSIlJDRjL5mvYZfirHW07bRyygyoapw8=";
  };

  buildInputs = [
    pytest
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  pyproject = true;
  pythonImportsCheck = [ "pytest_archon" ];

  meta = {
    description = "Tool that helps you structure (large) Python projects";
    homepage = "https://github.com/jwbargsten/pytest-archon";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
