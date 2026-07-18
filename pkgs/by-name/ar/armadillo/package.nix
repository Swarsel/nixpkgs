{
  lib,
  stdenv,
  fetchurl,
  blas,
  cmake,
  hdf5,
  lapack,
  superlu,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "armadillo";
  version = "15.2.3";

  src = fetchurl {
    url = "mirror://sourceforge/arma/armadillo-${finalAttrs.version}.tar.xz";
    hash = "sha256-AYLWfWlJ5DR6C8YvyMJ5O+frIDxx8Z7f+T+MRf1KgZA=";
  };

  patches = [ ./use-unix-config-on-OS-X.patch ];
  nativeBuildInputs = [ cmake ];

  buildInputs = [
    blas
    lapack
    superlu
    hdf5
  ];

  cmakeFlags = [
    "-DLAPACK_LIBRARY=${lapack}/lib/liblapack${stdenv.hostPlatform.extensions.sharedLibrary}"
    "-DDETECT_HDF5=ON"
  ];

  meta = {
    description = "C++ linear algebra library";
    homepage = "https://arma.sourceforge.net";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      juliendehos
    ];

    platforms = lib.platforms.unix;
  };
})
