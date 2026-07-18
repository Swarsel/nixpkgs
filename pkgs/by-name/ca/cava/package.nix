{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  alsa-lib,
  autoconf-archive,
  autoreconfHook,
  fftw,
  iniparser,
  libGL,
  libpulseaudio,
  libtool,
  ncurses,
  pipewire,
  pkgconf,
  portaudio,
  versionCheckHook,
  withPipewire ? stdenv.hostPlatform.isLinux,
  withSDL2 ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cava";
  version = "0.10.7";

  src = fetchFromGitHub {
    owner = "karlstav";
    repo = "cava";
    tag = finalAttrs.version;
    hash = "sha256-eOGUDGGlja5Cq8XTJFRqyP6qyaoxOJm09vZrlk4KS9k=";
  };

  nativeBuildInputs = [
    autoreconfHook
    autoconf-archive
    pkgconf
    versionCheckHook
  ];

  buildInputs = [
    fftw
    iniparser
    libpulseaudio
    libtool
    ncurses
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    portaudio
  ]
  ++ lib.optionals withSDL2 [
    libGL
    SDL2
  ]
  ++ lib.optionals withPipewire [
    pipewire
  ];

  doInstallCheck = true;

  preAutoreconf = ''
    echo ${finalAttrs.version} > version
  '';

  versionCheckProgramArg = "-v";

  meta = {
    description = "Console-based Audio Visualizer for Alsa";
    homepage = "https://github.com/karlstav/cava";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      mirrexagon
    ];

    platforms = lib.platforms.unix;
    mainProgram = "cava";
  };
})
