{
  lib,
  fetchFromGitHub,
  accelerate,
  aiohttp,
  anthropic,
  buildPythonPackage,
  einops,
  fastapi,
  gradio,
  httpx,
  markdown2,
  nh3,
  numpy,
  openai,
  peft,
  prompt-toolkit,
  protobuf,
  pydantic,
  ray,
  requests,
  rich,
  sentencepiece,
  setuptools,
  shortuuid,
  tiktoken,
  torch,
  transformers,
  uvicorn,
  wandb,
}:
let
  version = "0.2.36";
in
buildPythonPackage {
  inherit version;
  pname = "fschat";

  src = fetchFromGitHub {
    owner = "lm-sys";
    repo = "FastChat";
    tag = "v${version}";
    hash = "sha256-tQuvQXzQbQjU16DfS1o55VHW6eklngEvIigzZGgrKB8=";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    aiohttp
    fastapi
    httpx
    markdown2
    nh3
    numpy
    prompt-toolkit
    pydantic
    requests
    rich
    shortuuid
    tiktoken
    uvicorn
    # ] ++ markdown2.optional-dependencies.all;
  ];

  # tests require networking
  doCheck = false;

  optional-dependencies = {
    llm_judge = [
      anthropic
      openai
      ray
    ];

    model_worker = [
      accelerate
      peft
      sentencepiece
      torch
      transformers
      protobuf
    ];

    train = [
      # flash-attn
      wandb
      einops
    ];

    webui = [ gradio ];
  };

  pyproject = true;
  pythonImportsCheck = [ "fastchat" ];

  meta = {
    description = "Open platform for training, serving, and evaluating large language models. Release repo for Vicuna and Chatbot Arena";
    homepage = "https://github.com/lm-sys/FastChat";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ happysalada ];
  };
}
