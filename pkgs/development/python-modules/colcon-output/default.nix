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
  pname = "colcon-output";
  version = "0.2.14";

  src = fetchFromGitHub {
    owner = "colcon";
    repo = "colcon-output";
    tag = version;
    hash = "sha256-Zt8ZG2SZAgS1iXMnu3b2dSoP9IzrwLwMUXVSJWqRV9w=";
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
    "colcon_output"
  ];

  meta = {
    description = "Extension for colcon-core to customize the output in various ways";
    homepage = "http://colcon.readthedocs.io/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ guelakais ];
    downloadPage = "https://github.com/colcon/colcon-output";
  };
}
