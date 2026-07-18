{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  cairo,
  fluidsynth,
  libjack2,
  liblo,
  libsigcxx,
  libsmf,
  libx11,
  pkg-config,
  xxd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mamba";
  version = "2.6";

  src = fetchFromGitHub {
    owner = "brummer10";
    repo = "Mamba";
    tag = "v${finalAttrs.version}";
    hash = "sha256-S1+nGnB1LHIUgYves0qtWh+QXYKjtKWICpOo38b3zbY=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    pkg-config
    xxd
  ];

  buildInputs = [
    cairo
    fluidsynth
    libx11
    libjack2
    alsa-lib
    liblo
    libsigcxx
    libsmf
  ];

  makeFlags = [ "PREFIX=$(out)" ];
  enableParallelBuilding = true;

  meta = {
    description = "Virtual MIDI keyboard for Jack Audio Connection Kit";
    homepage = "https://github.com/brummer10/Mamba";
    license = lib.licenses.bsd0;

    maintainers = with lib.maintainers; [
      magnetophon
    ];

    platforms = lib.platforms.linux;
  };
})
