{
  lib,
  stdenv,
  fetchzip,
  jdk8,
  makeDesktopItem,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "jpexs";
  version = "24.1.0";

  src = fetchzip {
    url = "https://github.com/jindrapetrik/jpexs-decompiler/releases/download/version${finalAttrs.version}/ffdec_${finalAttrs.version}.zip";
    hash = "sha256-k6cnyiRyU4B5UdsVnY9LpzTO/o7Q9/aRS0Il2jV4PQ0=";
    stripRoot = false;
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/share/{ffdec,icons/hicolor/512x512/apps}

    cp ffdec.jar $out/share/ffdec
    cp -r lib $out/share/ffdec
    cp icon.png $out/share/icons/hicolor/512x512/apps/ffdec.png
    cp -r ${finalAttrs.desktopItem}/share/applications $out/share

    makeWrapper ${jdk8}/bin/java $out/bin/ffdec \
      --add-flags "-jar $out/share/ffdec/ffdec.jar"
  '';

  desktopItem = makeDesktopItem rec {
    categories = [
      "Development"
      "Java"
    ];

    comment = finalAttrs.meta.description;
    desktopName = "JPEXS Free Flash Decompiler";
    exec = name;
    genericName = "Flash Decompiler";
    icon = name;
    name = "ffdec";
    startupWMClass = "com-jpexs-decompiler-flash-gui-Main";
  };

  dontBuild = true;

  meta = {
    description = "Flash SWF decompiler and editor";

    longDescription = ''
      Open-source Flash SWF decompiler and editor. Extract resources,
      convert SWF to FLA, edit ActionScript, replace images, sounds,
      texts or fonts.
    '';

    homepage = "https://github.com/jindrapetrik/jpexs-decompiler";
    license = lib.licenses.gpl3;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];

    maintainers = with lib.maintainers; [
      xrtxn
    ];

    platforms = jdk8.meta.platforms;
    mainProgram = "ffdec";
  };
})
