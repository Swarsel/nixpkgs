{ mkDerivation }:

mkDerivation {
  patches = [ ./getent.patch ];
  path = "usr.bin/getent";
}
