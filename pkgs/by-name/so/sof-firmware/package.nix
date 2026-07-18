{
  lib,
  fetchurl,
  nix-update-script,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "sof-firmware";
  version = "2025.12.2";

  src = fetchurl {
    url = "https://github.com/thesofproject/sof-bin/releases/download/v${finalAttrs.version}/sof-bin-${finalAttrs.version}.tar.gz";
    hash = "sha256-Uz9j46bZTAnOBaeCZXtnX6aD/yB4fAl5Imz1Y+x59Rc=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/firmware/intel
    # copy sof and sof-* recursively, preserving symlinks
    cp -R -d sof{,-*} $out/lib/firmware/intel/

    runHook postInstall
  '';

  dontFixup = true; # binaries must not be stripped or patchelfed
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Sound Open Firmware";
    homepage = "https://www.sofproject.org/";
    changelog = "https://github.com/thesofproject/sof-bin/releases/tag/v${finalAttrs.version}";

    license = with lib.licenses; [
      bsd3
      isc
    ];

    sourceProvenance = with lib.sourceTypes; [ binaryFirmware ];

    maintainers = with lib.maintainers; [
      lblasc
      evenbrenden
      hmenke
    ];

    platforms = with lib.platforms; linux;
  };
})
