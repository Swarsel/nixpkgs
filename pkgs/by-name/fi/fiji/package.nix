{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  copyDesktopItems,
  jdk11,
  makeDesktopItem,
  makeWrapper,
  runtimeShell,
  unzip,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fiji";
  version = "20250408-1717";

  src = fetchurl {
    url = "https://downloads.imagej.net/fiji/archive/${finalAttrs.version}/fiji-nojre.zip";
    sha256 = "sha256-bqVrTBKII58E7WSlQfRPE0Dxd4h/oJALFvIOdAAFZoI=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    wrapGAppsHook3
    makeWrapper
    copyDesktopItems
    unzip
  ];

  buildInputs = [ (lib.getLib stdenv.cc.cc) ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,fiji,share/icons/hicolor/256x256/apps}

    cp -R * $out/fiji
    rm -f $out/fiji/jars/imagej-updater-*.jar

    # Don't create a local desktop entry and avoid deprecated garbage
    # collection option
    cat <<EOF > $out/bin/.fiji-launcher-hack
    #!${runtimeShell}
    exec \$($out/fiji/ImageJ-linux64 --default-gc --dry-run "\$@")
    EOF
    chmod +x $out/bin/.fiji-launcher-hack

    makeWrapper $out/bin/.fiji-launcher-hack $out/bin/fiji \
      --prefix PATH : ${lib.makeBinPath [ jdk11 ]} \
      --set JAVA_HOME ${jdk11.home} \
      ''${gappsWrapperArgs[@]}

    ln $out/fiji/images/icon.png $out/share/icons/hicolor/256x256/apps/fiji.png

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Education"
        "Science"
        "ImageProcessing"
      ];

      comment = "Scientific Image Analysis";
      desktopName = "Fiji Is Just ImageJ";
      exec = "fiji %F";
      genericName = "Fiji Is Just ImageJ";
      icon = "fiji";
      mimeTypes = [ "image/*" ];
      name = "fiji";
      startupNotify = true;
      startupWMClass = "fiji-Main";
      tryExec = "fiji";
    })
  ];

  dontBuild = true;
  dontWrapGApps = true;

  meta = {
    description = "Batteries-included distribution of ImageJ2, bundling a lot of plugins which facilitate scientific image analysis";
    homepage = "https://imagej.net/software/fiji/";

    license = with lib.licenses; [
      gpl2Plus
      gpl3Plus
      bsd2
      publicDomain
    ];

    sourceProvenance = with lib.sourceTypes; [
      binaryBytecode
      binaryNativeCode
    ];

    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "fiji";
  };
})
