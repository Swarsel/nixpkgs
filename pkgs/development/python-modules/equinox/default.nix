{
  lib,
  fetchFromGitHub,
  # tests
  beartype,
  buildPythonPackage,
  # build-system
  hatchling,
  # dependencies
  jax,
  jaxtyping,
  optax,
  pytest-xdist,
  pytestCheckHook,
  typing-extensions,
  wadler-lindig,
}:

buildPythonPackage (finalAttrs: {
  pname = "equinox";
  version = "0.13.8";

  src = fetchFromGitHub {
    owner = "patrick-kidger";
    repo = "equinox";
    tag = "v${finalAttrs.version}";
    hash = "sha256-JiIZKWuSkvrF09GdmegUeTyidaM5IRp4uqjJRsn86E4=";
  };

  # Relax speed constraints on tests that can fail on busy builders
  postPatch = ''
    substituteInPlace tests/test_while_loop.py \
      --replace-fail "speed < 0.1" "speed < 0.5" \
      --replace-fail "speed < 0.5" "speed < 1" \
      --replace-fail "speed < 1" "speed < 20" \
      --replace-fail "speed < 2" "speed < 20"
  '';

  nativeCheckInputs = [
    beartype
    optax
    pytest-xdist
    pytestCheckHook
  ];

  __structuredAttrs = true;
  build-system = [ hatchling ];

  dependencies = [
    jax
    jaxtyping
    typing-extensions
    wadler-lindig
  ];

  disabledTests = [
    # Flaky under heavy load:
    #   AssertionError: Non-linear scaling detected: ratio=1.56
    "test_speed_buffer_while"
  ];

  pyproject = true;
  pythonImportsCheck = [ "equinox" ];

  meta = {
    description = "JAX library based around a simple idea: represent parameterised functions (such as neural networks) as PyTrees";
    homepage = "https://github.com/patrick-kidger/equinox";
    changelog = "https://github.com/patrick-kidger/equinox/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
