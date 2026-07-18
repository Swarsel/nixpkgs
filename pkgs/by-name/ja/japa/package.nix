{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  fftwFloat,
  libclthreads,
  libclxclient,
  libjack2,
  libx11,
  libxft,
  zita-alsa-pcmi,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "japa";
  version = "0.9.4";

  src = fetchurl {
    url = "https://kokkinizita.linuxaudio.org/linuxaudio/downloads/japa-${finalAttrs.version}.tar.bz2";
    sha256 = "sha256-t9wlZr+pE5u6yTpATWDQseC/rf4TFbtG0X9tnTdkB8I=";
  };

  buildInputs = [
    alsa-lib
    libjack2
    fftwFloat
    libclthreads
    libclxclient
    libx11
    libxft
    zita-alsa-pcmi
  ];

  makeFlags = [
    "PREFIX=$(out)"
    "SUFFIX=''"
  ];

  preConfigure = ''
    cd ./source/
  '';

  meta = {
    description = "'perceptual' or 'psychoacoustic' audio spectrum analyser for JACK and ALSA";
    homepage = "http://kokkinizita.linuxaudio.org/linuxaudio/index.html";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.magnetophon ];
    platforms = lib.platforms.linux;
    mainProgram = "japa";
  };
})
