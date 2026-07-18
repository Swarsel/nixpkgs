{
  lib,
  fetchFromGitHub,
  accelerate,
  # video
  av,
  blobfile,
  buildPythonPackage,
  datasets,
  # deepspeed
  # deepspeed,
  # codecarbon
  # codecarbon,
  # retrieval
  faiss,
  fastapi,
  # ja
  fugashi,
  gitpython,
  # dependencies
  huggingface-hub,
  ipadic,
  # chat_template
  jinja2,
  jmespath,
  # kernels
  kernels,
  libcst,
  # audio
  librosa,
  # mistral-common
  mistral-common,
  # num2words
  num2words,
  numpy,
  # serving
  openai,
  # opentelemetry
  opentelemetry-api,
  opentelemetry-exporter-otlp,
  opentelemetry-sdk,
  # optuna
  optuna,
  packaging,
  # pyctcdecode,
  phonemizer,
  # vision
  pillow,
  protobuf,
  pydantic,
  pyyaml,
  # ray
  ray,
  regex,
  rich,
  # quality
  ruff,
  safetensors,
  # rhoknp,
  # sagemaker
  sagemaker,
  # optional-dependencies
  # sklearn
  scikit-learn,
  # sentencepiece
  sentencepiece,
  # build-system
  setuptools,
  starlette,
  sudachipy,
  # tiktoken
  tiktoken,
  # timm
  timm,
  tokenizers,
  tomli,
  # torch
  torch,
  # kenlm,
  torchaudio,
  # torch-vision
  torchvision,
  tqdm,
  typer,
  # sudachidict_core,
  # unidic_lite,
  unidic,
  urllib3,
  uvicorn,
}:

buildPythonPackage (finalAttrs: {
  pname = "transformers";
  version = "5.5.4";

  src = fetchFromGitHub {
    owner = "huggingface";
    repo = "transformers";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ZqynYPj8VxH6BmvxHuw3lq16e2FFi3p8pw5of+vkz40=";
  };

  # Many tests require internet access.
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    huggingface-hub
    numpy
    packaging
    pyyaml
    regex
    safetensors
    tokenizers
    tqdm
    typer
  ];

  optional-dependencies = lib.fix (self: {
    accelerate = [ accelerate ];

    audio = [
      torchaudio
      librosa
      # pyctcdecode
      phonemizer
    ];

    benchmark = [
      # optimum-benchmark
    ];

    chat-template = [
      jinja2
      jmespath
    ];

    codecarbon = [
      # codecarbon
    ];

    deepspeed = [
      # deepspeed
    ]
    ++ self.accelerate;

    docs = [
      # hf-docs-builder
    ];

    integrations = self.kernels ++ self.optuna ++ self.codecarbon ++ self.ray;

    ja = [
      fugashi
      ipadic
      # unidic_lite
      unidic
      # rhoknp
      sudachipy
      # sudachidict_core
    ];

    kernels = [ kernels ];
    mistral-common = [ mistral-common ] ++ mistral-common.optional-dependencies.image;
    num2words = [ num2words ];

    open-telemetry = [
      opentelemetry-api
      opentelemetry-exporter-otlp
      opentelemetry-sdk
    ];

    optuna = [ optuna ];

    quality = [
      datasets
      ruff
      gitpython
      urllib3
      libcst
      rich
      tomli
    ];

    ray = [ ray ] ++ ray.optional-dependencies.tune;

    retrieval = [
      faiss
      datasets
    ];

    sagemaker = [ sagemaker ];

    sentencepiece = [
      sentencepiece
      protobuf
    ];

    serving = [
      openai
      pydantic
      uvicorn
      fastapi
      starlette
      rich
    ]
    ++ self.torch;

    sklearn = [ scikit-learn ];

    tiktoken = [
      tiktoken
      blobfile
    ];

    timm = [ timm ];

    torch = [
      torch
      accelerate
    ];

    video = [ av ];

    vision = [
      torchvision
      pillow
    ];
  });

  pyproject = true;
  pythonImportsCheck = [ "transformers" ];

  meta = {
    description = "Natural Language Processing for TensorFlow 2.0 and PyTorch";
    homepage = "https://github.com/huggingface/transformers";
    changelog = "https://github.com/huggingface/transformers/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      GaetanLepage
      pashashocky
      happysalada
    ];

    platforms = lib.platforms.unix;
    mainProgram = "transformers-cli";
  };
})
