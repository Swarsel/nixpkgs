{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  libx11,
  libxau,
  libxdmcp,
  libxext,
  libxi,
  libxinerama,
  libxkbcommon,
  libxkbfile,
  libxt,
  libxtst,
  ninja,
  obs-studio,
  pkg-config,
  qtbase,
  sdl3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "obs-input-overlay";
  version = "5.1.0-unstable-2025-09-23";

  src = fetchFromGitHub {
    owner = "univrsal";
    repo = "input-overlay";
    rev = "4d62e7d0c55f8ff62c3a0e7b1a8f3092086b23b7";
    hash = "sha256-cUULaOoV4fffEvsHkcG3lnFCIHSvnv3LHg+SDuuVLao=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    ninja
  ];

  buildInputs = [
    obs-studio
    qtbase
    sdl3
    libx11
    libxau
    libxdmcp
    libxtst
    libxext
    libxi
    libxt
    libxinerama
    libxkbcommon
    libxkbfile
  ];

  cmakeFlags = lib.optionals stdenv.hostPlatform.isx86 [
    "-DCMAKE_CXX_FLAGS=-msse4.1"
  ];

  preFixup = ''
    # Remove broken uiohook development files
    rm -r $out/lib/cmake $out/lib/pkgconfig
  '';

  dontWrapQtApps = true;

  postUnpack = ''
    sed -i '/set(CMAKE_CXX_FLAGS "-march=native")/d' 'source/CMakeLists.txt'
  '';

  meta = {
    inherit (obs-studio.meta) platforms;
    description = "Show keyboard, gamepad and mouse input on stream";
    homepage = "https://github.com/univrsal/input-overlay";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ glittershark ];
  };
})
