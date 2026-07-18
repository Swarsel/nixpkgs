{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  colcon,
  packaging,
  pytest-cov-stub,
  # tests
  pytestCheckHook,
  scspell,
  # build-system
  setuptools,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "colcon-devtools";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "colcon";
    repo = "colcon-devtools";
    tag = version;
    hash = "sha256-QBkShQ58QHhYtlKtYaj9/Zs8KMy/Cw55lJHM16uNoxI=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
    scspell
    writableTmpDirAsHomeHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    colcon
    packaging
  ];

  disabledTestPaths = [
    # Skip the linter tests that require additional dependencies
    "test/test_flake8.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "colcon_devtools" ];

  pythonRemoveDeps = [
    # We use pytest-cov-stub instead (and it is not a runtime dependency anyways)
    "pytest-cov"
  ];

  meta = {
    description = "Extension for colcon to provide information about all extension points and extensions";
    homepage = "https://colcon.readthedocs.io/en/released/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ guelakais ];
    downloadPage = "https://github.com/colcon/colcon-devtools";
  };
}
