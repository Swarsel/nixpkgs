{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  deepdiff,
  nibabel,
  numpy,
  psutil,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "trx-python";
  version = "0.3";

  src = fetchFromGitHub {
    owner = "tee-ar-ex";
    repo = "trx-python";
    tag = version;
    hash = "sha256-gKPgP3GJ7QY0Piylk5L0HxnscRCREP1Hm5HZufL2h5g=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    psutil
  ];

  preCheck = ''
    export HOME=$TMPDIR
  '';

  build-system = [
    cython
    setuptools
    setuptools-scm
  ];

  dependencies = [
    deepdiff
    nibabel
    numpy
  ];

  disabledTestPaths = [
    # access to network
    "trx/tests/test_memmap.py"
    "trx/tests/test_io.py"
  ];

  enabledTestPaths = [ "trx/tests" ];
  pyproject = true;
  pythonImportsCheck = [ "trx" ];

  meta = {
    description = "Python implementation of the TRX file format";
    homepage = "https://github.com/tee-ar-ex/trx-python";
    changelog = "https://github.com/tee-ar-ex/trx-python/releases/tag/${version}";
    license = lib.licenses.bsd2;
    maintainers = [ ];
  };
}
