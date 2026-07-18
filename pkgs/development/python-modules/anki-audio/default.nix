{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  lame,
  mpv-unwrapped,
}:

buildPythonPackage (finalAttrs: {
  pname = "anki-audio";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "ankitects";
    repo = "anki-bundle-extras";
    rev = "e83c6e64dcb110ed579fc78afbb4e72bed8fb9e9";
    hash = "sha256-iOAZ7EytEVpvsrnVFk6bkiU8FWf2Q7tTzJjawZQCW6E=";
  };

  env = {
    ANKI_AUDIO_TARGET_ARCH = stdenv.hostPlatform.darwinArch;
    ANKI_AUDIO_TARGET_OS = "darwin";
  };

  preBuild =
    let
      archDir = if stdenv.hostPlatform.isAarch64 then "arm64" else "amd64";
    in
    ''
      mkdir -p mac/${archDir}/dist/audio/Resources
      ln -s ${lib.getExe mpv-unwrapped} ${lib.getExe lame} mac/${archDir}/dist/audio/Resources/
    '';

  build-system = [ hatchling ];
  pyproject = true;
  pythonImportsCheck = [ "anki_audio" ];

  meta = {
    description = "Audio binaries (mpv, lame) for Anki";
    homepage = "https://github.com/ankitects/anki-bundle-extras";
    license = lib.licenses.gpl2Plus;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];

    maintainers = with lib.maintainers; [
      euank
      junestepp
      oxij
    ];

    platforms = lib.platforms.darwin;
  };
})
