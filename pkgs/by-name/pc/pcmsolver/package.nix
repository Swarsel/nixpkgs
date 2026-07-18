{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  cmake,
  eigen,
  gfortran,
  perl,
  python3,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pcmsolver";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "PCMSolver";
    repo = "pcmsolver";
    rev = "v${finalAttrs.version}";
    sha256 = "0jrxr8z21hjy7ik999hna9rdqy221kbkl3qkb06xw7g80rc9x9yr";
  };

  # Glibc 2.34 changed SIGSTKSZ to a dynamic value, which breaks
  # PCMsolver. Replace SIGSTKZ by the backward-compatible _SC_SIGSTKSZ.
  postPatch = ''
    substituteInPlace external/Catch/catch.hpp \
      --replace SIGSTKSZ _SC_SIGSTKSZ
  '';

  nativeBuildInputs = [
    cmake
    gfortran
    perl
    python3
  ];

  buildInputs = [
    boost
    eigen
    zlib
  ];

  cmakeFlags = [
    "-DENABLE_OPENMP=ON"
    "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
  ];

  # Required for build with gcc-14
  env.NIX_CFLAGS_COMPILE = "-std=c++14 -Wno-template-body";
  # Requires files, that are not installed.
  doCheck = false;
  hardeningDisable = [ "format" ];

  meta = {
    description = "API for the Polarizable Continuum Model";
    homepage = "https://pcmsolver.readthedocs.io/en/stable/";
    license = lib.licenses.lgpl3Only;
    maintainers = [ lib.maintainers.sheepforce ];
    platforms = lib.platforms.linux;
    mainProgram = "run_pcm";
  };
})
