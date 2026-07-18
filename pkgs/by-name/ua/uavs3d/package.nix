{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  testers,
  unstableGitUpdater,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "uavs3d";
  version = "1.1-unstable-2025-12-13";

  src = fetchFromGitHub {
    owner = "uavs3";
    repo = "uavs3d";
    rev = "0e20d2c291853f196c68922a264bcd8471d75b68";
    hash = "sha256-SlCGLglBsU3ua406Bnf89c4X80F5B93piF2sAXqtRus=";
  };

  outputs = [
    "out"
    "dev"
  ];

  # Fix the build with CMake 4.
  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail \
        'cmake_minimum_required(VERSION 3.1)' \
        'cmake_minimum_required(VERSION 3.10)'
  '';

  nativeBuildInputs = [
    cmake
  ];

  cmakeFlags = [
    (lib.cmakeBool "COMPILE_10BIT" true)
    (lib.cmakeBool "BUILD_SHARED_LIBS" (!stdenv.hostPlatform.isStatic))
  ];

  passthru = {
    tests.pkg-config = testers.hasPkgConfigModules { package = finalAttrs.finalPackage; };

    updateScript = unstableGitUpdater {
      tagPrefix = "v";
    };
  };

  meta = {
    description = "AVS3 decoder which supports AVS3-P2 baseline profile";
    homepage = "https://github.com/uavs3/uavs3d";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ jopejoe1 ];
    platforms = lib.platforms.all;
    pkgConfigModules = [ "uavs3d" ];
  };
})
