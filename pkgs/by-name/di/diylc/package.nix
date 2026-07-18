{
  lib,
  stdenv,
  fetchurl,
  copyDesktopItems,
  jdk17,
  makeBinaryWrapper,
  makeDesktopItem,
  unzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "diylc";
  version = "5.11.0";

  src = fetchurl {
    url = "https://github.com/bancika/diy-layout-creator/releases/download/v${finalAttrs.version}/diylc-${finalAttrs.version}-universal.zip";
    hash = "sha256-peSxUdlqcS0gvlSzf6OgC0vJ6FIounauY0TaMjDX0ZI=";
  };

  nativeBuildInputs = [
    copyDesktopItems
    unzip
    makeBinaryWrapper
  ];

  installPhase = ''
    runHook preInstall

    # Nope, the icon cannot be named 'diylc' because KDE does not like it.
    install -Dm644 icons/icon_16x16.png $out/share/icons/hicolor/16x16/apps/diylc_icon.png
    install -Dm644 icons/icon_32x32.png $out/share/icons/hicolor/32x32/apps/diylc_icon.png
    install -Dm644 icons/icon_48x48.png $out/share/icons/hicolor/48x48/apps/diylc_icon.png
    install -Dm644 icons/icon_64x64.png $out/share/icons/hicolor/64x64/apps/diylc_icon.png
    install -Dm644 icons/icon_512x512.png $out/share/icons/hicolor/512x512/apps/diylc_icon.png
    install -Dm644 diylc.jar $out/app/diylc/diylc.jar
    install -Dm755 run.sh $out/app/diylc/run.sh
    patchShebangs $out/app/diylc/run.sh
    substituteInPlace $out/app/diylc/run.sh \
      --replace-fail '$(which java)' "${jdk17}/bin/java" \
      --replace-fail "exec java" "exec ${jdk17}/bin/java"
    mkdir $out/bin
    makeWrapper $out/app/diylc/run.sh $out/bin/diylc

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Development"
        "Electronics"
      ];

      comment = "Multi platform circuit layout and schematic drawing tool";
      desktopName = "DIY Layout Creator";
      exec = "diylc";
      icon = "diylc_icon";
      name = "diylc";
    })
  ];

  meta = {
    description = "Multi platform circuit layout and schematic drawing tool";
    homepage = "https://bancika.github.io/diy-layout-creator";
    changelog = "https://github.com/bancika/diy-layout-creator/releases";
    license = lib.licenses.gpl3Plus;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "diylc";
  };
})
