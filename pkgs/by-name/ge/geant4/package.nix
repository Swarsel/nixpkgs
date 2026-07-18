{
  lib,
  stdenv,
  fetchurl,
  boost,
  callPackage,
  clhep,
  cmake,
  coin3d,
  expat,
  libGL,
  libGLU,
  libGLX,
  libx11,
  libxext,
  libxmu,
  libxpm,
  motif,
  python3,
  qt6,
  soxt,
  xercesc,
  zlib,
  enableInventor ? false,
  enableMultiThreading ? true,
  enableOpenGLX11 ? !stdenv.hostPlatform.isDarwin,
  enablePython ? false,
  enableQt ? false,
  enableRaytracerX11 ? false,
  enableXM ? false,
}:

let
  boost_python = boost.override {
    enablePython = true;
    python = python3;
  };
in

stdenv.mkDerivation (finalAttrs: {
  pname = "geant4";
  version = "11.4.2";

  src = fetchurl {
    url = "https://cern.ch/geant4-data/releases/geant4-v${finalAttrs.version}.tar.gz";
    hash = "sha256-VyDyu6aSECfiBq1PCgb5vMNIras2JA6LJ3EPIM4+lxo=";
  };

  # Fix broken paths in a .pc
  postPatch = ''
    substituteInPlace source/externals/ptl/cmake/Modules/PTLPackageConfigHelpers.cmake \
      --replace '${"$"}{prefix}/${"$"}{PTL_INSTALL_' '${"$"}{PTL_INSTALL_'
  '';

  nativeBuildInputs = [ cmake ];

  buildInputs =
    lib.optionals enableOpenGLX11 [
      libGLU
      libxext
      libxmu
    ]
    ++ lib.optionals enableInventor [
      libxpm
      coin3d
      soxt
      motif
    ]
    ++ lib.optionals enablePython [
      boost_python
      python3
    ];

  propagatedBuildInputs = [
    clhep
    expat
    xercesc
    zlib
  ]
  ++ lib.optionals enableOpenGLX11 [
    libGL
    libx11
  ]
  ++ lib.optionals enableXM [ motif ]
  ++ lib.optionals enableQt [ qt6.qtbase ];

  cmakeFlags = [
    "-DGEANT4_INSTALL_DATA=OFF"
    "-DGEANT4_USE_GDML=ON"
    "-DGEANT4_USE_G3TOG4=ON"
    "-DGEANT4_USE_QT=${if enableQt then "ON" else "OFF"}"
    "-DGEANT4_USE_XM=${if enableXM then "ON" else "OFF"}"
    "-DGEANT4_USE_OPENGL_X11=${if enableOpenGLX11 then "ON" else "OFF"}"
    "-DGEANT4_USE_INVENTOR=${if enableInventor then "ON" else "OFF"}"
    "-DGEANT4_USE_PYTHON=${if enablePython then "ON" else "OFF"}"
    "-DGEANT4_USE_RAYTRACER_X11=${if enableRaytracerX11 then "ON" else "OFF"}"
    "-DGEANT4_USE_SYSTEM_CLHEP=ON"
    "-DGEANT4_USE_SYSTEM_EXPAT=ON"
    "-DGEANT4_USE_SYSTEM_ZLIB=ON"
    "-DGEANT4_BUILD_MULTITHREADED=${if enableMultiThreading then "ON" else "OFF"}"
  ]
  ++ lib.optionals (enableOpenGLX11 && stdenv.hostPlatform.isDarwin) [
    "-DXQuartzGL_INCLUDE_DIR=${libGLX.dev}/include"
    "-DXQuartzGL_gl_LIBRARY=${libGLX}/lib/libGL.dylib"
  ]
  ++ lib.optionals (enableMultiThreading && enablePython) [
    "-DGEANT4_BUILD_TLS_MODEL=global-dynamic"
  ]
  ++ lib.optionals enableInventor [
    "-DINVENTOR_INCLUDE_DIR=${coin3d}/include"
    "-DINVENTOR_LIBRARY_RELEASE=${coin3d}/lib/libCoin.so"
  ];

  postFixup = ''
    substituteInPlace "$out"/bin/geant4.sh \
      --replace-fail "export GEANT4_DATA_DIR" "# export GEANT4_DATA_DIR"
  ''
  + lib.optionalString enableQt ''
    wrapQtAppsHook
  '';

  dontWrapQtApps = true; # no binaries
  propagatedNativeBuildInputs = lib.optionals enableQt [ qt6.wrapQtAppsHook ];
  setupHook = ./geant4-hook.sh;

  # Set the myriad of envars required by Geant4 if we use a nix-shell.
  shellHook = ''
    source $out/nix-support/setup-hook
  '';

  passthru = {
    inherit enableQt;
    data = callPackage ./datasets.nix { };
    tests = callPackage ./tests.nix { };
  };

  meta = {
    description = "Toolkit for the simulation of the passage of particles through matter";

    longDescription = ''
      Geant4 is a toolkit for the simulation of the passage of particles through matter.
      Its areas of application include high energy, nuclear and accelerator physics, as well as studies in medical and space science.
      The two main reference papers for Geant4 are published in Nuclear Instruments and Methods in Physics Research A 506 (2003) 250-303, and IEEE Transactions on Nuclear Science 53 No. 1 (2006) 270-278.
    '';

    homepage = "https://www.geant4.org";
    license = lib.licenses.g4sl;

    maintainers = with lib.maintainers; [
      omnipotententity
      veprbl
    ];

    platforms = lib.platforms.unix;
  };
})
