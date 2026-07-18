{ libsysdecode, mkDerivation }:
mkDerivation {
  buildInputs = [ libsysdecode ];
  path = "usr.bin/truss";
}
