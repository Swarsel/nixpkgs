{
  lib,
  fetchFromGitHub,
  # tests
  braceexpand,
  buildPythonPackage,
  # dependencies
  ftfy,
  huggingface-hub,
  pandas,
  # build-system
  pdm-backend,
  protobuf,
  pytestCheckHook,
  regex,
  requests,
  safetensors,
  sentencepiece,
  timm,
  torch,
  torchvision,
  tqdm,
  transformers,
  webdataset,
}:
buildPythonPackage (finalAttrs: {
  pname = "open-clip-torch";
  version = "3.3.0";

  src = fetchFromGitHub {
    owner = "mlfoundations";
    repo = "open_clip";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rJT0LCIS0uChBUdZ6WTQv0npZ0Ae8veIXMgr6JTgUj4=";
  };

  nativeCheckInputs = [
    braceexpand
    pandas
    pytestCheckHook
    requests
    transformers
    webdataset
  ];

  build-system = [ pdm-backend ];

  dependencies = [
    ftfy
    huggingface-hub
    protobuf
    regex
    safetensors
    sentencepiece
    timm
    torch
    torchvision
    tqdm
  ];

  disabledTestPaths = [
    # -> On Darwin:
    # AttributeError: Can't pickle local object 'build_params.<locals>.<lambda>'
    # -> On Linux:
    # KeyError: Caught KeyError in DataLoader worker process 0
    "tests/test_wds.py"
  ];

  disabledTests = [
    # requires network
    "test_download_pretrained_from_hfh"
    "test_inference_simple"
    "test_inference_with_data"
    "test_pretrained_text_encoder"
    "test_training_mt5"

    # fails due to type errors
    "test_num_shards"

    # hangs forever
    "test_training"
  ];

  pyproject = true;
  pythonImportsCheck = [ "open_clip" ];

  meta = {
    description = "Open source implementation of CLIP";
    homepage = "https://github.com/mlfoundations/open_clip";
    changelog = "https://github.com/mlfoundations/open_clip/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ iynaix ];
    mainProgram = "open-clip";
  };
})
