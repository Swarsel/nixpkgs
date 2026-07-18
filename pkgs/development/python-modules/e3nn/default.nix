{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  llvmPackages,
  # dependencies
  opt-einsum-fx,
  # tests
  pytestCheckHook,
  scipy,
  # build-system
  setuptools,
  setuptools-scm,
  sympy,
  torch,
}:

buildPythonPackage (finalAttrs: {
  pname = "e3nn";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "e3nn";
    repo = "e3nn";
    tag = finalAttrs.version;
    hash = "sha256-gGl0DiLU8w0jqGWA/ZzvkxdZdZCvtXqtmEEZ2dIwZ2o=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  __structuredAttrs = true;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    opt-einsum-fx
    scipy
    sympy
    torch
  ];

  disabledTests = [
    # RuntimeError: torch.compile does not support compiling torch.jit.script or
    # torch.jit.freeze models directly
    "test_identity"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # symbol not found in flat namespace '___kmpc_barrier'
    "test_activation"
    "test_input_weights_jit"
    "test_variance"
  ];

  pyproject = true;
  pythonImportsCheck = [ "e3nn" ];

  meta = {
    description = "Modular framework for neural networks with Euclidean symmetry";
    homepage = "https://github.com/e3nn/e3nn";
    changelog = "https://github.com/e3nn/e3nn/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
