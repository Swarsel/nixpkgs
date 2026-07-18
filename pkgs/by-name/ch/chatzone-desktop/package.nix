{
  lib,
  fetchurl,
  appimageTools,
  copyDesktopItems,
  makeDesktopItem,
  makeWrapper,
  stdenvNoCC,
}:

let
  pname = "chatzone-desktop";
  version = "5.6.2";
  src = fetchurl {
    url = "https://ir.ozone.ru/s3/chatzone-clients/ci/5.6.2/1175/chatzone-desktop-linux-5.6.2.AppImage";
    hash = "sha256-2t3mp0snHn2NxVFCcU1XQ5h3rUCb4gXjKbF43p9W8ZU=";
  };
  appimageContents = appimageTools.extract { inherit pname version src; };
in
stdenvNoCC.mkDerivation {
  inherit pname version;
  src = appimageTools.wrapType2 { inherit pname version src; };

  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/
    cp -r bin $out/bin

    mkdir -p $out/share/chatzone-desktop/
    cp ${appimageContents}/app_icon.png $out/share/chatzone-desktop/
    cp -r ${appimageContents}/usr/share/icons $out/share

    wrapProgram $out/bin/chatzone-desktop \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}"

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Network"
        "InstantMessaging"
        "Chat"
      ];

      comment = "Chatzone Desktop application for Linux";
      desktopName = "Chatzone";
      exec = "chatzone-desktop";
      genericName = "Ozon corporate messenger";
      icon = "chatzone-desktop";
      mimeTypes = [ "x-scheme-handler/mattermost" ];
      name = "chatzone";
      startupWMClass = "Chatzone";
      terminal = false;
    })
  ];

  meta = {
    description = "Ozon corporate messenger";
    homepage = "https://apps.o3team.ru/";
    license = lib.licenses.unfreeRedistributable;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = [ lib.maintainers.progrm_jarvis ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "chatzone-desktop";
    downloadPage = "https://apps.o3team.ru/";
  };
}
