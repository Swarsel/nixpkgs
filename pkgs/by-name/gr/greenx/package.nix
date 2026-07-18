{
  lib,
  stdenv,
  fetchFromGitHub,
  blas,
  cmake,
  gfortran,
  lapack,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "greenx";
  version = "2.2";

  src = fetchFromGitHub {
    owner = "nomad-coe";
    repo = "greenx";
    rev = "v${finalAttrs.version}";
    hash = "sha256-otIs2Y79KoEL4ut8YQe7Y27LpmpId8h/X8B6GIg8l+E=";
  };

  nativeBuildInputs = [
    gfortran
    pkg-config
    cmake
  ];

  buildInputs = [
    blas
    lapack
  ];

  # Uses a hacky python setup run by cmake, which is hard to get running
  doCheck = false;

  meta = {
    description = "Library for Green’s function based electronic structure theory calculations";
    homepage = "https://github.com/nomad-coe/greenX";
    license = [ lib.licenses.asl20 ];
    maintainers = [ lib.maintainers.sheepforce ];
    platforms = lib.platforms.linux;
  };
})
