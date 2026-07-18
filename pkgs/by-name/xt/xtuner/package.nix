{
  lib,
  stdenv,
  fetchFromGitHub,
  cairo,
  fetchpatch,
  fftwFloat,
  libjack2,
  liblo,
  libsigcxx,
  libx11,
  pkg-config,
  zita-resampler,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xtuner";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "brummer10";
    repo = "XTuner";
    tag = "v${finalAttrs.version}";
    sha256 = "1i5chfnf3hcivwzni9z6cn9pb68qmwsx8bf4z7d29a5vig8kbhrv";
    fetchSubmodules = true;
  };

  patches = [
    # Fix build against glibc-2.38.
    (fetchpatch {
      extraPrefix = "libxputty/";
      hash = "sha256-VspR0KJjBt4WOrnlo7rHw1oAYM1d2RSz6JhuAEfsO3M=";
      name = "glibc-2.38.patch";
      stripLen = 1;
      url = "https://github.com/brummer10/libxputty/commit/7eb70bf3f7bce0af9e1919d6c875cdb8efca734e.patch";
    })
  ];

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    cairo
    libx11
    libjack2
    liblo
    libsigcxx
    zita-resampler
    fftwFloat
  ];

  makeFlags = [ "PREFIX=$(out)" ];
  enableParallelBuilding = true;

  meta = {
    description = "Tuner for Jack Audio Connection Kit";
    homepage = "https://github.com/brummer10/XTuner";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ magnetophon ];
    platforms = lib.platforms.linux;
    mainProgram = "xtuner";
  };
})
