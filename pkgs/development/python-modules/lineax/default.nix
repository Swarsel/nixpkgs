{
  lib,
  fetchFromGitHub,
  # tests
  beartype,
  buildPythonPackage,
  # dependencies
  equinox,
  # build-system
  hatchling,
  jax,
  jaxtyping,
  pytest,
  python,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "lineax";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "patrick-kidger";
    repo = "lineax";
    tag = "v${finalAttrs.version}";
    hash = "sha256-qclL/IE/+gLeBL4huy07npXR3sDlbrTlFfib3qVKupk=";
  };

  nativeCheckInputs = [
    beartype
    pytest
  ];

  # Intentionally not using pytest directly as it leads to JAX out-of-memory'ing
  # https://github.com/patrick-kidger/lineax/blob/1909d190c1963d5f2d991508c1b2714f2266048b/tests/README.md
  checkPhase = ''
    runHook preCheck

    ${python.interpreter} -m tests

    runHook postCheck
  '';

  __structuredAttrs = true;
  build-system = [ hatchling ];

  dependencies = [
    equinox
    jax
    jaxtyping
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "lineax" ];

  meta = {
    description = "Linear solvers in JAX and Equinox";
    homepage = "https://github.com/patrick-kidger/lineax";
    changelog = "https://github.com/patrick-kidger/lineax/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
