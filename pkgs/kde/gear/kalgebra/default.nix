{
  mkKdeDerivation,
  ncurses,
  qtsvg,
  qtwebengine,
  readline,
}:
mkKdeDerivation {
  pname = "kalgebra";

  extraBuildInputs = [
    qtsvg
    qtwebengine
    ncurses
    readline
  ];
}
