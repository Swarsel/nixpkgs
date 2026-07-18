{
  lib,
  android-tools,
  autoPatchelfHook,
  copyDesktopItems,
  fetchzip,
  gdk-pixbuf,
  gobject-introspection,
  jre,
  makeDesktopItem,
  makeWrapper,
  stdenvNoCC,
  wrapGAppsHook3,
}:

stdenvNoCC.mkDerivation rec {
  pname = "agi";
  version = "3.3.1";

  src = fetchzip {
    url = "https://github.com/google/agi/releases/download/${version}/agi-${version}-linux.zip";
    sha256 = "sha256-Yawl6InBYSWNw3clHyGAeC2PVfXEzWmbd6vcYrqAPO0=";
  };

  nativeBuildInputs = [
    wrapGAppsHook3
    gdk-pixbuf
    gobject-introspection
    autoPatchelfHook
    copyDesktopItems
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp ./{agi,gapis,gapir,gapit,device-info} $out/bin
    cp -r lib $out

    for i in 16 32 48 64 96 128 256 512 1024; do
      install -D ${src}/icon.png $out/share/icons/hicolor/''${i}x$i/apps/agi.png
    done

    runHook postInstall
  '';

  preFixup = ''
    wrapProgram $out/bin/agi \
      --add-flags "--vm ${jre}/bin/java" \
      --add-flags "--adb ${android-tools}/bin/adb" \
      --add-flags "--jar $out/lib/gapic.jar" \
      "''${gappsWrapperArgs[@]-}"
  '';

  desktopItems = lib.toList (makeDesktopItem {
    categories = [
      "Development"
      "Debugger"
      "Graphics"
      "3DGraphics"
    ];

    desktopName = "Android GPU Inspector";
    exec = "agi";
    icon = "agi";
    name = "agi";
  });

  dontWrapGApps = true;

  meta = {
    description = "Android GPU Inspector";
    homepage = "https://gpuinspector.dev";
    changelog = "https://github.com/google/agi/releases/tag/v${version}";
    license = lib.licenses.asl20;

    sourceProvenance = with lib.sourceTypes; [
      binaryBytecode
      binaryNativeCode
    ];

    maintainers = with lib.maintainers; [ kashw2 ];
    platforms = [ "x86_64-linux" ];
  };
}
