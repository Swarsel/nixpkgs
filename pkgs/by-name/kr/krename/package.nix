{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
  exiv2,
  kdePackages,
  podofo0,
  taglib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "krename";
  version = "5.0.60-unstable-2025-09-02";

  # For when the next stable release is made
  # src = fetchurl {
  #   url = "mirror://kde/stable/krename/${version}/src/krename-${finalAttrs.version}.tar.xz";
  #   hash = "sha256-sjxgp93Z9ttN1/VaxV/MqKVY+miq+PpcuJ4er2kvI+0=";
  # };
  src = fetchFromGitLab {
    owner = "utilities";
    repo = "krename";
    rev = "5ad5f5a1f0a1c7573fa1b872a1472dec96fe0dd7";
    hash = "sha256-fGNiIGGq10F71wh37aKDB7Q3fCxSXqttg/176LH3nVM=";
    domain = "invent.kde.org";
  };

  nativeBuildInputs = [
    cmake
    kdePackages.extra-cmake-modules
    kdePackages.kdoctools
    kdePackages.wrapQtAppsHook
  ];

  buildInputs = with kdePackages; [
    exiv2
    podofo0
    kio
    kxmlgui
    qtbase
    qtdeclarative
    qt5compat
    taglib
  ];

  env.NIX_LDFLAGS = "-ltag";

  meta = {
    inherit (kdePackages.qtbase.meta) platforms;
    description = "Powerful batch renamer for KDE";
    homepage = "https://kde.org/applications/utilities/krename/";

    license = with lib.licenses; [
      bsd3
      cc0
      gpl2Plus
    ];

    maintainers = with lib.maintainers; [
      peterhoeg
      kuflierl
    ];

    mainProgram = "krename";
  };
})
