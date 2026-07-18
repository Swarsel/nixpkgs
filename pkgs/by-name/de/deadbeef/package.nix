{
  lib,
  fetchFromGitHub,
  alsa-lib,
  autoreconfHook,
  clangStdenv,
  config,
  curl,
  dbus,
  faad2,
  ffmpeg,
  flac,
  gsettings-desktop-schemas,
  gtk3,
  imlib2,
  intltool,
  jansson,
  libcddb,
  libcdio,
  libmad,
  libpulseaudio,
  libsamplerate,
  libsndfile,
  libtool,
  libvorbis,
  libx11,
  libzip,
  opusfile,
  pipewire,
  pkg-config,
  swift-corelibs-libdispatch,
  wavpack,
  wrapGAppsHook3,
  yasm,
  zlib,
  aacSupport ? true,
  # output plugins
  alsaSupport ? true,
  apeSupport ? true,
  artworkSupport ? true,
  cdaSupport ? true,
  ffmpegSupport ? false,
  flacSupport ? true,
  hotkeysSupport ? true,
  mp123Support ? true,
  opusSupport ? true,
  osdSupport ? true,
  overloadSupport ? true,
  pipewireSupport ? true,
  pulseSupport ? config.pulseaudio or true,
  # transports
  remoteSupport ? true,
  # effect plugins
  resamplerSupport ? true,
  # input plugins
  vorbisSupport ? true,
  wavSupport ? true,
  wavpackSupport ? false,
  # misc plugins
  zipSupport ? true,
}:

let
  inherit (lib) optionals;
in
clangStdenv.mkDerivation (finalAttrs: {
  pname = "deadbeef";
  version = "1.10.3";

  src = fetchFromGitHub {
    owner = "DeaDBeeF-Player";
    repo = "deadbeef";
    tag = finalAttrs.version;
    hash = "sha256-SAp6XAE3fKTR27xYrdkNHneYDGJW1+XJdX6eBI9+EY0=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    autoreconfHook
    intltool
    libtool
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    jansson
    (swift-corelibs-libdispatch.override { useSwift = false; })
    gtk3
    gsettings-desktop-schemas
  ]
  ++ optionals vorbisSupport [
    libvorbis
  ]
  ++ optionals mp123Support [
    libmad
  ]
  ++ optionals flacSupport [
    flac
  ]
  ++ optionals wavSupport [
    libsndfile
  ]
  ++ optionals cdaSupport [
    libcdio
    libcddb
  ]
  ++ optionals aacSupport [
    faad2
  ]
  ++ optionals opusSupport [
    opusfile
  ]
  ++ optionals zipSupport [
    libzip
  ]
  ++ optionals ffmpegSupport [
    ffmpeg
  ]
  ++ optionals apeSupport [
    yasm
  ]
  ++ optionals artworkSupport [
    imlib2
  ]
  ++ optionals hotkeysSupport [
    libx11
  ]
  ++ optionals osdSupport [
    dbus
  ]
  ++ optionals alsaSupport [
    alsa-lib
  ]
  ++ optionals pulseSupport [
    libpulseaudio
  ]
  ++ optionals pipewireSupport [
    pipewire
  ]
  ++ optionals resamplerSupport [
    libsamplerate
  ]
  ++ optionals overloadSupport [
    zlib
  ]
  ++ optionals wavpackSupport [
    wavpack
  ]
  ++ optionals remoteSupport [
    curl
  ];

  enableParallelBuilding = true;

  meta = {
    description = "Ultimate Music Player for GNU/Linux";
    homepage = "http://deadbeef.sourceforge.net/";
    license = lib.licenses.gpl2;
    maintainers = [ ];

    platforms = [
      "x86_64-linux"
      "i686-linux"
    ];

    mainProgram = "deadbeef";
    downloadPage = "https://github.com/DeaDBeeF-Player/deadbeef";
  };
})
