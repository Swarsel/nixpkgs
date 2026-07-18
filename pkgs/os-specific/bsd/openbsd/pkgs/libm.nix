{ lib, mkDerivation }:

mkDerivation {
  outputs = [
    "out"
    "man"
  ];

  extraPaths = [ "sys" ];
  libcMinimal = true;
  path = "lib/libm";
  meta.platforms = lib.platforms.openbsd;
}
