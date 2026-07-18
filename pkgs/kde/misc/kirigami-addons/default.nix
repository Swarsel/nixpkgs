{
  lib,
  fetchurl,
  kitemmodels,
  mkKdeDerivation,
  qt5compat,
  qtdeclarative,
  qtmultimedia,
  qttools,
}:
mkKdeDerivation rec {
  pname = "kirigami-addons";
  version = "1.12.1";

  src = fetchurl {
    url = "mirror://kde/stable/kirigami-addons/kirigami-addons-${version}.tar.xz";
    hash = "sha256-xUOkk85YdfQF+xyf9tUxBg7QgsxtcQ5W1GrELRZCB7s=";
  };

  extraBuildInputs = [ qtdeclarative ];
  extraNativeBuildInputs = [ qttools ];

  extraPropagatedBuildInputs = [
    qt5compat
    qtmultimedia
    kitemmodels
  ];

  meta.license = with lib.licenses; [
    bsd2
    cc-by-sa-40
    cc0
    gpl2Plus
    lgpl2Only
    lgpl2Plus
    lgpl21Only
    lgpl21Plus
    lgpl3Only
  ];
}
