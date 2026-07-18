{
  lib,
  stdenv,
  alsa-lib,
  amrnb,
  amrwb,
  autoconf-archive,
  autoreconfHook,
  config,
  fetchgit,
  flac,
  lame,
  libao,
  libmad,
  libogg,
  libpng,
  libpulseaudio,
  libsndfile,
  libvorbis,
  opusfile,
  pkg-config,
  wavpack,
  # amrnb and amrwb are unfree, disabled by default
  enableAMR ? false,
  enableAlsa ? true,
  enableFLAC ? true,
  enableLame ? config.sox.enableLame or false,
  enableLibao ? true,
  enableLibmad ? true,
  enableLibogg ? true,
  enableLibpulseaudio ?
    stdenv.hostPlatform.isLinux && lib.meta.availableOn stdenv.hostPlatform libpulseaudio,
  enableLibsndfile ? true,
  enableOpusfile ? true,
  enablePNG ? true,
  enableWavpack ? true,
}:

stdenv.mkDerivation {
  pname = "sox";
  version = "unstable-2021-05-09";

  src = fetchgit {
    url = "https://git.code.sf.net/p/sox/code";
    rev = "42b3557e13e0fe01a83465b672d89faddbe65f49";
    hash = "sha256-9cpOwio69GvzVeDq79BSmJgds9WU5kA/KUlAkHcpN5c=";
    # not really needed, but when this src was updated from `fetchurl ->
    # fetchgit`, we spared the mass rebuild by changing this `name` and
    # therefor merge this to `master` and not to `staging`.
    name = "source";
  };

  outputs = [
    "out"
    "dev"
    "lib"
    "man"
  ];

  patches = [ ./0001-musl-rewind-pipe-workaround.patch ];

  nativeBuildInputs = [
    autoreconfHook
    autoconf-archive
    pkg-config
  ];

  buildInputs =
    lib.optional (enableAlsa && stdenv.hostPlatform.isLinux) alsa-lib
    ++ lib.optional enableLibao libao
    ++ lib.optional enableLame lame
    ++ lib.optional enableLibmad libmad
    ++ lib.optionals enableLibogg [
      libogg
      libvorbis
    ]
    ++ lib.optional enableOpusfile opusfile
    ++ lib.optional enableFLAC flac
    ++ lib.optional enablePNG libpng
    ++ lib.optional enableLibsndfile libsndfile
    ++ lib.optional enableWavpack wavpack
    ++ lib.optionals enableAMR [
      amrnb
      amrwb
    ]
    ++ lib.optional enableLibpulseaudio libpulseaudio;

  enableParallelBuilding = true;

  meta = {
    description = "Sample Rate Converter for audio";
    homepage = "https://sox.sourceforge.net/";
    license = if enableAMR then lib.licenses.unfree else lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
}
