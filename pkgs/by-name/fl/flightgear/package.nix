{
  lib,
  stdenv,
  fetchFromGitLab,
  apr,
  boost,
  callPackage,
  cmake,
  curl,
  fltk_1_3,
  freealut,
  glew,
  libGL,
  libGLU,
  libglut,
  libice,
  libjpeg,
  libpng,
  libsm,
  libunwind,
  libx11,
  libxext,
  libxi,
  libxmu,
  libxt,
  nix-update-script,
  openal,
  plib,
  qt5,
  simgear,
  udev,
  xorgproto,
  xz,
  zlib,
}:

let
  openscenegraph = callPackage ./openscenegraph-flightgear.nix { };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "flightgear";
  version = "2024.1.6";

  src = fetchFromGitLab {
    owner = "flightgear";
    repo = "flightgear";
    tag = finalAttrs.version;
    hash = "sha256-unYP8q7IvNwjLHTmm/38gauCPxr3+ZFcsD5rY6BEzno=";
  };

  nativeBuildInputs = [
    cmake
    qt5.wrapQtAppsHook
  ];

  buildInputs = [
    freealut
    libjpeg
    openal
    plib
    (simgear.override { openscenegraph = openscenegraph; })
    zlib
    boost
    libpng
    fltk_1_3
    apr
    qt5.qtbase
    qt5.qtquickcontrols2
    glew
    qt5.qtdeclarative
    curl
    openscenegraph
    xz
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [
    libglut
    libGLU
    libGL
    libice
    libsm
    libunwind
    libx11
    xorgproto
    libxext
    libxi
    libxmu
    libxt
    udev
  ];

  cmakeFlags = lib.optional stdenv.hostPlatform.isDarwin (
    lib.cmakeFeature "CMAKE_OSX_DEPLOYMENT_TARGET" "11.0"
  );

  postInstall = ''
    # Remove redundant AppImage artifacts
    rm -rf "$out/appdir"
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    # The bundle copies OSG dylib dangling symlinks
    rm -rf "$out/FlightGear.app/Contents/Frameworks"
    # Place app bundle where macOS expects it
    mkdir -p "$out/Applications"
    mv "$out/FlightGear.app" "$out/Applications/"
    # Provide fgfs in bin/ for CLI use, pointing into the bundle
    ln -s "$out/Applications/FlightGear.app/Contents/MacOS/FlightGear" "$out/bin/fgfs"
  '';

  qtWrapperArgs = [ "--set FG_ROOT ${finalAttrs.passthru.data}/share/FlightGear" ];

  passthru = {
    data = stdenv.mkDerivation {
      inherit (finalAttrs) version;
      pname = "flightgear-data";

      src = fetchFromGitLab {
        owner = "flightgear";
        repo = "fgdata";
        tag = finalAttrs.version;
        hash = "sha256-B7WCEMrHtSW4Yk2HM+ZjgKt5GeQrSmvxKITqAYXKSuw=";
      };

      installPhase = ''
        mkdir -p "$out/share/FlightGear"
        cp -a "$src"/* "$out/share/FlightGear/"
      '';

      dontUnpack = true;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "A free and highly sophisticated flight simulator";
    homepage = "https://www.flightgear.org/";
    changelog = "https://www.flightgear.org/download/releases/2024-1-5"; # TODO: Use finalattrs when back on stable tracking
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      raskin
      kirillrdy
      philocalyst
    ];

    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "fgfs";
    hydraPlatforms = [ ]; # disabled from hydra because it's so big
  };
})
