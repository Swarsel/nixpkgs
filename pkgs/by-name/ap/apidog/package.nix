{
  lib,
  fetchurl,
  appimageTools,
  makeDesktopItem,
}:

let
  pname = "apidog";
  version = "2.8.36";

  src = fetchurl {
    url = "https://file-assets.apidog.com/download/${version}/Apidog-${version}.AppImage";
    hash = "sha256-IlIt00NQw1InLba/3Zax25yRsn8ZbiBfuA6CRx6veTg=";
  };

  appimageContents = appimageTools.extract {
    inherit pname version src;
  };

  desktopItem = makeDesktopItem {
    categories = [
      "Development"
      "Utility"
    ];

    comment = "All-in-One API Platform: Design, Debug, Mock, Test, and Document.";
    desktopName = "Apidog";
    exec = "apidog %U";
    icon = "apidog";
    mimeTypes = [ "x-scheme-handler/apidog" ];
    name = "apidog";
  };
in
appimageTools.wrapType2 {
  inherit pname version src;
  desktopItems = [ desktopItem ];

  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/apidog.png \
      $out/share/icons/hicolor/512x512/apps/apidog.png
  '';

  extraPkgs = pkgs: [
    pkgs.nss
    pkgs.gtk3
    pkgs.libx11
    pkgs.libxcb
    pkgs.libxrandr
    pkgs.libxcomposite
    pkgs.libxdamage
    pkgs.libxfixes
    pkgs.libxext
    pkgs.libdbusmenu
    pkgs.alsa-lib
    pkgs.nodejs
  ];

  meta = with lib; {
    description = "All-in-one API design, test, mock and documentation platform";
    homepage = "https://apidog.com";
    license = licenses.unfree;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    maintainers = with maintainers; [ DomagojAlaber ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "apidog";
  };
}
