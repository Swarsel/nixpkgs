{
  lib,
  fetchFromGitHub,
  # dependencies
  absl-py,
  buildPythonPackage,
  # tests
  chex,
  etils,
  flax,
  jax,
  jaxlib,
  keras,
  ml-collections,
  numpy,
  packaging,
  pytestCheckHook,
  # build-system
  setuptools,
  tensorflow,
  tensorflow-datasets,
  torch,
  typing-extensions,
  wrapt,
}:

buildPythonPackage (finalAttrs: {
  pname = "clu";
  version = "0.0.12";

  src = fetchFromGitHub {
    owner = "google";
    repo = "CommonLoopUtils";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ntqRz3fCXMf0EDQsddT68Mdi105ECBVQpVsStzk2kvQ=";
  };

  # Fix Jax 0.10.0 compatibility
  # TypeError: clip() got an unexpected keyword argument 'a_min'
  postPatch = ''
    substituteInPlace clu/metrics.py \
      --replace-fail \
        "variance = jnp.clip(variance, a_min=0.0)" \
        "variance = jnp.clip(variance, min=0.0)"
  '';

  nativeCheckInputs = [
    chex
    keras
    pytestCheckHook
    tensorflow
    tensorflow-datasets
    torch
  ];

  __structuredAttrs = true;

  build-system = [
    setuptools
  ];

  dependencies = [
    absl-py
    etils
    flax
    jax
    jaxlib
    ml-collections
    numpy
    packaging
    typing-extensions
    wrapt
  ]
  ++ etils.optional-dependencies.epath;

  disabledTests = [
    # AssertionError: [Chex] Assertion assert_trees_all_close failed
    "test_collection_mixed_async"
    # flaky under load
    "test_async_execution"
  ];

  pyproject = true;
  pythonImportsCheck = [ "clu" ];

  meta = {
    description = "Common training loops in JAX";
    homepage = "https://github.com/google/CommonLoopUtils";
    changelog = "https://github.com/google/CommonLoopUtils/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
