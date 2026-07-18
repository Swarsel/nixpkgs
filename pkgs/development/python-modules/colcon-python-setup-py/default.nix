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
  pname = "colcon-python-setup-py";
  version = "0.2.9";

  src = fetchFromGitHub {
    owner = "colcon";
    repo = "colcon-python-setup-py";
    tag = version;
    hash = "sha256-N+OL0rSoWwZZioMV9JRvrQHdahE3fY7kKjfflUiRVL8=";
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
    "colcon_python_setup_py"
  ];

  meta = {
    description = "Extension for colcon-core to support Python packages with the metadata in the setup.py file";
    homepage = "https://colcon.readthedocs.io/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ guelakais ];
    downloadPage = "https://github.com/colcon/colcon-python-setup-py";
  };
}
