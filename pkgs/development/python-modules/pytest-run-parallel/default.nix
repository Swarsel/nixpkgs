{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # optional-dependencies
  psutil,
  # dependencies
  pytest,
  # tests
  pytest-cov-stub,
  pytest-order,
  pytest-xdist,
  pytestCheckHook,
  # build-system
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pytest-run-parallel";
  version = "0.9.1";

  src = fetchFromGitHub {
    owner = "Quansight-Labs";
    repo = "pytest-run-parallel";
    tag = "v${finalAttrs.version}";
    hash = "sha256-8ndm/CKtWieNF3mx7Ni7nPO4psam3TAM9NJzdiiSpPQ=";
  };

  nativeCheckInputs = [
    pytest-cov-stub
    pytest-order
    pytest-xdist
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  dependencies = [ pytest ];

  optional-dependencies = {
    psutil = [
      psutil
    ];
  };

  pyproject = true;

  pythonImportsCheck = [
    "pytest_run_parallel"
  ];

  meta = {
    description = "Simple pytest plugin to run tests concurrently";
    homepage = "https://github.com/Quansight-Labs/pytest-run-parallel";
    changelog = "https://github.com/Quansight-Labs/pytest-run-parallel/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
})
