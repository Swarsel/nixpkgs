{
  lib,
  fetchFromGitHub,
  # tests
  aiohttp,
  buildPythonPackage,
  # dependencies
  jinja2,
  lm-eval,
  mlx,
  numpy,
  protobuf,
  pytestCheckHook,
  pyyaml,
  sentencepiece,
  # build-system
  setuptools,
  transformers,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "mlx-lm";
  version = "0.31.3";

  src = fetchFromGitHub {
    owner = "ml-explore";
    repo = "mlx-lm";
    tag = "v${finalAttrs.version}";
    hash = "sha256-DPOJfsIucG8mWt4ZKenymCJo/i9Jw+a+iuIygIIYkA8=";
  };

  nativeCheckInputs = [
    aiohttp
    lm-eval
    pytestCheckHook
    sentencepiece
    writableTmpDirAsHomeHook
  ];

  __structuredAttrs = true;

  build-system = [
    setuptools
  ];

  dependencies = [
    jinja2
    mlx
    numpy
    protobuf
    pyyaml
    transformers
  ];

  disabledTestPaths = [
    # Requires network access to huggingface.co
    "tests/test_datsets.py"
    "tests/test_generate.py"
    "tests/test_prompt_cache.py::TestPromptCache"
    "tests/test_server.py"
    "tests/test_tokenizers.py"
    "tests/test_utils.py::TestUtils::test_convert"
    "tests/test_utils.py::TestUtils::test_load"

    # RuntimeError: [metal_kernel] No GPU back-end.
    "tests/test_losses.py"
    "tests/test_models.py::TestModels::test_bitnet"

    # TypeError: 'NoneType' object is not callable
    "tests/test_models.py::TestModels::test_gated_delta"
    "tests/test_models.py::TestModels::test_gated_delta_masked"
  ];

  pyproject = true;
  pythonImportsCheck = [ "mlx_lm" ];

  pythonRelaxDeps = [
    "transformers"
  ];

  meta = {
    description = "Run LLMs with MLX";
    homepage = "https://github.com/ml-explore/mlx-lm";
    changelog = "https://github.com/ml-explore/mlx-lm/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
  };
})
