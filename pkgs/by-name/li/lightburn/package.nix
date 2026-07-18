{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  autoPatchelfHook,
  copyDesktopItems,
  cups,
  e2fsprogs,
  fontconfig,
  freetype,
  libGL,
  libgpg-error,
  libusb1,
  libx11,
  libxcb,
  makeDesktopItem,
  makeWrapper,
  nspr,
  nss,
  p7zip,
}:

stdenv.mkDerivation rec {
  pname = "lightburn";
  version = "1.7.08";

  src = fetchurl {
    url = "https://release.lightburnsoftware.com/LightBurn/Release/LightBurn-v${version}/LightBurn-Linux64-v${version}.7z";
    hash = "sha256-dG/A39/SapyS6GGSKCsHUvYN+CONul/s55HTi9Cc59g=";
  };

  nativeBuildInputs = [
    p7zip
    autoPatchelfHook
    copyDesktopItems
    makeWrapper
  ];

  buildInputs = [
    nss
    nspr
    libusb1
    cups
    libgpg-error
    e2fsprogs
    libx11
    libxcb
    libGL
    alsa-lib
    freetype
    fontconfig
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt
    cp -ar LightBurn $out/opt/lightburn
    install -Dm644 $out/opt/lightburn/LightBurn.png $out/share/icons/hicolor/512x512/apps/lightburn.png

    runHook postInstall
  '';

  postFixup = ''
    mkdir $out/bin
    makeWrapper $out/opt/lightburn/AppRun $out/bin/lightburn \
      --unset QT_PLUGIN_PATH \
      --unset QML2_IMPORT_PATH
  '';

  desktopItems = [
    (makeDesktopItem {
      desktopName = "LightBurn";
      exec = "lightburn";
      genericName = "LightBurn";
      icon = "lightburn";
      name = "lightburn";
    })
  ];

  unpackPhase = ''
    7z x $src
  '';

  meta = {
    description = "Layout, editing, and control software for your laser cutter";
    homepage = "https://lightburnsoftware.com";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ q3k ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "lightburn";
  };
}
