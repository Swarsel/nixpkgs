{
  lib,
  stdenv,
  fetchurl,
  libx11,
  libxext,
  libxi,
  libxmu,
  libxt,
  libxtst,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "imwheel";
  version = "1.0.0pre12";

  src = fetchurl {
    url = "mirror://sourceforge/imwheel/imwheel-${finalAttrs.version}.tar.gz";
    sha256 = "2320ed019c95ca4d922968e1e1cbf0c075a914e865e3965d2bd694ca3d57cfe3";
  };

  buildInputs = [
    libx11
    libxext
    libxi
    libxmu
    libxt
    libxtst
  ];

  makeFlags = [
    "sysconfdir=/etc"
    "ETCDIR=/etc"
  ];

  env.NIX_CFLAGS_COMPILE = "-Wno-error=incompatible-pointer-types";

  installFlags = [
    "sysconfdir=${placeholder "out"}/etc"
    "ETCDIR=${placeholder "out"}/etc"
  ];

  meta = {
    description = "Mouse wheel configuration tool for XFree86/Xorg";
    homepage = "https://imwheel.sourceforge.net/";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ jhillyerd ];
    platforms = lib.platforms.linux;
    mainProgram = "imwheel";
  };
})
