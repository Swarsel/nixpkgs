{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  packaging,
  torch,
  torchaudio,
}:
buildPythonPackage (finalAttrs: {
  pname = "silero-vad";
  version = "6.2.1";

  src = fetchFromGitHub {
    owner = "snakers4";
    repo = "silero-vad";
    tag = "v${finalAttrs.version}";
    hash = "sha256-peGaJkSqjeobgx479OKt8ErorFviTIA7naFPewgab4U=";
  };

  # tests use torchcodec which refuses to decode tests/data/test.mp3
  # this causes all tests to fail. See https://github.com/snakers4/silero-vad/issues/777
  doCheck = false;

  build-system = [
    hatchling
  ];

  dependencies = [
    packaging
    torch
    torchaudio
  ];

  pyproject = true;

  pythonImportsCheck = [
    "silero_vad"
  ];

  meta = {
    description = "Silero VAD: pre-trained enterprise-grade Voice Activity Detector";
    homepage = "https://github.com/snakers4/silero-vad";
    changelog = "https://github.com/snakers4/silero-vad/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ seudonym ];
  };
})
