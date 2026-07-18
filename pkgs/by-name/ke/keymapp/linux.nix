{
  stdenv,
  autoPatchelfHook,
  copyDesktopItems,
  libsoup_3,
  libusb1,
  makeDesktopItem,
  meta,
  pname,
  src,
  version,
  webkitgtk_4_1,
  wrapGAppsHook4,
  ...
}:
stdenv.mkDerivation {
  inherit
    pname
    version
    src
    meta
    ;

  nativeBuildInputs = [
    copyDesktopItems
    autoPatchelfHook
    wrapGAppsHook4
  ];

  buildInputs = [
    libusb1
    webkitgtk_4_1
    libsoup_3
  ];

  installPhase = ''
    runHook preInstall

    install -m755 -D keymapp "$out/bin/keymapp"
    install -Dm644 icon.png "$out/share/icons/keymapp.png"

    runHook postInstall
  '';

  preFixup = ''
    gappsWrapperArgs+=(--set-default '__NV_PRIME_RENDER_OFFLOAD' 1)
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Settings"
        "HardwareSettings"
      ];

      desktopName = "Keymapp";
      exec = "keymapp";
      icon = "keymapp";
      name = "keymapp";
      type = "Application";
    })
  ];

  sourceRoot = ".";
}
