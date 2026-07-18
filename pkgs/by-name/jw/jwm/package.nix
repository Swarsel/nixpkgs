{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  expat,
  fontconfig,
  freetype,
  gettext,
  gitUpdater,
  libjpeg,
  libpng,
  librsvg,
  libx11,
  libxau,
  libxdmcp,
  libxext,
  libxft,
  libxinerama,
  libxmu,
  libxpm,
  libxrender,
  pango,
  pkg-config,
  which,
  xorgproto,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "jwm";
  version = "2.4.6";

  src = fetchFromGitHub {
    owner = "joewing";
    repo = "jwm";
    tag = "v${finalAttrs.version}";
    hash = "sha256-odGqHdm8xnjEcXmpKMy51HEhbjcROLL3hRSdlbmTr2g=";
  };

  postPatch = ''
    sed -i '/AM_ICONV/i AC_CONFIG_MACRO_DIRS([m4])' configure.ac
  '';

  nativeBuildInputs = [
    autoconf
    automake
    gettext
    pkg-config
    which
  ];

  buildInputs = [
    expat
    fontconfig
    freetype
    libx11
    libxau
    libxdmcp
    libxext
    libxft
    libxinerama
    libxmu
    libxpm
    libjpeg
    libpng
    librsvg
    pango
    libxrender
    xorgproto
  ];

  preConfigure = "NOCONFIGURE=1 ./autogen.sh";
  enableParallelBuilding = true;

  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
  };

  meta = {
    description = "Joe's Window Manager is a light-weight X11 window manager";
    homepage = "http://joewing.net/projects/jwm/";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.romildo ];
    platforms = lib.platforms.unix;
    mainProgram = "jwm";
  };
})
