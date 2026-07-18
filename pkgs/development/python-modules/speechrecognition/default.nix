{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # cohere
  cohere,
  # faster-whisper
  faster-whisper,
  flac,
  # google-cloud
  google-cloud-speech,
  # grok
  groq,
  httpx,
  # openai
  openai,
  # whisper-local
  openai-whisper,
  # pocketsphinx
  pocketsphinx,
  # audio
  pyaudio,
  # tests
  pytest-httpserver,
  pytestCheckHook,
  # optional-dependencies
  # assemblyai
  requests,
  respx,
  # build-system
  setuptools,
  soundfile,
  # dependencies
  standard-aifc,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "speechrecognition";
  version = "3.17.0";

  src = fetchFromGitHub {
    owner = "Uberi";
    repo = "speech_recognition";
    tag = finalAttrs.version;
    hash = "sha256-rzCBOQ0dIfreMRDHMSgMYspJ5KyOSxN18B3mf+n9v2w=";
  };

  # Remove Bundled binaries
  postPatch = ''
    rm speech_recognition/flac-*
    rm -r third-party

    substituteInPlace speech_recognition/audio.py \
      --replace-fail 'shutil_which("flac")' '"${lib.getExe flac}"'
  '';

  nativeCheckInputs = [
    groq
    pocketsphinx
    pytest-httpserver
    pytestCheckHook
    respx
  ]
  ++ lib.concatAttrValues finalAttrs.passthru.optional-dependencies;

  __darwinAllowLocalNetworking = true;
  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    standard-aifc
    typing-extensions
  ];

  disabledTestPaths = [
    # vosk is not available in nixpkgs
    "tests/recognizers/test_vosk.py"
  ];

  disabledTests = [
    # Parsed string does not match expected
    "test_sphinx_keywords"
  ];

  optional-dependencies = {
    assemblyai = [ requests ];
    audio = [ pyaudio ];
    cohere = [ cohere ];
    faster-whisper = [ faster-whisper ];
    google-cloud = [ google-cloud-speech ];

    groq = [
      groq
      httpx
    ];

    openai = [
      httpx
      openai
    ];

    pocketsphinx = [ pocketsphinx ];

    whisper-local = [
      openai-whisper
      soundfile
    ];
    # vosk = [ vosk ];
  };

  pyproject = true;
  pythonImportsCheck = [ "speech_recognition" ];

  meta = {
    description = "Speech recognition module for Python, supporting several engines and APIs, online and offline";
    homepage = "https://github.com/Uberi/speech_recognition";
    changelog = "https://github.com/Uberi/speech_recognition/releases/tag/${finalAttrs.src.tag}";

    license = with lib.licenses; [
      gpl2Only
      bsd3
    ];

    maintainers = with lib.maintainers; [ fab ];
  };
})
