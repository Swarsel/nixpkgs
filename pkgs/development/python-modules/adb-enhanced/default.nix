{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  docopt,
  fetchpatch,
  jdk11,
  psutil,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "adb-enhanced";
  version = "2.8.0";

  src = fetchFromGitHub {
    owner = "ashishb";
    repo = "adb-enhanced";
    tag = finalAttrs.version;
    hash = "sha256-YuQgz3WeN50hg/IgdoNV61St9gpu6lcgFfKCfI/ENl0=";
  };

  patches = [
    # psutil==7.2.1 -> psutil==7.2.2
    (fetchpatch {
      hash = "sha256-BRpdgLS6CNkmyj+OwnIaqfkmz1jzZg/qtoiN32jUIog=";
      url = "https://github.com/ashishb/adb-enhanced/pull/337.patch";
    })
  ];

  postPatch = ''
    substituteInPlace adbe/adb_enhanced.py \
      --replace-fail "f\"java" "f\"${lib.getExe jdk11}"
  '';

  # Disable tests because they require a dedicated Android emulator
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    psutil
    docopt
  ];

  pyproject = true;
  pythonImportsCheck = [ "adbe" ];

  meta = {
    description = "Tool for Android testing and development";
    homepage = "https://github.com/ashishb/adb-enhanced";
    license = lib.licenses.asl20;

    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode
    ];

    maintainers = with lib.maintainers; [ vtuan10 ];
    mainProgram = "adbe";
  };
})
