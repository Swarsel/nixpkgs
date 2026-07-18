{
  lib,
  fetchFromGitHub,
  build,
  buildPythonPackage,
  callPackage,
  coloredlogs,
  homf,
  packaging,
  pip,
  pydantic,
  pytestCheckHook,
  setuptools,
  urllib3,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "bork";
  version = "11.0.0";

  src = fetchFromGitHub {
    owner = "duckinator";
    repo = "bork";
    tag = "v${version}";
    hash = "sha256-VashMByAdoRa/uWBGgtsJtd4LcG8hwq/naDXxW+nSg8=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    build
    coloredlogs
    homf
    packaging
    pip
    pydantic
    urllib3
  ];

  disabledTestMarks = [ "network" ];

  disabledTests = [
    # tries to call python -m bork
    "test_repo"
    # Attempt to install packages via pip
    "test_builder_cwd"
    "test_builder_order"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "bork"
    "bork.api"
    "bork.cli"
  ];

  pythonRelaxDeps = [
    "build"
    "packaging"
    "urllib3"
  ];

  passthru.tests = callPackage ./tests.nix { };

  meta = {
    description = "Python build and release management tool";
    homepage = "https://github.com/duckinator/bork";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nicoo ];
    mainProgram = "bork";
  };
}
