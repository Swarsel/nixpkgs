{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  alsa-lib,
  avahi,
  cmake,
  curl,
  expat,
  ffmpeg,
  libcec,
  libevdev,
  libopus,
  libpthread-stubs,
  libpulseaudio,
  libuuid,
  libva,
  libvdpau,
  libxcb,
  perl,
  pkg-config,
  udev,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "moonlight-embedded";
  version = "2.7.0";

  src = fetchFromGitHub {
    owner = "moonlight-stream";
    repo = "moonlight-embedded";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Jc706BjIT3rS9zwntNOdgszP4CHuX+qxvPvWeU68Amg=";
    fetchSubmodules = true;
  };

  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [
    cmake
    perl
    pkg-config
  ];

  buildInputs = [
    alsa-lib
    libevdev
    libopus
    udev
    SDL2
    ffmpeg
    libxcb
    libvdpau
    libpulseaudio
    libcec
    libpthread-stubs
    curl
    expat
    avahi
    libuuid
    libva
  ];

  meta = {
    description = "Open source implementation of NVIDIA's GameStream";
    homepage = "https://github.com/moonlight-stream/moonlight-embedded";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "moonlight";
  };
})
