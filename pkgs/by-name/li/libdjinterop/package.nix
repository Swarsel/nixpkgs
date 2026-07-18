{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  cmake,
  fetchpatch2,
  ninja,
  pkg-config,
  sqlite,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libdjinterop";
  version = "0.26.1";

  src = fetchFromGitHub {
    owner = "xsco";
    repo = "libdjinterop";
    rev = finalAttrs.version;
    hash = "sha256-HwNhCemqVR1xNSbcht0AuwTfpRhVi70ZH5ksSTSRFoc=";
  };

  outputs = [
    "out"
    "dev"
  ];

  patches = [
    # https://github.com/xsco/libdjinterop/pull/161
    (fetchpatch2 {
      hash = "sha256-WahMsFeetSlHHiIyaC04YxTiXDxD1ooASqoIP2TK9R0=";
      url = "https://github.com/xsco/libdjinterop/commit/94ce315cd5155bd031eeccfec12fbeb8e399dd14.patch";
    })
  ];

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
  ];

  buildInputs = [
    boost
    sqlite
    zlib
  ];

  meta = {
    description = "C++ library for access to DJ record libraries";
    homepage = "https://github.com/xsco/libdjinterop";
    license = lib.licenses.lgpl3;
    maintainers = with lib.maintainers; [ benley ];
    platforms = lib.platforms.unix;
  };
})
