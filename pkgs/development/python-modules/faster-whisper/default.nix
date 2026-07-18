{
  lib,
  fetchFromGitHub,
  # dependencies
  av,
  buildPythonPackage,
  ctranslate2,
  huggingface-hub,
  onnxruntime,
  # tests
  pytestCheckHook,
  # build-system
  setuptools,
  tokenizers,
}:

buildPythonPackage rec {
  pname = "faster-whisper";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "SYSTRAN";
    repo = "faster-whisper";
    tag = "v${version}";
    hash = "sha256-pWVYxC1h0kIhhBxAt9oT2USuvoarlcwwYmaLUJlZZwY=";
  };

  # all tests require downloads
  doCheck = false;
  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    export HOME=$TMPDIR
  '';

  build-system = [
    setuptools
  ];

  dependencies = [
    av
    ctranslate2
    huggingface-hub
    onnxruntime
    tokenizers
  ];

  pyproject = true;
  pythonImportsCheck = [ "faster_whisper" ];

  pythonRelaxDeps = [
    "av"
    "tokenizers"
  ];

  meta = {
    description = "Faster Whisper transcription with CTranslate2";
    homepage = "https://github.com/SYSTRAN/faster-whisper";
    changelog = "https://github.com/SYSTRAN/faster-whisper/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
