{
  lib,
  stdenv,
  fetchFromGitHub,
  # dependencies
  asteroid-filterbanks,
  buildPythonPackage,
  einops,
  hatch-vcs,
  # build-system
  hatchling,
  huggingface-hub,
  # optional-dependencies
  hydra-core,
  lightning,
  matplotlib,
  opentelemetry-api,
  opentelemetry-exporter-otlp,
  opentelemetry-sdk,
  # tests
  papermill,
  pyannote-core,
  pyannote-database,
  pyannote-metrics,
  pyannote-pipeline,
  pyannoteai-sdk,
  pytestCheckHook,
  pythonAtLeast,
  pytorch-metric-learning,
  pyyaml,
  safetensors,
  speechbrain,
  tensorboardx,
  torch,
  torch-audiomentations,
  torchaudio,
  torchcodec,
  torchmetrics,
  typer,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyannote-audio";
  version = "4.0.7";

  src = fetchFromGitHub {
    owner = "pyannote";
    repo = "pyannote-audio";
    tag = finalAttrs.version;
    hash = "sha256-SCByRbQ3WD4QmumrZp83nKJ52VQVoiKYFN9l9oDYqzs=";
    fetchSubmodules = true;
  };

  nativeCheckInputs = [
    papermill
    pytestCheckHook
  ];

  preCheck = ''
    $out/bin/pyannote-audio --help
  '';

  __structuredAttrs = true;

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [
    asteroid-filterbanks
    einops
    huggingface-hub
    lightning
    matplotlib
    opentelemetry-api
    opentelemetry-exporter-otlp
    opentelemetry-sdk
    pyannote-core
    pyannote-database
    pyannote-metrics
    pyannote-pipeline
    pyannoteai-sdk
    pytorch-metric-learning
    pyyaml
    safetensors
    speechbrain
    tensorboardx
    torch
    torch-audiomentations
    torchaudio
    torchcodec
    torchmetrics
  ];

  disabledTestPaths =
    lib.optionals stdenv.hostPlatform.isDarwin [
      # Crashes the interpreter
      # - On aarch64-darwin: Trace/BPT trap: 5
      "tests/inference_test.py"
      "tests/test_train.py"
    ]
    ++ lib.optionals (pythonAtLeast "3.14") [
      # RuntimeError: Please call `iter(combined_loader)` first.
      # https://github.com/Lightning-AI/pytorch-lightning/issues/20641
      "tests/inference_test.py"
      "tests/test_train.py"
      # PicklingError: Can't pickle <class 'pyannote.database.registry.Debug'>
      "tests/tasks/test_reproducibility.py"
    ];

  disabledTests = [
    # Require internet access
    "test_hf_download_inference"
    "test_hf_download_model"
    "test_import_speechbrain_encoder_classifier"
    "test_skip_aggregation"
    "test_unknown_specifications_error_raised_on_non_setup_model_task"

    # AttributeError: module 'torchaudio' has no attribute 'info'
    # Removed in torchaudio v2.9.0
    # See https://github.com/pytorch/audio/issues/3902 for context
    "test_audio_resample"
  ];

  optional-dependencies = {
    cli = [
      hydra-core
      typer
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "pyannote.audio" ];

  meta = {
    description = "Neural building blocks for speaker diarization: speech activity detection, speaker change detection, overlapped speech detection, speaker embedding";
    homepage = "https://github.com/pyannote/pyannote-audio";
    changelog = "https://github.com/pyannote/pyannote-audio/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      GaetanLepage
    ];
  };
})
