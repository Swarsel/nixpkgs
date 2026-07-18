{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  doxygen,
  fetchpatch,
  libuecc,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ecdsautils";
  version = "0.4.2";

  src = fetchFromGitHub {
    owner = "freifunk-gluon";
    repo = "ecdsautils";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-vGHLAX/XOtePvdT/rljCOdlILHVO20mCt6p+MUi13dg=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-oJv47NckFHFONPcG3WfHwgaHRqrz2eWXzbr5SQr+kX4=";
      url = "https://github.com/freifunk-gluon/ecdsautils/commit/19f096f9c10264f4efe4b926fe83126e85642cba.patch";
    })
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    doxygen
  ];

  buildInputs = [ libuecc ];

  meta = {
    description = "Tiny collection of programs used for ECDSA (keygen, sign, verify)";
    homepage = "https://github.com/freifunk-gluon/ecdsautils/";

    license = with lib.licenses; [
      mit
      bsd2
    ];

    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
