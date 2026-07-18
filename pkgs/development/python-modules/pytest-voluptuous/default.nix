{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
  six,
  voluptuous,
}:

buildPythonPackage rec {
  pname = "pytest-voluptuous";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "F-Secure";
    repo = "pytest-voluptuous";
    tag = version;
    hash = "sha256-xdj4qCSSJQI9Rb1WyUYrAg1I5wQ5o6IJyIjJAafP/LY=";
  };

  buildInputs = [ pytest ];

  nativeCheckInputs = [
    pytestCheckHook
    six
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [ voluptuous ];
  enabledTestPaths = [ "tests/test_plugin.py" ];
  pyproject = true;
  pythonImportsCheck = [ "pytest_voluptuous" ];

  meta = {
    description = "Pytest plugin for asserting data against voluptuous schema";
    homepage = "https://github.com/F-Secure/pytest-voluptuous";
    changelog = "https://github.com/F-Secure/pytest-voluptuous/blob/${version}/CHANGELOG.rst";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}
