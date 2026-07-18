{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  espeak-ng,
  pytestCheckHook,
  replaceVars,
}:

buildPythonPackage rec {
  pname = "espeak-phonemizer";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "rhasspy";
    repo = "espeak-phonemizer";
    tag = "v${version}";
    hash = "sha256-K0s24mzXUqG0Au40jjGbpKNAznBkMHQzfh2/CDBN0F8=";
  };

  patches = [
    (replaceVars ./cdll.patch {
      libespeak_ng = "${lib.getLib espeak-ng}/lib/libespeak-ng.so";
    })
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  format = "setuptools";

  meta = {
    description = "Uses ctypes and libespeak-ng to transform test into IPA phonemes";
    homepage = "https://github.com/rhasspy/espeak-phonemizer";
    changelog = "https://github.com/rhasspy/espeak-phonemizer/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
    platforms = lib.platforms.linux;
    mainProgram = "espeak-phonemizer";
  };
}
