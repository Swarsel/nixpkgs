{
  lib,
  stdenv,
  fetchFromGitHub,
  abseil-cpp_202407,
  cmake,
  openssl,
  pkg-config,
}:

let
  cxxStandard = "17";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "s2geometry";
  version = "0.12.0";

  src = fetchFromGitHub {
    owner = "google";
    repo = "s2geometry";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-stH1iO4AEL+VZizntUzhvADNOKX333o3QSOz+WOBZ5Q=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  propagatedBuildInputs = [
    (abseil-cpp_202407.override { inherit cxxStandard; })
  ];

  cmakeFlags = [
    (lib.cmakeFeature "CMAKE_CXX_STANDARD" cxxStandard)
    # incompatible with our version of gtest
    (lib.cmakeBool "BUILD_TESTS" false)
  ];

  meta = {
    description = "Computational geometry and spatial indexing on the sphere";
    homepage = "http://s2geometry.io/";
    changelog = "https://github.com/google/s2geometry/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.Thra11 ];
    platforms = lib.platforms.unix;
  };
})
