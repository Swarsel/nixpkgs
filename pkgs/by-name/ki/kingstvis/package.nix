{
  lib,
  buildFHSEnv,
  dbus,
  fetchzip,
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
  xkeyboard_config,
  zlib,
}:

let
  pname = "kingstvis";
  version = "3.6.1";
  src = fetchzip {
    url = "http://res.kingst.site/kfs/KingstVIS_v${version}.tar.gz";
    hash = "sha256-eZJ3RZWdmNx/El3Hh5kUf44pIwdvwOEkRysYBgUkS18=";
  };
in

buildFHSEnv {
  inherit pname version;

  extraInstallCommands = ''
    install -Dvm644 ${src}/Driver/99-Kingst.rules \
      $out/lib/udev/rules.d/99-Kingst.rules
  '';

  runScript = "${src}/KingstVIS";

  targetPkgs = pkgs: [
    dbus
    fontconfig
    freetype
    glib
    libGL
    xkeyboard_config
    libice
    libsm
    libx11
    libxext
    libxi
    libxrender
    libxcb
    zlib
  ];

  meta = {
    description = "Kingst Virtual Instruments Studio, software for logic analyzers";
    homepage = "http://www.qdkingst.com/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = [ lib.maintainers.luisdaranda ];
    platforms = [ "x86_64-linux" ];
  };
}
