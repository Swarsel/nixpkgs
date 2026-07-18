{
  alsa-lib,
  audiofile,
  fftw,
  flac,
  id3lib,
  libmad,
  libogg,
  libopus,
  libpulseaudio,
  libsamplerate,
  libvorbis,
  mkKdeDerivation,
  pkg-config,
  qtmultimedia,
}:
mkKdeDerivation {
  pname = "kwave";

  extraBuildInputs = [
    qtmultimedia

    alsa-lib
    audiofile
    fftw
    flac
    id3lib
    libogg
    libopus
    libmad
    libpulseaudio
    libsamplerate
    libvorbis
  ];

  extraNativeBuildInputs = [ pkg-config ];
}
