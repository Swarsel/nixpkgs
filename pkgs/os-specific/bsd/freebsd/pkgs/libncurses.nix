{
  lib,
  libncurses-tinfo,
  mkDerivation,
  versionData,
  ...
}:
mkDerivation {
  buildInputs = lib.optionals (versionData.major >= 14) [ libncurses-tinfo ];

  preBuild = lib.optionalString (versionData.major >= 14) ''
    make -C ../tinfo $makeFlags curses.h ncurses_dll.h ncurses_def.h
  '';

  # some packages depend on libncursesw.so.8
  postInstall = ''
    ln -s $out/lib/libncursesw.so.9 $out/lib/libncursesw.so.8
  '';

  MK_TESTS = "no";

  extraPaths = [
    "lib/ncurses"
    "contrib/ncurses"
    "lib/Makefile.inc"
  ];

  path = "lib/ncurses/ncurses";
}
