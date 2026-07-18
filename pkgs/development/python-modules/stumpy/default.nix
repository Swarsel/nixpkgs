{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # tests
  dask,
  distributed,
  # dependencies
  numba,
  numpy,
  pandas,
  pytestCheckHook,
  scipy,
  # build-system
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "stumpy";
  version = "1.14.1";

  src = fetchFromGitHub {
    owner = "TDAmeritrade";
    repo = "stumpy";
    tag = "v${version}";
    hash = "sha256-wBOOYN9UVjc+++lYzgL2+ZqyhLTZOpd5baxYRi2HFJA=";
  };

  nativeCheckInputs = [
    dask
    distributed
    pandas
    pytestCheckHook
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    numba
    numpy
    scipy
  ];

  enabledTestPaths = [
    # whole testsuite is very CPU intensive, only run core tests
    # TODO: move entire test suite to passthru.tests
    "tests/test_core.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "stumpy" ];

  meta = {
    description = "Library that can be used for a variety of time series data mining tasks";
    homepage = "https://github.com/TDAmeritrade/stumpy";
    changelog = "https://github.com/TDAmeritrade/stumpy/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = [ ];

    badPlatforms = [
      # Multiple tests fail with:
      # Segmentation fault (core dumped)
      "aarch64-linux"
    ];
  };
}
