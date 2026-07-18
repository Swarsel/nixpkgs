{
  lib,
  fetchurl,
  bison,
  flex,
  mkKdeDerivation,
}:
mkKdeDerivation rec {
  pname = "kdevelop-pg-qt";
  version = "2.4.0";

  src = fetchurl {
    url = "mirror://kde/stable/kdevelop-pg-qt/${version}/src/kdevelop-pg-qt-${version}.tar.xz";
    hash = "sha256-rL62HIL116ot3PoY477l4lWRBpcL1tFG1GyV+NAnu4Y=";
  };

  # Breaks with split -dev
  outputs = [ "out" ];

  extraNativeBuildInputs = [
    bison
    flex
  ];

  meta.license = with lib.licenses; [
    bsd3
    gpl2Plus
    gpl3Plus
    lgpl2Only
    lgpl2Plus
    mit
  ];
}
