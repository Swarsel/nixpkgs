{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fastai,
  fastcore,
  # dependencies
  filelock,
  fsspec,
  # gradio
  gradio,
  hf-xet,
  httpx,
  # mcp
  mcp,
  packaging,
  pyyaml,
  requests,
  safetensors,
  # build-system
  setuptools,
  # fastai
  toml,
  # optional-dependencies
  # torch
  torch,
  tqdm,
  typer,
  typing-extensions,
  # tests
  versionCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "huggingface-hub";
  version = "1.10.2";

  src = fetchFromGitHub {
    owner = "huggingface";
    repo = "huggingface_hub";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Q9N0QnxV8oJcxUsJzv4wX8Z6FkNdEfUH5BEVoZolsRY=";
  };

  nativeCheckInputs = [
    versionCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    filelock
    fsspec
    hf-xet
    httpx
    packaging
    pyyaml
    tqdm
    typer
    typing-extensions
  ];

  optional-dependencies = {
    all = [

    ];

    fastai = [
      toml
      fastai
      fastcore
    ];

    gradio = [
      gradio
      requests
    ];

    hf_xet = [
      hf-xet
    ];

    mcp = [
      mcp
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
    changelog = "https://github.com/huggingface/huggingface_hub/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      GaetanLepage
      osbm
    ];

    mainProgram = "hf";
  };
})
