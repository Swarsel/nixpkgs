{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  ffmpeg,
  fftw,
  fftwFloat,
  ladspa-header,
  libao,
  libmad,
  libpulseaudio,
  libsndfile,
  libtool,
  pkg-config,
  zita-convolver,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dsp";
  version = "2.0";

  src = fetchFromGitHub {
    owner = "bmc0";
    repo = "dsp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-WUH4+5v1wv6EXTOuRq9iVVZsXMt5DVrtgX8vLE7a8s8=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    fftw
    zita-convolver
    fftwFloat
    libsndfile
    ffmpeg
    alsa-lib
    libao
    libmad
    ladspa-header
    libtool
    libpulseaudio
  ];

  meta = {
    description = "Audio processing program with an interactive mode";
    homepage = "https://github.com/bmc0/dsp";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ aaronjheng ];
    platforms = lib.platforms.linux;
    mainProgram = "dsp";
  };
})
