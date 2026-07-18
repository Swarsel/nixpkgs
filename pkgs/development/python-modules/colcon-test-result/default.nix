{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  colcon,
  pytest-cov-stub,
  pytestCheckHook,
  scspell,
  setuptools,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "colcon-test-result";
  version = "0.3.8";

  src = fetchFromGitHub {
    owner = "colcon";
    repo = "colcon-test-result";
    rev = version;
    hash = "sha256-4t2jGJlwm8ZQkOG+Q2KyZ9Qnhhy5PAHcxxo7lkqSDRA=";
  };

  nativeCheckInputs = [
    pytest-cov-stub
    pytestCheckHook
    scspell
    writableTmpDirAsHomeHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    colcon
  ];

  disabledTestPaths = [
    "test/test_flake8.py"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "colcon_test_result"
  ];

  meta = {
    description = "Extension for colcon to provide test result handling";
    homepage = "https://github.com/colcon/colcon-test-result";
    changelog = "https://github.com/colcon/colcon-test-result/blob/${version}/CHANGELOG.rst";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ guelakais ];
  };
}
