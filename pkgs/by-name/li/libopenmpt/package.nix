{
  lib,
  stdenv,
  fetchurl,
  config,
  flac,
  libogg,
  libpulseaudio,
  libsndfile,
  libvorbis,
  mpg123,
  pkg-config,
  portaudio,
  zlib,
  usePulseAudio ? config.pulseaudio or stdenv.hostPlatform.isLinux,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libopenmpt";
  version = "0.8.7";

  src = fetchurl {
    url = "https://lib.openmpt.org/files/libopenmpt/src/libopenmpt-${finalAttrs.version}+release.autotools.tar.gz";
    hash = "sha256-J1wp70e+mZL2KjX8yW98oFwG0v0FySmLje6fdD91sIk=";
  };

  outputs = [
    "out"
    "dev"
    "bin"
  ];

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    zlib
    mpg123
    libogg
    libvorbis
    portaudio
    libsndfile
    flac
  ]
  ++ lib.optionals usePulseAudio [
    libpulseaudio
  ];

  configureFlags = [
    (lib.strings.withFeature usePulseAudio "pulseaudio")
  ];

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

  postFixup = ''
    moveToOutput share/doc $dev
  '';

  enableParallelBuilding = true;
  passthru.updateScript = ./update.sh;

  meta = {
    description = "Cross-platform C++ and C library to decode tracked music files into a raw PCM audio stream";

    longDescription = ''
      libopenmpt is a cross-platform C++ and C library to decode tracked music files (modules) into a raw PCM audio stream.
      openmpt123 is a cross-platform command-line or terminal based module file player.
      libopenmpt is based on the player code of the OpenMPT project.
    '';

    homepage = "https://lib.openmpt.org/libopenmpt/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ OPNA2608 ];
    platforms = lib.platforms.unix;
    mainProgram = "openmpt123";
  };
})
