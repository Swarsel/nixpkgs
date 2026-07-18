{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  ctranslate2,
  ctranslate2-cpp,
  minisbd,
  # tests
  pytestCheckHook,
  sacremoses,
  sentencepiece,
  # build-system
  setuptools,
  spacy,
  stanza,
  writableTmpDirAsHomeHook,
}:
let
  ctranslate2OneDNN = ctranslate2.override {
    ctranslate2-cpp = ctranslate2-cpp.override {
      # https://github.com/OpenNMT/CTranslate2/issues/1294
      withOneDNN = true;
      withOpenblas = false;
    };
  };

  inherit (stdenv.hostPlatform) isDarwin isLinux isAarch64;
  isAarch64Linux = isLinux && isAarch64;
in
buildPythonPackage (finalAttrs: {
  pname = "argostranslate";
  version = "1.11.0";

  src = fetchFromGitHub {
    owner = "argosopentech";
    repo = "argos-translate";
    tag = "v${finalAttrs.version}";
    hash = "sha256-8uzWS0YZEteeLTYAp9qpnnJhxyhxbWkKt1krqe/RF4M=";
  };

  doCheck = !isAarch64Linux;

  nativeCheckInputs = [
    pytestCheckHook
    writableTmpDirAsHomeHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    ctranslate2OneDNN
    minisbd
    sacremoses
    sentencepiece
    spacy
    stanza
  ];

  pyproject = true;

  # aarch64-linux fails cpuinfo test, because /sys/devices/system/cpu/ does not exist in the sandbox:
  # terminate called after throwing an instance of 'onnxruntime::OnnxRuntimeException'
  pythonImportsCheck = lib.optionals (!isAarch64Linux) [
    "argostranslate"
    "argostranslate.translate"
  ];

  pythonRelaxDeps = [
    "stanza"
  ];

  meta = {
    description = "Open-source offline translation library written in Python";
    homepage = "https://www.argosopentech.com";
    changelog = "https://github.com/argosopentech/argos-translate/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      misuzu
      Stebalien
    ];
  };
})
