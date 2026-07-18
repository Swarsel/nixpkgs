{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # nativeBuildInputs
  cargo,
  # optional-dependencies
  datasets,
  # dependencies
  interegular,
  jsonschema,
  numpy,
  # buildInputs
  openssl,
  pkg-config,
  pydantic,
  # tests
  pytestCheckHook,
  rustPlatform,
  rustc,
  scipy,
  # build-system
  setuptools-rust,
  setuptools-scm,
  torch,
  transformers,
}:

buildPythonPackage (finalAttrs: {
  pname = "outlines-core";
  version = "0.2.14";

  src = fetchFromGitHub {
    owner = "dottxt-ai";
    repo = "outlines-core";
    tag = finalAttrs.version;
    hash = "sha256-XmXD2tWG2277bC318Bn9RqeEE7j9VdauvWnBmFS8Lsk=";
  };

  postPatch = ''
    substituteInPlace Cargo.toml \
      --replace-fail \
        'version = "0.0.0"' \
        'version = "${finalAttrs.version}"'

    cp --no-preserve=mode ${./Cargo.lock} Cargo.lock
  '';

  nativeBuildInputs = [
    cargo
    pkg-config
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
    rustc
  ];

  buildInputs = [
    openssl
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ]
  ++ lib.concatAttrValues finalAttrs.passthru.optional-dependencies;

  preCheck = ''
    rm -rf outlines_core
  '';

  build-system = [
    setuptools-rust
    setuptools-scm
  ];

  cargoDeps = rustPlatform.importCargoLock {
    lockFile = ./Cargo.lock;
  };

  dependencies = [
    interegular
    jsonschema
  ];

  disabledTestPaths = [
    # Downloads from Hugging Face Hub
    "tests/test_kernels.py"
  ];

  disabledTests = [
    # Tests that need to download from Hugging Face Hub.
    "test_complex_serialization"
    "test_create_fsm_index_tokenizer"
    "test_from_pretrained"
    "test_pickling_from_pretrained_with_revision"
    "test_reduced_vocabulary_with_rare_tokens"
  ];

  optional-dependencies = {
    tests = [
      datasets
      numpy
      pydantic
      scipy
      torch
      transformers
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "outlines_core" ];

  meta = {
    description = "Structured text generation (core)";
    homepage = "https://github.com/outlines-dev/outlines-core";
    changelog = "https://github.com/dottxt-ai/outlines-core/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ danieldk ];
  };
})
