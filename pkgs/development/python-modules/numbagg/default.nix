{
  lib,
  fetchFromGitHub,
  bottleneck,
  buildPythonPackage,
  hypothesis,
  # dependencies
  numba,
  numpy,
  pandas,
  pytest-benchmark,
  # tests
  pytestCheckHook,
  # build-system
  setuptools,
  setuptools-scm,
  tabulate,
}:

buildPythonPackage rec {
  pname = "numbagg";
  version = "0.9.4";

  src = fetchFromGitHub {
    owner = "numbagg";
    repo = "numbagg";
    tag = "v${version}";
    hash = "sha256-JYgjeExpL+rbiaFPO9IHsm4Qh6GTLdTWB5dO3zIIPbs=";
  };

  nativeCheckInputs = [
    pytestCheckHook

    pandas
    bottleneck
    hypothesis
    tabulate
    pytest-benchmark
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    numpy
    numba
  ];

  disabledTests = [
    # Uses outdated pandas API as an oracle
    "nanargmin"
    "nanargmax"
  ];

  pyproject = true;
  pytestFlags = [ "--benchmark-disable" ];
  pythonImportsCheck = [ "numbagg" ];

  meta = {
    description = "Fast N-dimensional aggregation functions with Numba";
    homepage = "https://github.com/numbagg/numbagg";
    changelog = "https://github.com/numbagg/numbagg/releases/tag/v${version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ flokli ];
  };
}
