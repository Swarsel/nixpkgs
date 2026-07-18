{
  lib,
  stdenv,
  fetchFromGitHub,
  addDriverRunpath,
  cmake,
  pkg-config,
  replaceVars,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libvpl";
  version = "2.16.0";

  src = fetchFromGitHub {
    owner = "intel";
    repo = "libvpl";
    rev = "v${finalAttrs.version}";
    hash = "sha256-TbneMexrGShBE83WRCHvECucG2/eYMtljwb3yvCTP7k=";
  };

  patches = [
    (replaceVars ./opengl-driver-lib.patch {
      inherit (addDriverRunpath) driverLink;
    })
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_TESTS" finalAttrs.finalPackage.doCheck)
  ];

  doCheck = true;

  meta = {
    description = "Intel Video Processing Library";
    homepage = "https://intel.github.io/libvpl/";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
})
