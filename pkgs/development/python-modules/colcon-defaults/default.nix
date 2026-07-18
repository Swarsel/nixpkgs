{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  #dependencies
  colcon,
  pyaml,
  pytest-cov-stub,
  pytest-repeat,
  pytest-rerunfailures,
  # tests
  pytestCheckHook,
  scspell,
  # build-system
  setuptools,
  writableTmpDirAsHomeHook,
}:
buildPythonPackage rec {
  pname = "colcon-defaults";
  version = "0.2.9";

  src = fetchFromGitHub {
    owner = "colcon";
    repo = "colcon-defaults";
    tag = version;
    hash = "sha256-Nb6D9jpbCvUnCNgRLBgWQFybNx0hyWVLSKj6gmTWjVs=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
    pytest-repeat
    pytest-rerunfailures
    scspell
    writableTmpDirAsHomeHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    colcon
    pyaml
  ];

  disabledTestPaths = [
    # Skip formatting checks to prevent depending on flake8
    "test/test_flake8.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "colcon_defaults" ];

  meta = {
    description = "Extension for colcon to read defaults from a config file";
    homepage = "https://github.com/colcon/colcon-defaults";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ guelakais ];
  };
}
