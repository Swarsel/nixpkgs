{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  cmake,
  # dependencies
  mlx-lm,
  nanobind,
  ninja,
  numpy,
  pydantic,
  # tests
  pytestCheckHook,
  scikit-build-core,
  sentencepiece,
  tiktoken,
  torch,
  transformers,
  triton,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "xgrammar";
  version = "0.1.33";

  src = fetchFromGitHub {
    owner = "mlc-ai";
    repo = "xgrammar";
    tag = "v${version}";
    hash = "sha256-mliAmFBY3eLnUP+2HCRGX36KPUjaxn0Eb+2aKyDwdaM=";
    fetchSubmodules = true;
  };

  patches = [
    ./0001-fix-find-nanobind-from-python-module.patch
  ];

  env = lib.optionalAttrs stdenv.hostPlatform.isLinux {
    NIX_CFLAGS_COMPILE = toString [
      # xgrammar hardcodes -flto=auto while using static linking, which can cause linker errors without this additional flag.
      "-ffat-lto-objects"
    ];
  };

  nativeCheckInputs = [
    pytestCheckHook
    sentencepiece
    tiktoken
    writableTmpDirAsHomeHook
  ];

  build-system = [
    cmake
    ninja
    nanobind
    scikit-build-core
  ];

  dependencies = [
    numpy
    pydantic
    torch
    transformers
  ]
  ++ lib.optionals (stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isx86_64) [
    triton
  ]
  ++ lib.optionals (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64) [
    mlx-lm
  ];

  disabledTestPaths = [
    # Requires internet access
    "tests/python/test_structural_tag_converter.py"
    "tests/python/test_structural_tag_for_model.py"
  ];

  disabledTests = [
    # You are trying to access a gated repo.
    "test_grammar_compiler"
    "test_grammar_matcher"
    "test_grammar_matcher_ebnf"
    "test_grammar_matcher_json"
    "test_grammar_matcher_json_schema"
    "test_grammar_matcher_tag_dispatch"
    "test_regex_converter"
    "test_serialize_compiled_grammar_with_hf_tokenizer"
    "test_tokenizer_info"

    # Torch not compiled with CUDA enabled
    "test_token_bitmask_operations"

    # AssertionError
    "test_json_schema_converter"
  ];

  dontUseCmakeConfigure = true;
  pyproject = true;
  pythonImportsCheck = [ "xgrammar" ];

  meta = {
    description = "Efficient, Flexible and Portable Structured Generation";
    homepage = "https://xgrammar.mlc.ai";
    changelog = "https://github.com/mlc-ai/xgrammar/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
  };
}
