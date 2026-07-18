{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  cmake,
  curl,
  expat,
  flac,
  fltk,
  fmt,
  fontconfig,
  gtk3,
  jack2,
  libGL,
  libmpg123,
  libogg,
  libopus,
  libpulseaudio,
  libsamplerate,
  libsndfile,
  libvorbis,
  libxpm,
  libxrandr,
  nlohmann_json,
  pkg-config,
  rtmidi,
  webkitgtk_4_1,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "giada";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "monocasual";
    repo = "giada";
    tag = finalAttrs.version;
    hash = "sha256-AceH2FO75WF/Cmk3wd6u495M277iuZp/21nBl3K4jHU=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    alsa-lib
    curl
    expat
    flac
    fltk
    fmt
    gtk3
    jack2
    libGL
    libxpm
    libxrandr
    libogg
    libopus
    libpulseaudio
    libsamplerate
    libsndfile
    libvorbis
    libmpg123
    nlohmann_json
    rtmidi
    webkitgtk_4_1
  ]
  ++ lib.optionals (stdenv.hostPlatform.isLinux || stdenv.hostPlatform.isFreeBSD) [
    fontconfig
  ];

  cmakeFlags = [
    "-DCMAKE_INSTALL_BINDIR=bin"
  ];

  env.NIX_CFLAGS_COMPILE = toString [
    "-w"
    "-Wno-error"
  ];

  meta = {
    description = "Free, minimal, hardcore audio tool for DJs, live performers and electronic musicians";
    homepage = "https://giadamusic.com/";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ kashw2 ];
    platforms = lib.platforms.all;
    mainProgram = "giada";
  };
})
