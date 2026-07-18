{
  lib,
  stdenv,
  copyDesktopItems,
  fetchzip,
  jre,
  makeDesktopItem,
  makeWrapper,
}:
let
  desktopItem = makeDesktopItem {
    categories = [ "Game" ];
    comment = "A cross-platform G-Code sender for GRBL, Smoothieware, TinyG and G2core.";
    desktopName = "Universal-G-Code-Sender";
    exec = "ugs";
    name = "ugs";
  };

in
stdenv.mkDerivation (finalAttrs: {
  pname = "ugs";
  version = "2.1.18";

  src = fetchzip {
    url = "https://github.com/winder/Universal-G-Code-Sender/releases/download/v${finalAttrs.version}/UniversalGcodeSender.zip";
    hash = "sha256-GRoQ9Wg+OyjhBjjRiNVZlMQ6pukvj9i3p9UA+7B/Tww=";
  };

  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall

    makeWrapper ${jre}/bin/java $out/bin/ugs \
      --prefix PATH : ${lib.makeBinPath [ jre ]} \
      --add-flags "-jar ${finalAttrs.src}/UniversalGcodeSender.jar"

    runHook postInstall
  '';

  desktopItems = [ desktopItem ];
  dontUnpack = true;

  meta = {
    description = "Cross-platform G-Code sender for GRBL, Smoothieware, TinyG and G2core";
    homepage = "https://github.com/winder/Universal-G-Code-Sender";
    license = lib.licenses.gpl3;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = with lib.maintainers; [ matthewcroughan ];
    platforms = lib.platforms.all;
    mainProgram = "ugs";
  };
})
