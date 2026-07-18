{
  lib,
  stdenv,
  fetchurl,
  SDL,
  SDL_image,
  SDL_mixer,
  SDL_ttf,
  csound,
  cunit,
  curl,
  expat,
  gettext,
  gmp,
  guile_2_0,
  libGL,
  libGLU,
  libcaca,
  libjpeg,
  libogg,
  libpng,
  libtool,
  libvorbis,
  libx11,
  libxrender,
  perl,
  pkg-config,
  readline,
  sqlite,
  xorgproto,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "liquidwar6";
  version = "0.6.3902";

  src = fetchurl {
    url = "mirror://gnu/liquidwar6/liquidwar6-${finalAttrs.version}.tar.gz";
    sha256 = "1976nnl83d8wspjhb5d5ivdvdxgb8lp34wp54jal60z4zad581fn";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    xorgproto
    libx11
    gmp
    guile_2_0
    libjpeg
    libpng
    expat
    gettext
    perl
    SDL
    SDL_image
    SDL_mixer
    SDL_ttf
    curl
    sqlite
    libogg
    libvorbis
    csound
    libxrender
    libcaca
    cunit
    libtool
    readline
    libGL
    libGLU
  ];

  # To avoid problems finding SDL_types.h.
  configureFlags = [ "CFLAGS=-I${lib.getDev SDL}/include/SDL" ];

  env.NIX_CFLAGS_COMPILE = toString (
    lib.optionals (stdenv.cc.isGNU && lib.versionAtLeast stdenv.cc.version "12") [
      # Needed with GCC 12 but problematic with some old GCCs
      "-Wno-error=address"
      "-Wno-error=use-after-free"
      "-std=gnu17"
    ]
    ++ [
      "-Wno-error=deprecated-declarations"
      # Avoid GL_GLEXT_VERSION double definition
      " -DNO_SDL_GLEXT"
    ]
  );

  hardeningDisable = [ "format" ];

  meta = {
    description = "Quick tactics game";
    homepage = "https://www.gnu.org/software/liquidwar6/";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.raskin ];
    platforms = lib.platforms.linux;
  };
})
