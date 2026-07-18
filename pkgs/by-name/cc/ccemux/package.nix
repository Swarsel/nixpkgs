{
  lib,
  stdenv,
  fetchurl,
  jre,
  makeDesktopItem,
  makeWrapper,
  useCCTweaked ? true,
}:

let
  version = "unstable-2023-07-08";
  rev = "989cfe52a0458b991e0a7d87edec81d3fef472ac";

  baseUrl = "https://emux.cc/versions/${lib.substring 0 8 rev}/CCEmuX";
  jar =
    if useCCTweaked then
      fetchurl {
        hash = "sha256-nna5KRp6jVLkbWKOHGtQqaPr3Zl05mVkCf/8X9C5lRY=";
        url = "${baseUrl}-cct.jar";
      }
    else
      fetchurl {
        hash = "sha256-2Z38O6z7OrHKe8GdLnexin749uJzQaCZglS+SwVD5YE=";
        url = "${baseUrl}-cc.jar";
      };

  desktopIcon = fetchurl {
    hash = "sha256-gqWURXaOFD/4aZnjmgtKb0T33NbrOdyRTMmLmV42q+4=";
    url = "https://github.com/CCEmuX/CCEmuX/raw/${rev}/src/main/resources/img/icon.png";
  };
  desktopItem = makeDesktopItem {
    categories = [ "Emulator" ];
    comment = "A modular ComputerCraft emulator";
    desktopName = "CCEmuX";
    exec = "ccemux";
    genericName = "ComputerCraft Emulator";
    icon = desktopIcon;
    name = "CCEmuX";
  };
in

stdenv.mkDerivation (finalAttrs: {
  inherit version;
  pname = "ccemux";
  src = jar;
  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ jre ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,share/ccemux}
    cp -r ${desktopItem}/share/applications $out/share/applications

    install -D ${finalAttrs.src} $out/share/ccemux/ccemux.jar
    install -D ${desktopIcon} $out/share/icons/hicolor/256x256/apps/ccemux.png

    makeWrapper ${jre}/bin/java $out/bin/ccemux \
      --add-flags "-jar $out/share/ccemux/ccemux.jar"

    runHook postInstall
  '';

  dontUnpack = true;

  meta = {
    description = "Modular ComputerCraft emulator";
    homepage = "https://github.com/CCEmuX/CCEmuX";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];

    maintainers = with lib.maintainers; [
      viluon
    ];

    mainProgram = "ccemux";
  };
})
