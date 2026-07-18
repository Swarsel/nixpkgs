{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  onetbb,
  useTBB ? lib.meta.availableOn stdenv.hostPlatform onetbb,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libblake3";
  version = "1.8.5";

  src = fetchFromGitHub {
    owner = "BLAKE3-team";
    repo = "BLAKE3";
    tag = finalAttrs.version;
    hash = "sha256-4Oany3uk0759YIZgD1gsONSFU1Mn/GAMvsSeP33J9Ts=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [ cmake ];

  propagatedBuildInputs = lib.optionals useTBB [
    onetbb
  ];

  cmakeFlags = [
    (lib.cmakeBool "BLAKE3_USE_TBB" useTBB)
    (lib.cmakeBool "BUILD_SHARED_LIBS" (!stdenv.hostPlatform.isStatic))
  ];

  sourceRoot = finalAttrs.src.name + "/c";

  meta = {
    description = "Official C implementation of BLAKE3";
    homepage = "https://github.com/BLAKE3-team/BLAKE3/tree/master/c";

    license = with lib.licenses; [
      asl20
      cc0
    ];

    maintainers = with lib.maintainers; [
      fgaz
      fpletz
      silvanshade
    ];

    platforms = lib.platforms.all;
  };
})
