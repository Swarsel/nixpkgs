{
  lib,
  stdenv,
  alsa-lib,
  autoconf-archive,
  autoreconfHook,
  config,
  fetchFromCodeberg,
  fftw,
  flac,
  ladspa-sdk,
  lame,
  libao,
  libid3tag,
  libmad,
  libogg,
  libpng,
  libpulseaudio,
  libsndfile,
  libvorbis,
  opencore-amr,
  opusfile,
  pkg-config,
  speex,
  speexdsp,
  twolame,
  wavpack,
  enableAMR ? true,
  enableAlsa ? true,
  enableFFTW ? true,
  enableFLAC ? true,
  enableLadspa ? true,
  enableLame ? config.sox.enableLame or false,
  enableLibao ? true,
  enableLibid3tag ? true,
  enableLibmad ? true,
  enableLibogg ? true,
  enableLibpulseaudio ?
    stdenv.hostPlatform.isLinux && lib.meta.availableOn stdenv.hostPlatform libpulseaudio,
  enableLibsndfile ? true,
  enableOpusfile ? true,
  enablePNG ? true,
  enableReplace ? true,
  enableSpeex ? true,
  enableTwolame ? config.sox.enableTwolame or false,
  enableWavpack ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sox";
  version = "14.7.1.2";

  src = fetchFromCodeberg {
    owner = "sox_ng";
    repo = "sox_ng";
    tag = "sox_ng-${finalAttrs.version}";
    hash = "sha256-yIebX0a/fbpr/NMgiK+gjDPNValf3gITpxDSJAc6eAw=";
  };

  outputs = [
    "out"
    "dev"
    "lib"
    "man"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    autoconf-archive
    pkg-config
  ];

  buildInputs =
    lib.optional (enableAlsa && stdenv.hostPlatform.isLinux) alsa-lib
    ++ lib.optional enableAMR opencore-amr
    ++ lib.optional enableFLAC flac
    ++ lib.optional enableFFTW fftw
    ++ lib.optional enableLadspa ladspa-sdk
    ++ lib.optional enableLame lame
    ++ lib.optional enableLibao libao
    ++ lib.optional enableLibid3tag libid3tag
    ++ lib.optional enableLibmad libmad
    ++ lib.optional enableLibpulseaudio libpulseaudio
    ++ lib.optional enableLibsndfile libsndfile
    ++ lib.optional enableOpusfile opusfile
    ++ lib.optional enablePNG libpng
    ++ lib.optional enableTwolame twolame
    ++ lib.optional enableWavpack wavpack
    ++ lib.optionals enableLibogg [
      libogg
      libvorbis
    ]
    ++ lib.optionals enableSpeex [
      speex
      speexdsp
    ];

  configureFlags = [
    (lib.enableFeature enableReplace "replace")
  ];

  __structuredAttrs = true;
  enableParallelBuilding = true;

  meta = {
    description = "Another Swiss Army Knife of sound processing utilities";
    homepage = "https://codeberg.org/sox_ng/sox_ng";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ fpletz ];
    platforms = lib.platforms.unix;
  };
})
