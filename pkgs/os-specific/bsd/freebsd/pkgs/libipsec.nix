{ buildPackages, mkDerivation }:
mkDerivation {
  extraNativeBuildInputs = [
    buildPackages.byacc
    buildPackages.flex
  ];

  path = "lib/libipsec";
}
