{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  clarifai-grpc,
  clarifai-protocol,
  click,
  fsspec,
  huggingface-hub,
  inquirerpy,
  numpy,
  pillow,
  pkgs,
  psutil,
  pycocotools,
  pydantic-core,
  pytest-asyncio,
  pytestCheckHook,
  pyyaml,
  rich,
  ruff,
  schema,
  setuptools,
  tabulate,
  tqdm,
  tritonclient,
  uv,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "clarifai";
  version = "12.1.4";

  src = fetchFromGitHub {
    owner = "Clarifai";
    repo = "clarifai-python";
    tag = version;
    hash = "sha256-+iIOAji6xDyGTZTE/DgRguYhgWYM1FS8+SIlPcmNpNo=";
  };

  nativeCheckInputs = [
    pkgs.gitMinimal
    huggingface-hub
    pytest-asyncio
    pytestCheckHook
    writableTmpDirAsHomeHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    clarifai-grpc
    clarifai-protocol
    click
    fsspec
    inquirerpy
    numpy
    pillow
    psutil
    pydantic-core
    pyyaml
    rich
    ruff
    schema
    tabulate
    tqdm
    tritonclient
    uv
  ];

  disabledTestPaths = [
    # Tests require network access and API key
    "tests/cli/test_compute_orchestration.py"
    "tests/runners/test_download_checkpoints.py"
    "tests/runners/test_model_run_locally.py"
    "tests/runners/test_model_upload.py"
    "tests/runners/test_num_threads_config.py"
    "tests/runners/test_runners_proto.py"
    "tests/runners/test_runners.py"
    "tests/runners/test_url_fetcher.py"
    "tests/runners/test_vllm_model_upload.py"
    "tests/test_app.py"
    "tests/test_data_upload.py"
    "tests/test_eval.py"
    "tests/test_list_models.py"
    "tests/test_model_predict.py"
    "tests/test_model_train.py"
    "tests/test_rag.py"
    "tests/test_search.py"
    "tests/workflow/test_create_delete.py"
    "tests/workflow/test_predict.py"
  ];

  disabledTests = [
    # Test requires network access and API key
    "test_export_workflow_general"
    "test_validate_invalid_id"
    "test_validate_invalid_hex_id"
  ];

  optional-dependencies = {
    all = [ pycocotools ];
  };

  pyproject = true;
  pythonImportsCheck = [ "clarifai" ];

  pythonRelaxDeps = [
    "clarifai-protocol"
    "click"
    "fsspec"
    "psutil"
    "ruff"
    "schema"
    "uv"
  ];

  meta = {
    description = "Clarifai Python Utilities";
    homepage = "https://github.com/Clarifai/clarifai-python";
    changelog = "https://github.com/Clarifai/clarifai-python/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ natsukium ];
    mainProgram = "clarifai";
  };
}
