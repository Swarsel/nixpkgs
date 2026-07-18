{
  lib,
  stdenv,
  buildPackages,
  cmake,
  # explicitly depending on openexr_2 because ilmbase doesn't exist for v3
  openexr_2,
}:

stdenv.mkDerivation {
  # the project no longer provides separate tarballs. We may even want to merge
  # the ilmbase package into openexr in the future.
  inherit (openexr_2) src patches;
  pname = "ilmbase";
  version = lib.getVersion openexr_2;

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [ cmake ];

  preConfigure = ''
    # Need to cd after patches for openexr patches to apply.
    cd IlmBase
  '';

  # fails 1 out of 1 tests with
  # "lt-ImathTest: testBoxAlgo.cpp:892: void {anonymous}::boxMatrixTransform(): Assertion `b21 == b2' failed"
  # at least on i686. spooky!
  doCheck = stdenv.hostPlatform.isx86_64;
  depsBuildBuild = [ buildPackages.stdenv.cc ];

  meta = {
    inherit (openexr_2.meta) knownVulnerabilities;
    description = "Library for 2D/3D vectors and matrices and other mathematical objects, functions and data types for computer graphics";
    homepage = "https://www.openexr.com/";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.all;
  };
}
