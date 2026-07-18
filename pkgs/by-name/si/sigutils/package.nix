{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fftwSinglePrec,
  libsndfile,
  pkg-config,
  volk,
}:

stdenv.mkDerivation {
  pname = "sigutils";
  version = "unstable-2022-07-05";

  src = fetchFromGitHub {
    owner = "BatchDrake";
    repo = "sigutils";
    rev = "1d7559d427aadd253dd825eef26bf15e54860c5f";
    sha256 = "sha256-wvd6sixwGmR9R4x+swLVqXre4Dqnj10jZIXUfaJcmBw=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    fftwSinglePrec
    libsndfile
    volk
  ];

  meta = {
    description = "Small signal processing utility library";
    homepage = "https://github.com/BatchDrake/sigutils";
    license = lib.licenses.gpl3;

    maintainers = with lib.maintainers; [
      polygon
      oxapentane
    ];

    platforms = lib.platforms.all;
  };
}
