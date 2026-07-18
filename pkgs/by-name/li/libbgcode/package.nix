{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  catch2_3,
  cmake,
  heatshrink,
  pkg-config,
  zlib,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "libbgcode";
  version = "0-unstable-2025-02-19";

  src = fetchFromGitHub {
    owner = "prusa3d";
    repo = "libbgcode";
    rev = "5041c093b33e2748e76d6b326f2251310823f3df";
    hash = "sha256-EaxVZerH2v8b1Yqk+RW/r3BvnJvrAelkKf8Bd+EHbEc=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    heatshrink
    zlib
    boost
  ];

  cmakeFlags = [
    (lib.cmakeBool "LibBGCode_BUILD_TESTS" finalAttrs.finalPackage.doCheck)
  ];

  doCheck = true;

  checkInputs = [
    catch2_3
  ];

  meta = {
    description = "Prusa Block & Binary G-code reader / writer / converter";
    homepage = "https://github.com/prusa3d/libbgcode";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ lach ];
    platforms = lib.platforms.unix;
    mainProgram = "bgcode";
  };
})
