{
  lib,
  stdenv,
  fetchFromGitHub,
  argostranslate,
  beautifulsoup4,
  buildPythonPackage,
  setuptools,
  writableTmpDirAsHomeHook,
}:

let
  inherit (stdenv.hostPlatform) isLinux isAarch64;
  isAarch64Linux = isLinux && isAarch64;
in
buildPythonPackage (finalAttrs: {
  pname = "translatehtml";
  version = "1.5.3";

  src = fetchFromGitHub {
    owner = "argosopentech";
    repo = "translate-html";
    tag = "v${finalAttrs.version}";
    hash = "sha256-A94N/nfYSVwi0M3SpNFqlXrRNOCpIi9agOCAlH66QcI=";
  };

  doCheck = !isAarch64Linux;
  nativeCheckInputs = [ writableTmpDirAsHomeHook ];
  build-system = [ setuptools ];

  dependencies = [
    argostranslate
    beautifulsoup4
  ];

  pyproject = true;
  # aarch64-linux fails cpuinfo test, because /sys/devices/system/cpu/ does not exist in the sandbox:
  # terminate called after throwing an instance of 'onnxruntime::OnnxRuntimeException'
  pythonImportsCheck = lib.optional (!isAarch64Linux) "translatehtml";
  pythonRelaxDeps = [ "beautifulsoup4" ];

  meta = {
    description = "Translate HTML using Beautiful Soup and Argos Translate";
    homepage = "https://www.argosopentech.com";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ misuzu ];
  };
})
