{
  lib,
  stdenv,
  fetchurl,
  freetype,
  gettext,
  intltool,
  libGL,
  libGLU,
  libglut,
  libice,
  libpng,
  libsm,
  libx11,
  libxext,
  libxi,
  libxmu,
  libxt,
  pkg-config,
  sfml_2,
  tcl,
  xorgproto,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "extremetuxracer";
  version = "0.8.4";

  src = fetchurl {
    url = "mirror://sourceforge/extremetuxracer/etr-${finalAttrs.version}.tar.xz";
    hash = "sha256-+jKFzAx1Wlr/Up8/LOo1FkgRFMa0uOHsB2n+7/BHc+U=";
  };

  nativeBuildInputs = [
    pkg-config
    intltool
  ];

  buildInputs = [
    libGLU
    libGL
    libx11
    xorgproto
    tcl
    libglut
    freetype
    sfml_2
    libxi
    libxmu
    libxext
    libxt
    libsm
    libice
    libpng
    gettext
  ];

  configureFlags = [ "--with-tcl=${tcl}/lib" ];

  preConfigure = ''
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE"
  '';

  meta = {
    description = "High speed arctic racing game based on Tux Racer";

    longDescription = ''
      ExtremeTuxRacer - Tux lies on his belly and accelerates down ice slopes.
    '';

    homepage = "https://sourceforge.net/projects/extremetuxracer/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = with lib.platforms; linux;
    mainProgram = "etr";
  };
})
