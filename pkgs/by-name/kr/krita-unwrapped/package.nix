{
  lib,
  stdenv,
  fetchurl,
  SDL2,
  boost,
  cmake,
  curl,
  eigen_5,
  exiv2,
  fftw,
  fribidi,
  giflib,
  gsl,
  immer,
  kdePackages,
  kseexpr,
  lager,
  lcms2,
  libaom,
  libheif,
  libjxl,
  libmypaint,
  libraw,
  libunibreak,
  libwebp,
  opencolorio,
  openexr,
  openjpeg,
  pkg-config,
  python3Packages,
  qt6,
  xsimd,
  zug,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "krita-unwrapped";
  version = "6.0.2.1";

  src = fetchurl {
    url = "mirror://kde/stable/krita/${finalAttrs.version}/krita-${finalAttrs.version}.tar.gz";
    hash = "sha256-Z1M8sRXewqWYe1r6fdTPjgREuQfNmTSc8dD7ZEVuQPg=";
  };

  # Krita runs custom python scripts in CMake with custom PYTHONPATH which krita determined in their CMake script.
  # Patch the PYTHONPATH so python scripts can import sip successfully.
  postPatch =
    let
      pythonPath = python3Packages.makePythonPath (
        with python3Packages;
        [
          sip
          setuptools
        ]
      );
    in
    ''
      substituteInPlace cmake/modules/FindSIP.cmake \
        --replace 'PYTHONPATH=''${_sip_python_path}' 'PYTHONPATH=${pythonPath}'
      substituteInPlace cmake/modules/SIPMacros.cmake \
        --replace 'PYTHONPATH=''${_krita_python_path}' 'PYTHONPATH=${pythonPath}'

      substituteInPlace plugins/impex/jp2/jp2_converter.cc \
        --replace '<openjpeg.h>' '<${openjpeg.incDir}/openjpeg.h>'
    ''
    # https://invent.kde.org/graphics/krita/-/commit/30182dbfe789c9b44e5762978bf9ebb22c4f72b6
    + ''
      patch -p1 <<EOF
      --- a/cmake/modules/SIPMacros.cmake
      +++ b/cmake/modules/SIPMacros.cmake
      @@ -152,3 +152,3 @@
               if (QT_MAJOR_VERSION STREQUAL "6")
      -            set(abi_version "13.0")
      +            set(abi_version "13.8")
                   set(sip_disabled_features "[\"Krita_Qt5\"]")
      EOF
    '';

  nativeBuildInputs = [
    cmake
    kdePackages.extra-cmake-modules
    pkg-config
    python3Packages.sip
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    boost
    libraw
    fftw
    eigen_5
    exiv2
    fribidi
    lcms2
    gsl
    openexr
    lager
    libaom
    libheif

    giflib
    libjxl
    openjpeg
    opencolorio
    xsimd
    curl
    immer
    kseexpr
    libmypaint
    libunibreak
    libwebp
    SDL2
    zug
    python3Packages.pyqt6

    qt6.qtmultimedia
    qt6.qttools
  ]
  ++ (with kdePackages; [
    breeze-icons
    karchive
    kcompletion
    kconfig
    kcoreaddons
    kcrash
    kguiaddons
    ki18n
    kio
    kitemmodels
    kitemviews
    kwidgetsaddons
    kwindowsystem
    mlt
    poppler
    quazip
    libkdcraw
  ]);

  cmakeFlags = [
    "-DBUILD_WITH_QT6=ON"
    "-DALLOW_UNSTABLE=QT6"
    "-DENABLE_UPDATERS=OFF"
    "-DBUILD_KRITA_QT_DESIGNER_PLUGINS=ON"
  ];

  cmakeBuildType = "RelWithDebInfo";

  meta = {
    description = "Free and open source painting application";
    homepage = "https://krita.org/";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      sifmelcara
    ];

    platforms = lib.platforms.linux;
    mainProgram = "krita";
  };
})
