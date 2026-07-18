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
  pname = "colcon-mixin";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "colcon";
    repo = "colcon-mixin";
    tag = version;
    hash = "sha256-XQpRDBTtrFOOlCRXKVImUtwrwirO0ELWifUpfQuyrrY=";
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
    "colcon_mixin"
  ];

  meta = {
    description = "Extension for colcon-core to provide mixin functionality";
    homepage = "https://github.com/colcon/colcon-mixin";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ guelakais ];
  };
}
