{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # tests
  cloudpickle,
  equinox,
  # build-system
  hatchling,
  ipython,
  jax,
  jaxlib,
  # passthru
  jaxtyping,
  pytestCheckHook,
  pythonOlder,
  # python <= 3.12 only
  tensorflow,
  torch,
  # dependencies
  wadler-lindig,
}:

buildPythonPackage (finalAttrs: {
  pname = "jaxtyping";
  version = "0.3.11";

  src = fetchFromGitHub {
    owner = "patrick-kidger";
    repo = "jaxtyping";
    tag = "v${finalAttrs.version}";
    hash = "sha256-oC8n4YiV39EjRm8vYDFrUVJmEPeH814q7uIKdmpqnJk=";
  };

  doCheck = false;

  nativeCheckInputs = [
    cloudpickle
    equinox
    ipython
    jax
    jaxlib
    pytestCheckHook
    torch
  ]
  ++ lib.optionals (pythonOlder "3.13") [
    tensorflow
  ];

  __structuredAttrs = true;
  build-system = [ hatchling ];

  dependencies = [
    wadler-lindig
  ];

  pyproject = true;
  pythonImportsCheck = [ "jaxtyping" ];

  # Enable tests via passthru to avoid cyclic dependency with equinox.
  passthru.tests = {
    check = jaxtyping.overridePythonAttrs {
      # We disable tests because they complain about the version of typeguard being too new.
      doCheck = false;
      catchConflicts = false;
    };
  };

  meta = {
    description = "Type annotations and runtime checking for JAX arrays and PyTrees";
    homepage = "https://github.com/patrick-kidger/jaxtyping";
    changelog = "https://github.com/patrick-kidger/jaxtyping/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
