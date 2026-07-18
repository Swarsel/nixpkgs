{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  cython,
  # dependencies
  dedupe-pylbfgs,
  numpy,
  # tests
  pytestCheckHook,
  setuptools,
  unstableGitUpdater,
}:

buildPythonPackage {
  pname = "pyhacrf-datamade";
  # Tagged release requested upstream in https://github.com/dedupeio/pyhacrf/issues/57
  version = "0.2.8-unstable-2025-05-16";

  # NOTE: This is a fork of dirko/pyhacrf maintained by dedupeio
  src = fetchFromGitHub {
    owner = "dedupeio";
    repo = "pyhacrf";
    rev = "899aa6c2c48e5afe8fb40727ffd6070e4ba71c31";
    hash = "sha256-MVkOChDblu7A/ve51SYqO7lNoTXwh37bHjnZd+NvzK0=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  # Change to temp directory so pytest imports from installed package in $out, not source
  preCheck = ''
    export TEST_DIR=$(mktemp -d)
    cp -r pyhacrf/tests $TEST_DIR/
    pushd $TEST_DIR
  '';

  postCheck = ''
    popd
  '';

  build-system = [
    cython
    numpy
    setuptools
  ];

  dependencies = [
    dedupe-pylbfgs
    numpy
  ];

  pyproject = true;

  pythonImportsCheck = [
    "pyhacrf"
  ];

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Hidden alignment conditional random field for classifying string pairs";
    homepage = "https://github.com/dedupeio/pyhacrf";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ daniel-fahey ];
  };
}
