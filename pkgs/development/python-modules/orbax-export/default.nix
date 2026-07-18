{
  lib,
  # dependencies
  absl-py,
  buildPythonPackage,
  # tests
  chex,
  dataclasses-json,
  etils,
  fetchPypi,
  flax,
  # build-system
  flit-core,
  jax,
  jaxlib,
  jaxtyping,
  numpy,
  orbax-checkpoint,
  # passthru
  orbax-export,
  protobuf,
  pytestCheckHook,
  tensorflow,
}:

buildPythonPackage (finalAttrs: {
  pname = "orbax-export";
  version = "0.0.8";

  # Tags on the GitHub repo don't match the Pypi releases for orbax-export
  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-VE7vVk4qbxfNEbEWf+vjSLe3z1bZV13plKM9VhPdVoo=";
    pname = "orbax_export";
  };

  # Circular dependency with flax
  doCheck = false;

  nativeCheckInputs = [
    chex
    flax
    pytestCheckHook
  ];

  preCheck = ''
    cd orbax/export
    rm -rf ./**/__init__.py
    rm -rf typing
  '';

  build-system = [
    flit-core
  ];

  dependencies = [
    absl-py
    dataclasses-json
    etils
    jax
    jaxlib
    jaxtyping
    numpy
    orbax-checkpoint
    protobuf
    tensorflow
  ];

  pyproject = true;

  pythonImportsCheck = [
    "orbax"
    "orbax.export"
    "orbax.export.bfloat16_toolkit.python"
  ];

  passthru.tests.pytest = orbax-export.overridePythonAttrs {
    doCheck = true;
  };

  meta = {
    description = "Serialization library for JAX users, enabling the exporting of JAX models to the TensorFlow SavedModel format";
    homepage = "https://github.com/google/orbax/tree/main/export";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
