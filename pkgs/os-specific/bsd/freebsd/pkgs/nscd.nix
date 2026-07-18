{ libutil, mkDerivation, ... }:
mkDerivation {
  buildInputs = [ libutil ];
  path = "usr.sbin/nscd";
}
