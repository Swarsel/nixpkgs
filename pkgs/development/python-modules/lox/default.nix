{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pathos,
  pytest-mock,
  pytestCheckHook,
  setuptools,
  tqdm,
}:

buildPythonPackage rec {
  pname = "lox";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "BrianPugh";
    repo = "lox";
    tag = "v${version}";
    hash = "sha256-PZKs+D1TmrBr+1M4ni7kKLywQ8Z6YCVjH2HFF6QjHdY=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-mock
    tqdm
  ];

  build-system = [ setuptools ];
  dependencies = [ pathos ];

  disabledTests = [
    # Benchmark, performance testing
    "test_perf_lock"
    "test_perf_qlock"

    # time sensitive testing
    "test_bathroom_example"
    "test_RWLock_r"
  ];

  pyproject = true;
  pythonImportsCheck = [ "lox" ];

  meta = {
    description = "Threading and Multiprocessing made easy";
    homepage = "https://github.com/BrianPugh/lox";
    changelog = "https://github.com/BrianPugh/lox/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.greg ];
  };
}
