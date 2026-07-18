{
  lib,
  stdenv,
  fetchurl,
  bison,
  cfitsio,
  cmake,
  discount,
  fetchpatch,
  fftw,
  flex,
  gsl,
  hdf5,
  kdePackages,
  libcerf,
  lz4,
  matio,
  netcdf,
  pkg-config,
  poppler,
  qt6,
  readstat,
  shared-mime-info,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "labplot";
  version = "2.12.1";

  src = fetchurl {
    url = "mirror://kde/stable/labplot/labplot-${finalAttrs.version}.tar.xz";
    hash = "sha256-4oFVv930DltvfEeRMTVW0eSBOARPIW8hDVFbn21sEGo=";
  };

  patches = [
    # backport build fix
    # FIXME: remove in next update
    (fetchpatch {
      hash = "sha256-0biKZXWMs5y1U9phAivEAbd2N4C/CiOKvk/QRAaPimo=";
      url = "https://invent.kde.org/education/labplot/-/commit/c2db2ec28aa8958f7041ae5cd03ddae9f44e5aa3.diff";
    })
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    kdePackages.extra-cmake-modules
    shared-mime-info
    bison
    flex
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase

    kdePackages.karchive
    kdePackages.kcompletion
    kdePackages.kconfig
    kdePackages.kcoreaddons
    kdePackages.kcrash
    kdePackages.kdoctools
    kdePackages.ki18n
    kdePackages.kiconthemes
    kdePackages.kio
    kdePackages.knewstuff
    kdePackages.kparts
    kdePackages.ktextwidgets
    kdePackages.kxmlgui

    kdePackages.syntax-highlighting
    gsl

    kdePackages.poppler
    fftw
    hdf5
    netcdf
    cfitsio
    libcerf
    kdePackages.cantor
    zlib
    lz4
    readstat
    matio
    qt6.qtserialport
    discount
  ];

  cmakeFlags = [
    "-DQT_FIND_PRIVATE_MODULES=ON"
  ];

  meta = {
    description = "Free, open source and cross-platform data visualization and analysis software accessible to everyone";
    homepage = "https://labplot.kde.org";

    license = with lib.licenses; [
      asl20
      bsd3
      cc-by-30
      cc0
      gpl2Only
      gpl2Plus
      gpl3Only
      gpl3Plus
      lgpl3Plus
      mit
    ];

    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "labplot2";
  };
})
