{
  lib,
  stdenv,
  fetchurl,
  bison,
  dbus,
  flex,
  fontconfig,
  freetype,
  gd,
  gnome2,
  gtk2,
  imagemagick,
  intltool,
  libGL,
  libGLU,
  libxmu,
  libxrender,
  netpbm,
  pkg-config,
  shared-mime-info,
  tcl,
  tk,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pcb";
  version = "4.3.0";

  src = fetchurl {
    url = "mirror://sourceforge/pcb/pcb-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-roUvRq+Eq6f1HYE/uRb8f82+6kP3E08VBQcCThdD+14=";
  };

  nativeBuildInputs = [
    pkg-config
    bison
    intltool
    flex
    netpbm
    imagemagick
  ];

  buildInputs = [
    gtk2
    dbus
    libxrender
    freetype
    fontconfig
    libGLU
    libGL
    tcl
    shared-mime-info
    tk
    gnome2.gtkglext
    gd
    libxmu
  ];

  configureFlags = [
    "--disable-update-desktop-database"
  ];

  meta = {
    description = "Printed Circuit Board editor";
    homepage = "https://sourceforge.net/projects/pcb/";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ mog ];
    platforms = lib.platforms.linux;
  };
})
