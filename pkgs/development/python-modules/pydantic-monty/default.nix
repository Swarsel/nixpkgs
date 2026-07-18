{
  lib,
  fetchFromGitHub,
  anyio,
  buildPythonPackage,
  dirty-equals,
  inline-snapshot,
  pytest-examples,
  pytest-pretty,
  pytestCheckHook,
  rustPlatform,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "pydantic-monty";
  version = "0.0.17";

  src = fetchFromGitHub {
    owner = "pydantic";
    repo = "monty";
    tag = "v${finalAttrs.version}";
    hash = "sha256-f+WcznnOMSc0ahgfvgVec4U0nH9j022NLnWQLdISv3M=";
  };

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  nativeCheckInputs = [
    anyio
    dirty-equals
    inline-snapshot
    pytest-examples
    pytest-pretty
    pytestCheckHook
  ];

  __structuredAttrs = true;

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname src version;
    hash = "sha256-y+vi7kZPavBNnIeLpAoKO2YcBTq2d9yeDl+eoRJV1Tk=";
  };

  dependencies = [ typing-extensions ];

  disabledTests = [
    # These tests fails because they expect to have multiple cores
    # to produce a predicted speedup measurement, which we cannot
    # achieve in the sandbox.
    "test_parallel_exec"
  ];

  maturinBuildFlags = [
    "-m"
    "crates/monty-python/Cargo.toml"
  ];

  pyproject = true;

  pytestFlags = [
    "--config-file"
    "crates/monty-python/pyproject.toml"
  ];

  pythonImportsCheck = [ "pydantic_monty" ];

  meta = {
    description = "Minimal, secure Python interpreter written in Rust for use by AI";
    homepage = "https://github.com/pydantic/monty";
    changelog = "https://github.com/pydantic/monty/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ squat ];
  };
})
