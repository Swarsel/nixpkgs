{
  lib,
  fetchFromGitHub,
  accelerate,
  av,
  buildPythonPackage,
  cookiecutter,
  datasets,
  # optional-dependencies
  diffusers,
  fairscale,
  faiss,
  fastapi,
  # dependencies
  filelock,
  flax,
  ftfy,
  hf-xet,
  huggingface-hub,
  jax,
  jaxlib,
  librosa,
  numpy,
  onnxconverter-common,
  onnxruntime,
  onnxruntime-tools,
  opencv4,
  optax,
  optuna,
  packaging,
  phonemizer,
  pillow,
  protobuf,
  pydantic,
  pyyaml,
  ray,
  regex,
  requests,
  safetensors,
  sagemaker,
  scikit-learn,
  sentencepiece,
  # build-system
  setuptools,
  starlette,
  tensorflow,
  tf2onnx,
  timm,
  tokenizers,
  torch,
  torchaudio,
  torchvision,
  tqdm,
  uvicorn,
}:

buildPythonPackage (finalAttrs: {
  pname = "transformers";
  version = "4.57.6";

  src = fetchFromGitHub {
    owner = "huggingface";
    repo = "transformers";
    tag = "v${finalAttrs.version}";
    hash = "sha256-a78ornUAYlOpr30iFdq1oUiWQTm6GeT0iq8ras5i3DQ=";
  };

  # Many tests require internet access.
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    filelock
    huggingface-hub
    numpy
    packaging
    pyyaml
    regex
    requests
    tokenizers
    safetensors
    tqdm
  ];

  optional-dependencies =
    let
      audio = [
        librosa
        # pyctcdecode
        phonemizer
        # kenlm
      ];
      vision = [ pillow ];
    in
    {
      agents = [
        diffusers
        accelerate
        datasets
        torch
        sentencepiece
        opencv4
        pillow
      ];

      audio = audio;

      deepspeed = [
        # deepspeed
        accelerate
      ];

      fairscale = [ fairscale ];

      flax = [
        jax
        jaxlib
        flax
        optax
      ];

      flax-speech = audio;
      ftfy = [ ftfy ];

      hf_xet = [
        hf-xet
      ];

      ja = [
        # fugashi
        # ipadic
        # rhoknp
        # sudachidict_core
        # sudachipy
        # unidic
        # unidic_lite
      ];

      modelcreation = [ cookiecutter ];

      onnx = [
        onnxconverter-common
        tf2onnx
        onnxruntime
        onnxruntime-tools
      ];

      onnxruntime = [
        onnxruntime
        onnxruntime-tools
      ];

      optuna = [ optuna ];
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

      # sigopt = [ sigopt ];
      # integrations = ray ++ optuna ++ sigopt;
      serving = [
        pydantic
        uvicorn
        fastapi
        starlette
      ];

      sklearn = [ scikit-learn ];
      speech = [ torchaudio ] ++ audio;

      tf = [
        tensorflow
        onnxconverter-common
        tf2onnx
        # tensorflow-text
        # keras-nlp
      ];

      tf-speech = audio;
      timm = [ timm ];
      tokenizers = [ tokenizers ];

      torch = [
        torch
        accelerate
      ];

      torch-speech = [ torchaudio ] ++ audio;
      torch-vision = [ torchvision ] ++ vision;

      # natten = [ natten ];
      # codecarbon = [ codecarbon ];
      video = [
        av
      ];
    };

  pyproject = true;
  pythonImportsCheck = [ "transformers" ];
  pythonRelaxDeps = [ "huggingface-hub" ];

  meta = {
    description = "Natural Language Processing for TensorFlow 2.0 and PyTorch";
    homepage = "https://github.com/huggingface/transformers";
    changelog = "https://github.com/huggingface/transformers/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      pashashocky
      happysalada
    ];

    platforms = lib.platforms.unix;
    mainProgram = "transformers-cli";
    broken = lib.versionAtLeast huggingface-hub.version "1.0";
  };
})
