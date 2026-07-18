{
  lib,
  stdenv,
  fetchFromGitHub,
  cairo,
  fftwFloat,
  gtk2,
  libGL,
  libGLU,
  libjack2,
  lv2,
  pango,
  pkg-config,
}:

stdenv.mkDerivation rec {
  pname = "meters-lv2";
  version = "0.9.20";

  src = fetchFromGitHub {
    owner = "x42";
    repo = "meters.lv2";
    rev = "v${version}";
    sha256 = "sha256-eGXTbE83bJEDqTBltL6ZX9qa/OotCFmUxpE/aLqGELU=";
  };

  postPatch = ''
    substituteInPlace Makefile --replace "-msse -msse2 -mfpmath=sse" ""
  ''; # remove x86-specific flags

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    lv2
    libGLU
    libGL
    gtk2
    cairo
    pango
    fftwFloat
    libjack2
  ];

  makeFlags = [ "PREFIX=${placeholder "out"}" ];
  enableParallelBuilding = true;
  meter_VERSION = version;

  postUnpack = ''
    rm -rf $sourceRoot/robtk/
    ln -s ${robtkSrc} $sourceRoot/robtk
  '';

  robtkSrc = fetchFromGitHub {
    owner = "x42";
    repo = "robtk";
    rev = "v${robtkVersion}";
    sha256 = "sha256-L1meipOco8esZl+Pgqgi/oYVbhimgh9n8p9Iqj3dZr0=";
  };

  robtkVersion = "0.7.5";

  meta = {
    description = "Collection of audio level meters with GUI in LV2 plugin format";
    homepage = "https://x42.github.io/meters.lv2/";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.linux;
    mainProgram = "x42-meter";
  };
}
