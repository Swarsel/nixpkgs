{
  lib,
  buildPackages,
  mkDerivation,
}:
mkDerivation {
  makeFlags = [
    "AWK=${lib.getBin buildPackages.gawk}/bin/awk"
    "HOSTCC=${buildPackages.stdenv.cc}/bin/${buildPackages.stdenv.cc.targetPrefix}cc"
  ];

  path = "lib/libcurses";
}
