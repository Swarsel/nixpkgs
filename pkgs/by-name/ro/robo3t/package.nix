{
  lib,
  stdenv,
  fetchurl,
  curlWithGnuTls,
  dbus,
  fontconfig,
  freetype,
  glib,
  libGL,
  libice,
  libsm,
  libx11,
  libxcb,
  libxext,
  libxi,
  libxrender,
  makeDesktopItem,
  makeWrapper,
  xkeyboard_config,
  zlib,
}:

stdenv.mkDerivation rec {
  pname = "robo3t";
  version = "1.4.3";

  src = fetchurl {
    url = "https://github.com/Studio3T/robomongo/releases/download/v${version}/robo3t-${version}-linux-x86_64-${rev}.tar.gz";
    sha256 = "sha256-pH4q/O3bq45ZZn+s/12iScd0WbfkcLjK4MBdVCMXK00=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    BASEDIR=$out/lib/robo3t

    mkdir -p $BASEDIR/bin
    cp bin/* $BASEDIR/bin

    mkdir -p $BASEDIR/lib
    cp -r lib/* $BASEDIR/lib

    mkdir -p $out/share/applications
    cp $desktopItem/share/applications/* $out/share/applications

    mkdir -p $out/share/icons
    cp ${icon} $out/share/icons/robomongo.png

    patchelf --set-interpreter ${stdenv.cc.libc}/lib/ld-linux-x86-64.so.2 $BASEDIR/bin/robo3t

    mkdir $out/bin

    makeWrapper $BASEDIR/bin/robo3t $out/bin/robo3t \
      --suffix LD_LIBRARY_PATH : ${ldLibraryPath} \
      --suffix QT_XKB_CONFIG_ROOT : ${xkeyboard_config}/share/X11/xkb

    runHook postInstall
  '';

  desktopItem = makeDesktopItem {
    categories = [
      "Development"
      "IDE"
    ];

    comment = "Query GUI for mongodb";
    desktopName = "Robo3T";
    exec = "robo3t";
    genericName = "MongoDB management tool";
    icon = icon;
    name = "robo3t";
  };

  icon = fetchurl {
    sha256 = "sha256-2PkUxBq2ow0wl09k8B6LJJUQ+y4GpnmoAeumKN1u5xg=";
    url = "https://github.com/Studio3T/robomongo/raw/${rev}/install/macosx/robomongo.iconset/icon_128x128.png";
  };

  ldLibraryPath = lib.makeLibraryPath [
    stdenv.cc.cc
    zlib
    glib
    libxi
    libxcb
    libxrender
    libx11
    libsm
    libice
    libxext
    dbus
    fontconfig
    freetype
    libGL
    curlWithGnuTls
  ];

  rev = "48f7dfd";

  meta = {
    description = "Query GUI for mongodb. Formerly called Robomongo";
    homepage = "https://robomongo.org/";
    license = lib.licenses.gpl3Only;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ eperuffo ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "robo3t";
  };
}
