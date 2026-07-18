{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  curl,
  enet,
  flac,
  libGL,
  libmpeg2,
  libmpg123,
  libpcap,
  libpng,
  libserialport,
  nlohmann_json,
  portmidi,
  sdl3,
  sdl3-image,
  zstd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "amiberry";
  version = "8.1.6";

  src = fetchFromGitHub {
    owner = "BlitterStudio";
    repo = "amiberry";
    tag = "v${finalAttrs.version}";
    hash = "sha256-XUq7L2udZDH78UHeZBjbiERRwEwv8+JfxpPnThOGV6k=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    curl
    enet
    flac
    libGL
    libmpeg2
    libmpg123
    libpcap
    libpng
    libserialport
    nlohmann_json
    portmidi
    sdl3
    sdl3-image
    zstd
  ];

  enableParallelBuilding = true;

  meta = {
    description = "Optimized Amiga emulator for Linux/macOS";
    homepage = "https://github.com/BlitterStudio/amiberry";
    license = lib.licenses.gpl3;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "amiberry";
  };
})
