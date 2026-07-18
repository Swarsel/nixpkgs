{
  lib,
  fetchFromGitHub,
  piper-tts,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "wyoming-piper";
  version = "2.2.2";

  src = fetchFromGitHub {
    owner = "rhasspy";
    repo = "wyoming-piper";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pk6HAzl0A8R5szI7d6ZFOQI5akkzWb0Nb/WuxKdIwg8=";
  };

  doCheck = false; # only test requires network

  nativeCheckInputs = with python3Packages; [
    numpy
    pytest-asyncio
    pytestCheckHook
    python-speech-features
  ];

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies =
    with python3Packages;
    [
      regex
      piper-tts
      sentence-stream
      wyoming
    ]
    ++ wyoming.optional-dependencies.zeroconf;

  disabledTests = [
    # network access
    "test_piper"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "wyoming_piper"
  ];

  pythonRelaxDeps = [
    "regex"
    "sentence-stream"
    "wyoming"
  ];

  meta = {
    description = "Wyoming Server for Piper";
    homepage = "https://github.com/rhasspy/wyoming-piper";
    changelog = "https://github.com/rhasspy/wyoming-piper/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
    mainProgram = "wyoming-piper";
  };
})
