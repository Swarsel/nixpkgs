{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  libjack2,
  liblo,
  libsamplerate,
  libsndfile,
  pkg-config,
  rubberband,
  scons,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "klick";
  version = "0.14.2";

  src = fetchFromGitHub {
    owner = "Allfifthstuning";
    repo = "klick";
    rev = finalAttrs.version;
    hash = "sha256-jHyeVCmyy9ipbVaF7GSW19DOVpU9EQJoLcGq9uos+eY=";
  };

  nativeBuildInputs = [
    pkg-config
    scons
  ];

  buildInputs = [
    rubberband
    libsamplerate
    libsndfile
    liblo
    libjack2
    boost
  ];

  preBuild = ''
    substituteInPlace SConstruct \
      --replace-fail 'pkg-config' "${stdenv.cc.targetPrefix}pkg-config"
  '';

  prefixKey = "PREFIX=";

  meta = {
    description = "Advanced command-line metronome for JACK";
    homepage = "https://das.nasophon.de/klick/";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "klick";
  };
})
