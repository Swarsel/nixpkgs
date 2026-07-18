{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  # tests
  pytestCheckHook,
  # dependencies
  scipy,
  # build-system
  setuptools,
  setuptools-scm,
  torch,
}:

buildPythonPackage (finalAttrs: {
  pname = "linear-operator";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "cornellius-gp";
    repo = "linear_operator";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Ghe4a3zMSvTv3J6ROd1RLELK+k24/rO8p+XUPVsl090=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    scipy
    torch
  ];

  disabledTests = [
    # flaky numerical tests
    "test_matmul_matrix_broadcast"
    "test_solve_matrix_broadcast"
    "test_svd"
  ]
  ++ lib.optionals (stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isAarch64) [
    # RuntimeError: Failed to initialize cpuinfo!
    "test_half"
  ];

  pyproject = true;
  pythonImportsCheck = [ "linear_operator" ];

  meta = {
    description = "LinearOperator implementation to wrap the numerical nuts and bolts of GPyTorch";
    homepage = "https://github.com/cornellius-gp/linear_operator";
    changelog = "https://github.com/cornellius-gp/linear_operator/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ veprbl ];
  };
})
