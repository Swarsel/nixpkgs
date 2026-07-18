{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  # checks
  chex,
  # dependencies
  jax,
  # optional-dependencies
  jax-tap,
  jaxlib,
  numpy,
  optax,
  pytest-xdist,
  pytestCheckHook,
  scipy,
  # build-system
  setuptools,
  setuptools-scm,
  tqdm,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "blackjax";
  version = "1.6";

  src = fetchFromGitHub {
    owner = "blackjax-devs";
    repo = "blackjax";
    tag = finalAttrs.version;
    hash = "sha256-qLOAmUQxr1xtlJB/TMnjFkvvHUwh0XKpPN+FVD8ju8Y=";
  };

  nativeCheckInputs = [
    chex
    pytestCheckHook
    pytest-xdist
  ]
  ++ finalAttrs.passthru.optional-dependencies.progress;

  __structuredAttrs = true;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    jax
    jaxlib
    numpy
    optax
    scipy
    typing-extensions
  ];

  disabledTestPaths = [
    "tests/test_benchmarks.py"

    # Assertion errors on numerical values
    "tests/mcmc/test_integrators.py"
  ];

  disabledTests = [
    # too slow
    "test_adaptive_tempered_smc"

    # AssertionError on numerical values
    "test_barker"
    "test_imm_shrinkage_seed_influence_persists_diagonal"
    "test_laps"
    "test_mclmc"
    "test_mcse4"
    "test_mean_and_std"
    "test_normal_univariate"
    "test_nuts__with_device"
    "test_nuts__with_jit"
    "test_nuts__without_device"
    "test_nuts__without_jit"
    "test_smc__with_jit"
    "test_smc_waste_free__with_jit"
  ]
  ++ lib.optionals (stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isAarch64) [
    # AssertionError: Not equal to tolerance rtol=1e-07, atol=1e-05
    "test_equal_matrices"
  ];

  optional-dependencies = {
    progress = [
      jax-tap
      tqdm
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "blackjax" ];

  meta = {
    description = "Sampling library designed for ease of use, speed and modularity";
    homepage = "https://blackjax-devs.github.io/blackjax";
    changelog = "https://github.com/blackjax-devs/blackjax/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ bcdarwin ];
  };
})
