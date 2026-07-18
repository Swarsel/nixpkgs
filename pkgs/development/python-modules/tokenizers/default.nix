{
  lib,
  fetchurl,
  fetchFromGitHub,
  buildPythonPackage,
  # nativeBuildInputs
  cargo,
  # tests
  datasets,
  # dependencies
  huggingface-hub,
  linkFarm,
  numpy,
  # buildInputs
  openssl,
  pkg-config,
  pytest-asyncio,
  pytestCheckHook,
  requests,
  rustPlatform,
  rustc,
  setuptools-rust,
  tiktoken,
  writableTmpDirAsHomeHook,
}:

let
  # See https://github.com/huggingface/tokenizers/blob/main/bindings/python/tests/utils.py for details
  # about URLs and file names
  test-data = linkFarm "tokenizers-test-data" {
    "albert-base-v1-tokenizer.json" = fetchurl {
      hash = "sha256-biqj1cpMaEG8NqUCgXnLTWPBKZMfoY/OOP2zjOxNKsM=";
      url = "https://s3.amazonaws.com/models.huggingface.co/bert/albert-base-v1-tokenizer.json";
    };

    "bert-base-uncased-vocab.txt" = fetchurl {
      hash = "sha256-B+ztN1zsFE0nyQAkHz4zlHjeyVj5L928VR8pXJkgOKM=";
      url = "https://s3.amazonaws.com/models.huggingface.co/bert/bert-base-uncased-vocab.txt";
    };

    "bert-wiki.json" = fetchurl {
      hash = "sha256-i533xC8J5CDMNxBjo+p6avIM8UOcui8RmGAmK0GmfBc=";
      url = "https://s3.amazonaws.com/models.huggingface.co/bert/anthony/doc-pipeline/tokenizer.json";
    };

    "big.txt" = fetchurl {
      hash = "sha256-+gZsfUDw8gGsQUTmUqpiQw5YprOAXscGUPZ42lgE6Hs=";
      url = "https://norvig.com/big.txt";
    };

    "openai-gpt-merges.txt" = fetchurl {
      hash = "sha256-Dqm1GuaVBzzYceA1j3AWMR1nGn/zlj42fVI2Ui8pRyU=";
      url = "https://s3.amazonaws.com/models.huggingface.co/bert/openai-gpt-merges.txt";
    };

    "openai-gpt-vocab.json" = fetchurl {
      hash = "sha256-/fSbGefeI2hSCR2gm4Sno81eew55kWN2z0X2uBJ7gHg=";
      url = "https://s3.amazonaws.com/models.huggingface.co/bert/openai-gpt-vocab.json";
    };

    "roberta-base-merges.txt" = fetchurl {
      hash = "sha256-HOFmR3PFDz4MyIQmGak+3EYkUltyixiKngvjO3cmrcU=";
      url = "https://s3.amazonaws.com/models.huggingface.co/bert/roberta-base-merges.txt";
    };

    "roberta-base-vocab.json" = fetchurl {
      hash = "sha256-nn9jwtFdZmtS4h0lDS5RO4fJtxPPpph6gu2J5eblBlU=";
      url = "https://s3.amazonaws.com/models.huggingface.co/bert/roberta-base-vocab.json";
    };

    "tokenizer-llama3.json" = fetchurl {
      hash = "sha256-eePlImNfMXEwCRO7QhRkqH3mIiGCoFcLmyzLoqlksrQ=";
      url = "https://huggingface.co/Narsil/llama-tokenizer/resolve/main/tokenizer.json";
    };

    "tokenizer-wiki.json" = fetchurl {
      hash = "sha256-ipY9d5DR5nxoO6kj7rItueZ9AO5wq9+Nzr6GuEIfIBI=";
      url = "https://s3.amazonaws.com/models.huggingface.co/bert/anthony/doc-quicktour/tokenizer.json";
    };
  };
in
buildPythonPackage rec {
  pname = "tokenizers";
  version = "0.22.2";

  src = fetchFromGitHub {
    owner = "huggingface";
    repo = "tokenizers";
    tag = "v${version}";
    hash = "sha256-krc+FUA5H3J7L4D1xyjyFMpjXMU8TEfwdfRT4+uvti8=";
  };

  nativeBuildInputs = [
    cargo
    pkg-config
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
    rustc
    setuptools-rust
  ];

  buildInputs = [
    openssl
  ];

  nativeCheckInputs = [
    datasets
    numpy
    pytest-asyncio
    pytestCheckHook
    requests
    tiktoken
    writableTmpDirAsHomeHook
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit
      pname
      version
      src
      sourceRoot
      ;

    hash = "sha256-anYZ7M5OvLOOHDy+sLuZlHQ/cNTk6xHksBHSHa75iY4=";
  };

  dependencies = [
    huggingface-hub
  ];

  disabledTestPaths = [
    # fixture 'model' not found
    "benches/test_tiktoken.py"
  ];

  disabledTests = [
    # Downloads data using the datasets module
    "test_encode_special_tokens"
    "test_splitting"
    "TestTrainFromIterators"

    # Require downloading from huggingface
    # huggingface_hub.errors.LocalEntryNotFoundError
    "test_async_methods_existence"
    "test_basic_encoding"
    "test_concurrency"
    "test_decode"
    "test_decode_skip_special_tokens"
    "test_decode_stream_fallback"
    "test_encode"
    "test_error_handling"
    "test_large_batch"
    "test_numpy_inputs"
    "test_performance_comparison"
    "test_various_input_formats"
    "test_with_special_tokens"
    "test_with_truncation_padding"

    # Those tests require more data
    "test_from_pretrained"
    "test_from_pretrained_revision"
    "test_continuing_prefix_trainer_mistmatch"
  ];

  postUnpack =
    # Add data files for tests, otherwise tests attempt network access
    ''
      mkdir $sourceRoot/tests/data
      ln -s ${test-data}/* $sourceRoot/tests/data/
    '';

  pyproject = true;
  pythonImportsCheck = [ "tokenizers" ];
  sourceRoot = "${src.name}/bindings/python";

  meta = {
    description = "Fast State-of-the-Art Tokenizers optimized for Research and Production";
    homepage = "https://github.com/huggingface/tokenizers";
    changelog = "https://github.com/huggingface/tokenizers/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
    platforms = lib.platforms.unix;
  };
}
