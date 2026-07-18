{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ffmpeg,
  fmt,
  inih,
  libebur128,
  pkg-config,
  taglib,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rsgain";
  version = "3.7";

  src = fetchFromGitHub {
    owner = "complexlogic";
    repo = "rsgain";
    rev = "v${finalAttrs.version}";
    hash = "sha256-mI/lXRmPQTSgzFvNu8cjJN86wIkWFUrJg1yFFfBu2JE=";
  };

  nativeBuildInputs = [
    pkg-config
    cmake
  ];

  buildInputs = [
    libebur128
    taglib
    ffmpeg
    inih
    fmt
    zlib
  ];

  meta = {
    description = "Simple, but powerful ReplayGain 2.0 tagging utility";
    homepage = "https://github.com/complexlogic/rsgain";
    changelog = "https://github.com/complexlogic/rsgain/blob/v${finalAttrs.version}/CHANGELOG";
    license = lib.licenses.bsd2;
    maintainers = [ lib.maintainers.felipeqq2 ];
    platforms = lib.platforms.all;
    mainProgram = "rsgain";
  };
})
