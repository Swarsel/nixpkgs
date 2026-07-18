{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  cmake,
  copyDesktopItems,
  curl,
  libGL,
  libGLU,
  libjpeg,
  libogg,
  libvorbis,
  libx11,
  makeDesktopItem,
  openal,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dhewm3";
  version = "1.5.4";

  src = fetchFromGitHub {
    owner = "dhewm";
    repo = "dhewm3";
    rev = finalAttrs.version;
    sha256 = "sha256-losqnxnjRPOczjrRPyyOxCeg9TNScXLcXADgo9Bxm5k=";
  };

  nativeBuildInputs = [
    cmake
    copyDesktopItems
  ];

  buildInputs = [
    SDL2
    libGLU
    libGL
    libx11
    zlib
    libjpeg
    libogg
    libvorbis
    openal
    curl
  ];

  preConfigure = ''
    cd "$(ls -d dhewm3-*.src)"/neo
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Game" ];
      desktopName = "Doom 3";
      exec = "dhewm3";
      name = "dhewm3";
    })
  ];

  hardeningDisable = [ "format" ];

  # Add libGLU libGL linking
  patchPhase = ''
    sed -i 's/\<idlib\()\?\)$/idlib GL\1/' neo/CMakeLists.txt
  '';

  meta = {
    description = "Doom 3 port to SDL";
    homepage = "https://github.com/dhewm/dhewm3";
    license = lib.licenses.gpl3;
    maintainers = [ ];
    platforms = with lib.platforms; linux;
    mainProgram = "dhewm3";
  };
})
