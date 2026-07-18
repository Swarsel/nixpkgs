{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  distlib,
  empy,
  packaging,
  pytest-cov-stub,
  pytest-repeat,
  pytest-rerunfailures,
  # tests
  pytestCheckHook,
  python-dateutil,
  pyyaml,
  scspell,
  # build-system
  setuptools,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "colcon-core";
  version = "0.21.0";

  src = fetchFromGitHub {
    owner = "colcon";
    repo = "colcon-core";
    tag = version;
    hash = "sha256-yERPJD2LYmBrLchyX/axQ+8h5/hRXsjvzF3DkR8CsCs=";
  };

  # Upstream tracking issue: https://github.com/ros2/ros2/issues/1738
  # This will break some functionality of building setuptools packages using colcon, other package types should work fine
  patches = [ ./0001-update-setuptools.patch ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
    pytest-repeat
    pytest-rerunfailures
    scspell
    writableTmpDirAsHomeHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    empy
    distlib
    packaging
    python-dateutil
    pyyaml
  ];

  disabledTestPaths = [
    # Skip the linter tests that require additional dependencies
    "test/test_flake8.py"
    # Skip failing Python build tests
    "test/test_build_python.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "colcon_core" ];

  pythonRemoveDeps = [
    # We use pytest-cov-stub instead (and it is not a runtime dependency anyways)
    "pytest-cov"
    # Upper bound on setuptools is too strict for nixpkgs
    "setuptools"
  ];

  meta = {
    description = "Command line tool to build sets of software packages";
    homepage = "https://github.com/colcon/colcon-core";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      amronos
      guelakais
    ];

    mainProgram = "colcon";
  };
}
