{
  lib,
  fetchFromGitHub,
  # dependencies
  absl-py,
  buildPythonPackage,
  # tests
  callPackage,
  # build-system
  flit-core,
  jax,
  jaxlib,
  numpy,
}:

buildPythonPackage (finalAttrs: {
  pname = "optax";
  version = "0.2.8";

  src = fetchFromGitHub {
    owner = "deepmind";
    repo = "optax";
    tag = "v${finalAttrs.version}";
    hash = "sha256-dVmMacQx6V5lv0z4nWUTlekuEDqtIZlxJazAeA9UR+E=";
  };

  outputs = [
    "out"
    "testsout"
  ];

  # check in passthru.tests.pytest to escape infinite recursion with flax
  doCheck = false;

  postInstall = ''
    mkdir $testsout
    cp -R examples $testsout/examples
  '';

  build-system = [ flit-core ];

  dependencies = [
    absl-py
    jax
    jaxlib
    numpy
  ];

  pyproject = true;
  pythonImportsCheck = [ "optax" ];

  passthru.tests = {
    pytest = callPackage ./tests.nix { };
  };

  meta = {
    description = "Gradient processing and optimization library for JAX";
    homepage = "https://github.com/deepmind/optax";
    changelog = "https://github.com/deepmind/optax/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ndl ];
  };
})
