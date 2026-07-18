{ libsbuf, mkDerivation }:
mkDerivation {
  buildInputs = [ libsbuf ];
  MK_TESTS = "no";
  extraPaths = [ "lib/libc/locale" ];
  path = "usr.bin/locale";
}
