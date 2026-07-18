{
  lib,
  fetchFromGitHub,
  # dependencies
  absl-py,
  buildPythonPackage,
  # tests
  cloudpickle,
  dm-tree,
  # build-system
  flit-core,
  jax,
  jaxlib,
  numpy,
  pytestCheckHook,
  toolz,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "chex";
  version = "0.1.92";

  src = fetchFromGitHub {
    owner = "google-deepmind";
    repo = "chex";
    tag = "v${finalAttrs.version}";
    hash = "sha256-PM76Q72Bgyms7dROJkmlpPuDvtqjHLPTDkUYqo08T74=";
  };

  nativeCheckInputs = [
    cloudpickle
    dm-tree
    pytestCheckHook
  ];

  __structuredAttrs = true;

  build-system = [
    flit-core
  ];

  dependencies = [
    absl-py
    jax
    jaxlib
    numpy
    toolz
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "chex" ];

  meta = {
    description = "Library of utilities for helping to write reliable JAX code";
    homepage = "https://github.com/google-deepmind/chex";
    changelog = "https://github.com/google-deepmind/chex/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ndl ];
  };
})
