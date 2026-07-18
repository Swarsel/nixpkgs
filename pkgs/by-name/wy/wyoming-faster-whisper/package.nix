{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "wyoming-faster-whisper";
  version = "3.5.0";

  src = fetchFromGitHub {
    owner = "rhasspy";
    repo = "wyoming-faster-whisper";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+RmP552zsvWbxIpfhmKNdU4EZSeEImUdaF827g6Tuco=";
  };

  # tests require models from huggingface
  doCheck = false;

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    faster-whisper
    pysilero-vad
    wyoming
  ];

  optional-dependencies = with python3Packages; {
    onnx_asr = [
      onnx-asr
    ]
    ++ onnx-asr.optional-dependencies.cpu
    ++ onnx-asr.optional-dependencies.hub;

    sherpa = [
      sherpa-onnx
    ];

    transformers = [
      transformers
    ]
    ++ transformers.optional-dependencies.torch;

    zeroconf = [
      wyoming
    ]
    ++ wyoming.optional-dependencies.zeroconf;
  };

  pyproject = true;

  pythonImportsCheck = [
    "wyoming_faster_whisper"
  ];

  pythonRelaxDeps = [
    "faster-whisper"
    "wyoming"
  ];

  meta = {
    description = "Wyoming Server for Faster Whisper";
    homepage = "https://github.com/rhasspy/wyoming-faster-whisper";
    changelog = "https://github.com/rhasspy/wyoming-faster-whisper/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
    mainProgram = "wyoming-faster-whisper";
  };
})
