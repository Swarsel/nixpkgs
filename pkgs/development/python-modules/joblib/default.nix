{
  lib,
  stdenv,
  buildPythonPackage,
  fetchPypi,
  # propagates (optional, but unspecified)
  # https://github.com/joblib/joblib#dependencies
  lz4,
  psutil,
  # tests
  pytestCheckHook,
  pythonAtLeast,
  # build-system
  setuptools,
  threadpoolctl,
}:

buildPythonPackage rec {
  pname = "joblib";
  version = "1.5.3";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-hWGjJp5oARBoY/0NbYS7c3vp52MeM6rtP7nOWVNojaM=";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    lz4
    psutil
  ];

  nativeCheckInputs = [
    pytestCheckHook
    threadpoolctl
  ];

  disabledTests = [
    "test_disk_used" # test_disk_used is broken: https://github.com/joblib/joblib/issues/57
    "test_parallel_call_cached_function_defined_in_jupyter" # jupyter not available during tests
    "test_nested_parallel_warnings" # tests is flaky under load
    "test_memory" # tests - and the module itself - assume strictatime mount for build directory
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    "test_dispatch_multiprocessing" # test_dispatch_multiprocessing is broken only on Darwin.
  ];

  enabledTestPaths = [ "joblib/test" ];
  pyproject = true;

  meta = {
    description = "Lightweight pipelining: using Python functions as pipeline jobs";
    homepage = "https://joblib.readthedocs.io/";
    changelog = "https://github.com/joblib/joblib/releases/tag/${version}";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
