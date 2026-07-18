{
  lib,
  stdenv,
  fetchurl,
  flex,
  ncurses,
  readline,
  texinfo,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cgdb";
  version = "0.8.0";

  src = fetchurl {
    url = "https://cgdb.me/files/cgdb-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-DTi1JNN3JXsQa61thW2K4zBBQOHuJAhTQ+bd8bZYEfE=";
  };

  patches = [
    ./gcc14.patch
  ];

  strictDeps = true;

  nativeBuildInputs = [
    flex
    texinfo
  ];

  buildInputs = [
    ncurses
    readline
  ];

  meta = {
    description = "Curses interface to gdb";
    homepage = "https://cgdb.github.io/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = with lib.platforms; linux ++ cygwin;
    mainProgram = "cgdb";
  };
})
