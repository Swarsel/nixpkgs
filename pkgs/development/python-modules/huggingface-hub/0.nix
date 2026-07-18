{
  lib,
  fetchFromGitHub,
  # inference
  aiohttp,
  buildPythonPackage,
  fastai,
  fastcore,
  # dependencies
  filelock,
  fsspec,
  graphviz,
  # hf_transfer
  hf-transfer,
  hf-xet,
  # optional-dependencies
  # cli
  inquirerpy,
  # tensorflow-testing
  keras,
  packaging,
  pydot,
  pyyaml,
  requests,
  safetensors,
  # build-system
  setuptools,
  # tensorflow
  tensorflow,
  # fastai
  toml,
  # torch
  torch,
  tqdm,
  typing-extensions,
  # tests
  versionCheckHook,
}:

buildPythonPackage rec {
  pname = "huggingface-hub";
  version = "0.36.2";

  src = fetchFromGitHub {
    owner = "huggingface";
    repo = "huggingface_hub";
    tag = "v${version}";
    hash = "sha256-cUp5Mm8vgJI/0N/9inQVedGWRde8lioduFoccq6b7UE=";
  };

  nativeCheckInputs = [
    versionCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    filelock
    fsspec
    hf-xet
    packaging
    pyyaml
    requests
    tqdm
    typing-extensions
  ];

  optional-dependencies = {
    all = [

    ];

    cli = [
      inquirerpy
    ];

    fastai = [
      toml
      fastai
      fastcore
    ];

    hf_transfer = [
      hf-transfer
    ];

    hf_xet = [
      hf-xet
    ];

    inference = [
      aiohttp
    ];

    tensorflow = [
      tensorflow
      pydot
      graphviz
    ];

    tensorflow-testing = [
      tensorflow
      keras
    ];

    torch = [
      torch
      safetensors
    ]
    ++ safetensors.optional-dependencies.torch;
  };

  pyproject = true;
  pythonImportsCheck = [ "huggingface_hub" ];
  versionCheckProgramArg = "version";

  meta = {
    description = "Download and publish models and other files on the huggingface.co hub";
    homepage = "https://github.com/huggingface/huggingface_hub";
    changelog = "https://github.com/huggingface/huggingface_hub/releases/tag/v${version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      GaetanLepage
      osbm
    ];

    mainProgram = "hf";
  };
}
