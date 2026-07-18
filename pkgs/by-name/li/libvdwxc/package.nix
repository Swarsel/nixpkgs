{
  lib,
  stdenv,
  fetchFromGitLab,
  autoreconfHook,
  fftwMpi,
  gfortran,
  mpi,
}:

stdenv.mkDerivation {
  pname = "libvdwxc";
  # Stable version has non-working MPI detection.
  version = "unstable-24.02.2020";

  src = fetchFromGitLab {
    owner = "libvdwxc";
    repo = "libvdwxc";
    rev = "92f4910c6ac88e111db2fb3a518089d0510c53b0";
    sha256 = "1c7pjrvifncbdyngs2bv185imxbcbq64nka8gshhp8n2ns6fids6";
  };

  nativeBuildInputs = [
    autoreconfHook
    gfortran
  ];

  buildInputs = [
    mpi
    fftwMpi
  ];

  # Required for compilation with gcc-14
  env.NIX_CFLAGS_COMPILE = "-Wno-error=incompatible-pointer-types";

  preConfigure = ''
    mkdir build && cd build

    configureFlagsArray+=(
      --with-mpi=${lib.getDev mpi}
      CC=mpicc
      FC=mpif90
      MPICC=mpicc
      MPIFC=mpif90
    )
  '';

  doCheck = true;
  configureScript = "../configure";
  hardeningDisable = [ "format" ];

  meta = {
    description = "Portable C library of density functionals with van der Waals interactions for density functional theory";
    homepage = "https://libvdwxc.materialsmodeling.org/";

    license = with lib.licenses; [
      lgpl3Plus
      bsd3
    ];

    maintainers = [ lib.maintainers.sheepforce ];
    platforms = lib.platforms.unix;
  };
}
