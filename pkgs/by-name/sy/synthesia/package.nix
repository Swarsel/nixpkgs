{
  lib,
  fetchurl,
  copyDesktopItems,
  makeDesktopItem,
  runtimeShell,
  stdenvNoCC,
  wineWow64Packages,
}:

let
  icon = fetchurl {
    hash = "sha256-M9cQqHwwjko5pchdNtIMjYwd4joIvBphAYnpw73qYzM=";
    name = "synthesia.png";
    url = "https://cdn.synthesia.app/images/headerIcon.png";
  };
in
stdenvNoCC.mkDerivation rec {
  pname = "synthesia";
  version = "10.9";

  src = fetchurl {
    url = "https://cdn.synthesia.app/files/Synthesia-${version}-installer.exe";
    hash = "sha256-BFTsbesfMqxY1731ss6S0w8BcUaoqjVrr62VeU1BfrU=";
  };

  nativeBuildInputs = [
    copyDesktopItems
    wineWow64Packages.stable
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cat <<'EOF' > $out/bin/synthesia
    #!${runtimeShell}
    export PATH=${wineWow64Packages.stable}/bin:$PATH
    export WINEARCH=win64
    export WINEPREFIX="''${SYNTHESIA_HOME:-"''${XDG_DATA_HOME:-"''${HOME}/.local/share"}/synthesia"}/wine"
    export WINEDLLOVERRIDES="mscoree=" # disable mono
    if [ ! -d "$WINEPREFIX" ] ; then
      mkdir -p "$WINEPREFIX"
      wine ${src} /S
    fi
    wine "$WINEPREFIX/drive_c/Program Files (x86)/Synthesia/Synthesia.exe"
    EOF
    chmod +x $out/bin/synthesia
    install -Dm644 ${icon} $out/share/icons/hicolor/48x48/apps/synthesia.png
    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Game"
        "Audio"
      ];

      comment = meta.description;
      desktopName = "Synthesia";
      exec = "synthesia";
      icon = "synthesia";
      name = "synthesia";
      startupWMClass = "synthesia.exe";
    })
  ];

  dontBuild = true;
  dontUnpack = true;

  meta = {
    description = "Fun way to learn how to play the piano";
    homepage = "https://synthesiagame.com/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ ners ];
    platforms = wineWow64Packages.stable.meta.platforms;
    downloadPage = "https://synthesiagame.com/download";
  };
}
