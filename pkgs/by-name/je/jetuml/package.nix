{
  lib,
  fetchurl,
  copyDesktopItems,
  imagemagick,
  jdk,
  makeBinaryWrapper,
  makeDesktopItem,
  stdenvNoCC,
}:

let
  jdkWithFX = jdk.override { enableJavaFX = true; };
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "jetuml";
  version = "3.9";

  src = fetchurl {
    url = "https://github.com/prmr/JetUML/releases/download/v${finalAttrs.version}/JetUML-${finalAttrs.version}.jar";
    hash = "sha256-wACGbHeRQ5rXcuI1J3eTfQraWp8eWtkIAPo7BNGcFUU=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    makeBinaryWrapper
    copyDesktopItems
    imagemagick
  ];

  installPhase = ''
    runHook preInstall

    ${jdkWithFX}/lib/openjdk/bin/jar xf $src jet.png
    magick jet.png -resize 128x128 jet128.png
    magick jet.png -resize 48x48 jet48.png
    install -Dm444 jet48.png $out/share/icons/hicolor/48x48/apps/jet.png
    install -Dm444 jet128.png $out/share/icons/hicolor/128x128/apps/jet.png

    install -Dm444 $src $out/share/java/JetUML-${finalAttrs.version}.jar

    makeWrapper ${jdkWithFX}/lib/openjdk/bin/java $out/bin/jetuml \
      --add-flags "-jar $out/share/java/JetUML-${finalAttrs.version}.jar"

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Application"
        "Development"
        "ProjectManagement"
      ];

      comment = finalAttrs.meta.description;
      desktopName = "JetUML";
      exec = "jetuml";
      genericName = "UML Tool";
      icon = "jet";
      name = "jetuml";
    })
  ];

  dontUnpack = true;

  meta = {
    description = "Desktop application for fast UML diagramming";
    homepage = "https://www.jetuml.org/";
    license = lib.licenses.gpl3Plus;
    sourceProvenance = [ lib.sourceTypes.binaryBytecode ];
    maintainers = [ lib.maintainers.felissedano ];
    platforms = lib.platforms.all;
    mainProgram = "jetuml";
  };
})
