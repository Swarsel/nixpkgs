{
  libncurses,
  libncurses-tinfo,
  mkDerivation,
}:
mkDerivation {
  pname = "ncurses-form";

  buildInputs = [
    libncurses-tinfo
    libncurses
  ];

  extraPaths = [
    "lib/ncurses"
    "contrib/ncurses"
    "lib/Makefile.inc"
  ];

  path = "lib/ncurses/form";
}
