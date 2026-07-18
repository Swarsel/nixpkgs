{
  lib,
  stdenv,
  fetchurl,
  ncurses,
  readline,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ytree";
  version = "2.12";

  src = fetchurl {
    url = "https://han.de/~werner/ytree-${finalAttrs.version}.tar.gz";
    hash = "sha256-I2bS1fwfZERgMjhj5b6ZdFhLybLWbXJHFlqP8aCZERQ=";
  };

  patches = [
    # Two fixups (because diff files can't be smaller):
    # - Create PREFIX instead of using DESTDIR
    # - use gzip without timestamp, to improve reproducibility
    ./0001-use-prefix-and-gzip-n.diff
  ];

  buildInputs = [
    ncurses
    readline
  ];

  makeFlags = [ "CC=${stdenv.cc.targetPrefix}cc" ];

  preInstall = ''
    mkdir -p $out/bin $out/share/man/man1
  '';

  installFlags = [ "PREFIX=${placeholder "out"}" ];

  meta = {
    description = "Curses-based file manager similar to DOS Xtree(TM)";
    homepage = "https://www.han.de/~werner/ytree.html";
    license = with lib.licenses; [ gpl2Plus ];
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "ytree";
  };
})
# TODO: X11 support
