{
  lib,
  fetchurl,
  stdenvNoCC,
  unzip,
}:
let
  info = lib.importJSON ./info.json;
in
stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (info) version;
  pname = "the-unarchiver";
  src = fetchurl { inherit (info) url hash; };
  nativeBuildInputs = [ unzip ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    mv "The Unarchiver.app" $out/Applications

    runHook postInstall
  '';

  sourceRoot = ".";
  passthru.updateScript = ./update/update.mjs;

  meta = {
    description = "Unpacks archive files";
    homepage = "https://theunarchiver.com/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ xiaoxiangmoe ];

    platforms = [
      "aarch64-darwin"
    ];
  };
})
