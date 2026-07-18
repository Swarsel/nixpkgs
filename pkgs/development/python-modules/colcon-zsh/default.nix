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
  pname = "colcon-zsh";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "colcon";
    repo = "colcon-zsh";
    tag = version;
    hash = "sha256-8aXmPxYFeqcLUNO4+md2lyk2/SnVu21HPBRZGrB/HHM=";
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
    "colcon_zsh"
  ];

  meta = {
    description = "Extension for colcon-core to provide Z shell scripts";
    homepage = "http://colcon.readthedocs.io/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ guelakais ];
    downloadPage = "https://github.com/colcon/colcon-zsh#";
  };
}
