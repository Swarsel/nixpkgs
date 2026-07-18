{ libcurses, mkDerivation }:
mkDerivation {
  buildInputs = [ libcurses ];
  path = "usr.bin/top";
}
