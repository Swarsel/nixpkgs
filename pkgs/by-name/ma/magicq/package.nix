{
  lib,
  stdenv,
  fetchurl,
  alsa-lib-with-plugins,
  autoPatchelfHook,
  copyDesktopItems,
  dpkg,
  ffmpeg_4,
  libGL,
  libGLU,
  libarchive,
  libgcc,
  libusb-compat-0_1,
  libusb1,
  libz,
  makeDesktopItem,
  portaudio,
  qt5,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "magicq";
  version = "1.9.7.3";

  src = fetchurl {
    url = "https://secure.chamsys.co.uk/downloads/v${finalAttrs.src_version}/magicq_ubuntu_v${finalAttrs.src_version}.deb";
    hash = "sha256-FsVSt9iIhwL/wI2XYmKJrA7800wFQ2qJ/uF3bbMLw0Q=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
    dpkg
    qt5.wrapQtAppsHook
  ];

  buildInputs = [
    alsa-lib-with-plugins
    ffmpeg_4
    libGL
    libGLU
    libarchive
    libgcc
    qt5.qtbase
    qt5.qtmultimedia
    qt5.qtbase
    libusb-compat-0_1
    libusb1
    libz
    portaudio
  ];

  installPhase = ''
    mkdir $out
    cp -r . $out
    rm -r $out/opt/magicq/lib
    rm $out/opt/magicq/plugins/imageformats/libqtiff.so
    rm $out/opt/magicq/plugins/printsupport/libcupsprintersupport.so
    rm $out/opt/magicq/plugins/mediaservice/libgstcamerabin.so
    mv $out/usr/share $out/share
    runHook postInstall
  '';

  postFixup = ''
    mkdir $out/bin
    makeWrapper $out/opt/magicq/bin/mqqt $out/bin/magicq \
    --chdir $out/opt/magicq
    wrapQtApp $out/bin/magicq
    sed "s|@out@|$out|g" -i $out/share/applications/magicq.desktop
  '';

  __structuredAttrs = true;

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "AudioVideo"
        "Qt"
      ];

      desktopName = "MagicQ by ChamSys Ltd.";
      exec = "@out@/bin/magicq";
      genericName = "MagicQ";
      icon = "magicq";
      name = "magicq";
      path = "@out@/opt/magicq/";
    })
  ];

  src_version = builtins.replaceStrings [ "." ] [ "_" ] finalAttrs.version;

  meta = {
    description = "MagicQ Lighting Console Software";
    homepage = "https://chamsyslighting.com/product/magicq-software/";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = with lib.maintainers; [ panakotta00 ];
    platforms = lib.platforms.linux;
    mainProgram = "magicq";
  };
})
