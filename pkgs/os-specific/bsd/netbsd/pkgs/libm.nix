{ lib, mkDerivation }:

mkDerivation {
  outputs = [
    "out"
    "man"
  ];

  SHLIBINSTALLDIR = "$(out)/lib";
  extraPaths = [ "sys" ];
  libcMinimal = true;
  path = "lib/libm";
  meta.platforms = lib.platforms.netbsd;
}
