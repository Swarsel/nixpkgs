{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest,
  pytestCheckHook,
  setuptools-scm,
  setuptools_80,
}:

buildPythonPackage rec {
  pname = "pytest-logdog";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "ods";
    repo = "pytest-logdog";
    rev = version;
    hash = "sha256-Tmoq+KAGzn0MMj29rukDfAc4LSIwC8DoMTuBAppV32I=";
  };

  buildInputs = [ pytest ];
  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools_80
    setuptools-scm
  ];

  pyproject = true;
  pythonImportsCheck = [ "pytest_logdog" ];

  meta = {
    description = "Pytest plugin to test logging";
    homepage = "https://github.com/ods/pytest-logdog";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
