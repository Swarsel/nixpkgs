{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cmake,
  gfortran,
  libspatialindex,
  mpi,
  ninja,
  pkgs,
  rtree,
  scikit-build-core,
}:

buildPythonPackage {
  inherit (pkgs.libsupermesh)
    pname
    version
    src
    meta
    ;

  nativeBuildInputs = [
    gfortran
    cmake
    ninja
    mpi
  ];

  buildInputs = [
    libspatialindex
    gfortran.cc.lib
  ];

  # Only build tests if not built by scikit-build-core
  doCheck = false;

  build-system = [
    scikit-build-core
  ];

  dependencies = [
    rtree
  ];

  dontUseCmakeConfigure = true;
  pyproject = true;
}
