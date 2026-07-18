{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  buildPackages,
  cmake,
  libjack2,
  libpulseaudio,
  libsndfile,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fluidsynth";
  version = "2.5.5";

  src = fetchFromGitHub {
    owner = "FluidSynth";
    repo = "fluidsynth";
    tag = "v${finalAttrs.version}";
    hash = "sha256-WEzOYHtPIUkPZu3v4dWcCh3dOJUyG1xRxDuoSXqiGbk=";
    fetchSubmodules = true;
  };

  outputs = [
    "out"
    "dev"
    "man"
  ];

  nativeBuildInputs = [
    buildPackages.stdenv.cc
    pkg-config
    cmake
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    libsndfile
    libjack2
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib
    libpulseaudio
  ];

  cmakeFlags = [
    "-Denable-framework=off"
    "-Dosal=cpp11"
    "-Denable-libinstpatch=0"
  ];

  meta = {
    description = "Real-time software synthesizer based on the SoundFont 2 specifications";
    homepage = "https://www.fluidsynth.org";
    license = lib.licenses.lgpl21Plus;

    maintainers = with lib.maintainers; [
      guylamar2006
    ];

    platforms = lib.platforms.unix;
    mainProgram = "fluidsynth";
  };
})
