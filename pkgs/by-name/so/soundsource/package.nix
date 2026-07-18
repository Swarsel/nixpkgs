{
  lib,
  fetchurl,
  stdenvNoCC,
  unzip,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "soundsource";
  version = "6.0.2";

  src = fetchurl {
    url = "https://web.archive.org/web/20251220113913/https://cdn.rogueamoeba.com/soundsource/download/SoundSource.zip";
    hash = "sha256-tzgGUYaY6mIZXs3xxGC3b3AoJ/DcaESYr49zcDS7+Fo=";
  };

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications"
    unzip -d "$out/Applications" $src

    runHook postInstall
  '';

  dontUnpack = true;

  meta = {
    description = "Sound controller for macOS";
    homepage = "https://rogueamoeba.com/soundsource";
    changelog = "https://rogueamoeba.com/support/releasenotes/?product=SoundSource";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      emilytrau
      _4evy
    ];

    platforms = lib.platforms.darwin;
  };
})
