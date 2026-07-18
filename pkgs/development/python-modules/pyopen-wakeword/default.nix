{
  lib,
  stdenv,
  fetchFromGitHub,
  autoPatchelfHook,
  buildPythonPackage,
  numpy,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyopen-wakeword";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "rhasspy";
    repo = "pyopen-wakeword";
    tag = "v${version}";
    hash = "sha256-czFDuIZ10aetr6frkKSozPjS7zMeNJ5/WVLA7Ib1CaI=";
  };

  postPatch = ''
    # install pre-compiled libtensorflowlite
    python ./script/copy_lib
  '';

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    numpy
  ];

  pyproject = true;

  pythonImportsCheck = [
    "pyopen_wakeword"
  ];

  meta = {
    description = "Alternative Python library for openWakeWord";
    homepage = "https://github.com/rhasspy/pyopen-wakeword";
    changelog = "https://github.com/rhasspy/pyopen-wakeword/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    # vendors prebuilt libtensorflowlite_c.{so,dll,dylib}
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ hexa ];

    broken =
      # elftools.common.exceptions.ELFError: Magic number does not match
      stdenv.hostPlatform.isDarwin
      ||
        # segfaults when calling into libtensorflowlite
        stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isAarch64;
  };
}
