{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  cmake,
  eigen,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libnabo";
  version = "1.1.2";

  src = fetchFromGitHub {
    owner = "norlab-ulaval";
    repo = "libnabo";
    rev = finalAttrs.version;
    sha256 = "sha256-/XXRwiLLaEvp+Q+c6lBiuWBb9by6o0pDf8wFtBNp7o8=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    eigen
    boost
  ];

  cmakeFlags = [
    "-DEIGEN_INCLUDE_DIR=${eigen}/include/eigen3"
  ];

  doCheck = true;
  checkTarget = "test";

  meta = {
    inherit (finalAttrs.src.meta) homepage;
    description = "Fast K Nearest Neighbor library for low-dimensional spaces";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ cryptix ];
    platforms = lib.platforms.linux;
  };
})
