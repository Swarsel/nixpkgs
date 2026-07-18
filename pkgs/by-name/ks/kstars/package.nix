{
  lib,
  stdenv,
  fetchurl,
  cfitsio,
  cmake,
  curl,
  eigen,
  fetchpatch2,
  gsl,
  indi-full,
  kdePackages,
  libnova,
  libraw,
  libsecret,
  libxisf,
  opencv,
  pkg-config,
  stellarsolver,
  wcslib,
  xplanet,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "kstars";
  version = "3.8.3";

  src = fetchurl {
    url = "mirror://kde/stable/kstars/${finalAttrs.version}/kstars-${finalAttrs.version}.tar.xz";
    hash = "sha256-xez++JWHcQIx5Mk+TUeBrhcnbQNE4tqX31T9bthqGdU=";
  };

  nativeBuildInputs = with kdePackages; [
    extra-cmake-modules
    kdoctools
    wrapQtAppsHook
    cmake
    pkg-config
  ];

  buildInputs = with kdePackages; [
    breeze-icons
    cfitsio
    curl
    eigen
    gsl
    indi-full
    kconfig
    kdoctools
    kguiaddons
    ki18n
    kiconthemes
    kio
    knewstuff
    knotifyconfig
    kplotting
    kwidgetsaddons
    kxmlgui
    libnova
    libraw
    libsecret
    libxisf
    opencv
    qtdatavis3d
    qtkeychain
    qtsvg
    qtwayland
    qtwebsockets
    stellarsolver
    wcslib
    xplanet
    zlib
  ];

  cmakeFlags = with lib.strings; [
    (cmakeBool "BUILD_WITH_QT6" true)
    (cmakeFeature "INDI_PREFIX" "${indi-full}")
    (cmakeFeature "XPLANET_PREFIX" "${xplanet}")
    (cmakeFeature "DATA_INSTALL_DIR" (placeholder "out") + "/share/kstars/")
  ];

  meta = {
    description = "Virtual planetarium astronomy software";

    longDescription = ''
      It provides an accurate graphical simulation of the night sky, from any location on Earth, at any date and time.
      The display includes up to 100 million stars, 13.000 deep-sky objects, all 8 planets, the Sun and Moon, and thousands of comets, asteroids, supernovae, and satellites.
      For students and teachers, it supports adjustable simulation speeds in order to view phenomena that happen over long timescales, the KStars Astrocalculator to predict conjunctions, and many common astronomical calculations.
    '';

    homepage = "https://kde.org/applications/education/org.kde.kstars";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      timput
      returntoreality
    ];

    platforms = lib.platforms.linux;
    mainProgram = "kstars";
  };
})
