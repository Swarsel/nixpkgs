{
  lib,
  fetchFromGitHub,
  # dependencies
  beartype,
  buildPythonPackage,
  einops,
  fastapi,
  # build-system
  hatchling,
  huggingface-hub,
  numpy,
  pydantic,
  python-multipart,
  requests,
  safetensors,
  scipy,
  sentencepiece,
  # optional-dependencies
  soundfile,
  torch,
  torchao,
  typer,
  typing-extensions,
  uvicorn,
}:

buildPythonPackage (finalAttrs: {
  pname = "pocket-tts";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "kyutai-labs";
    repo = "pocket-tts";
    tag = "v${finalAttrs.version}";
    hash = "sha256-TonwnbH1FQMoK7SyKiCyEVIn9TY8drUyN2ZOq8JpXj4=";
  };

  # All tests are failing as the model cannot be downloaded from the sandbox
  doCheck = false;
  __structuredAttrs = true;

  build-system = [
    hatchling
  ];

  dependencies = [
    beartype
    einops
    fastapi
    huggingface-hub
    numpy
    pydantic
    python-multipart
    requests
    safetensors
    scipy
    sentencepiece
    torch
    typer
    typing-extensions
    uvicorn
  ];

  optional-dependencies = {
    audio = [
      soundfile
    ];

    quantize = [
      torchao
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "pocket_tts" ];

  pythonRelaxDeps = [
    "beartype"
    "python-multipart"
  ];

  meta = {
    description = "Lightweight text-to-speech (TTS) application designed to run efficiently on CPUs";
    homepage = "https://github.com/kyutai-labs/pocket-tts";
    changelog = "https://github.com/kyutai-labs/pocket-tts/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
    mainProgram = "pocket-tts";
  };
})
