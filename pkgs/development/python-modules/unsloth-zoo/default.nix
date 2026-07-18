{
  lib,
  # dependencies
  accelerate,
  buildPythonPackage,
  # tests
  cudaPackages,
  cut-cross-entropy,
  datasets,
  fetchPypi,
  filelock,
  hf-transfer,
  huggingface-hub,
  msgspec,
  numpy,
  packaging,
  peft,
  pillow,
  protobuf,
  psutil,
  python,
  regex,
  sentencepiece,
  # build-system
  setuptools,
  setuptools-scm,
  torch,
  torchao,
  tqdm,
  transformers,
  triton,
  trl,
  typing-extensions,
  tyro,
}:

buildPythonPackage (finalAttrs: {
  pname = "unsloth-zoo";
  version = "2026.4.7";

  # no tags on GitHub
  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-jJ58d2+5lEALEaASELZtQkY2YxNWaLrfLvOCUGnwrh4=";
    pname = "unsloth_zoo";
  };

  patches = [
    # Avoid circular dependency in Nix, since `unsloth` depends on `unsloth-zoo`.
    ./dont-require-unsloth.patch
  ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail \
        "setuptools==80.9.0" \
        "setuptools" \
      --replace-fail \
        "setuptools-scm==9.2.0" \
        "setuptools-scm"
  '';

  # No tests
  doCheck = false;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    accelerate
    cut-cross-entropy
    datasets
    filelock
    hf-transfer
    huggingface-hub
    msgspec
    numpy
    packaging
    peft
    pillow
    protobuf
    psutil
    regex
    sentencepiece
    torch
    torchao
    triton
    tqdm
    transformers
    trl
    tyro
    typing-extensions
  ];

  # Importing touches torch.cuda at module import time and queries GPU memory.
  dontUsePythonImportsCheck = true;
  pyproject = true;

  pythonRelaxDeps = [
    "datasets"
    "torch"
    "transformers"
  ];

  # Cover the import path on GPU-enabled runners instead of pure builders.
  passthru.gpuCheck =
    (cudaPackages.writeGpuTestPython.override { python3Packages = python.pkgs; }
      {
        libraries = ps: [ ps.unsloth-zoo ];
      }
      ''
        import torch

        assert torch.cuda.is_available(), "CUDA is not available"
        assert torch.ones(1, device="cuda").is_cuda

        import unsloth_zoo  # noqa: F401
        from unsloth_zoo.device_type import DEVICE_COUNT, DEVICE_TYPE

        assert DEVICE_TYPE == "cuda", DEVICE_TYPE
        assert DEVICE_COUNT > 0, DEVICE_COUNT
        print(f"Unsloth Zoo detected {DEVICE_COUNT} CUDA device(s)")
      ''
    ).gpuCheck;

  meta = {
    description = "Utils for Unsloth";
    homepage = "https://github.com/unslothai/unsloth_zoo";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ hoh ];
  };
})
