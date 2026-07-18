{
  lib,
  stdenv,
  autoreconfHook,
  curl,
  fetchhg,
  libjpeg,
  libpng,
  libxext,
  libxft,
  libxi,
  libxinerama,
  libxtst,
  libxv,
  libxxf86vm,
  lirc,
  ncurses,
  perl,
  pkg-config,
  readline,
  shared-mime-info,
  xine-lib,
  xorgproto,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xine-ui";
  version = "0.99.14-unstable-2024-08-26";

  src = fetchhg {
    url = "http://hg.code.sf.net/p/xine/xine-ui";
    rev = "2beaad6bb92e6732585f68af2e346a24e5ad53a5";
    hash = "sha256-Y08JX9q4w6pSJRCa5mWN11BnA6mZJSO/yn3X8YyZ6E4=";
  };

  outputs = [
    "out"
    "dev"
    "lib"
    "man"
  ];

  postPatch = ''
    substituteInPlace src/common/getopt.h \
      --replace-fail 'extern int getopt ();' 'extern int getopt (int ___argc, char *const *___argv, const char *__shortopts);'
  '';

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    shared-mime-info
    perl
  ];

  buildInputs = [
    curl
    libxext
    libxft
    libxi
    libxinerama
    libxtst
    libxv
    libxxf86vm
    libjpeg
    libpng
    lirc
    ncurses
    readline
    xine-lib
    xorgproto
  ];

  configureFlags = [ "--with-readline=${readline.dev}" ];

  env = {
    LIRC_CFLAGS = "-I${lib.getInclude lirc}/include";
    LIRC_LIBS = "-L ${lib.getLib lirc}/lib -llirc_client";
  };

  meta = {
    description = "Xlib-based frontend for Xine video player";
    homepage = "https://xine.sourceforge.net/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "xine";
  };
})
