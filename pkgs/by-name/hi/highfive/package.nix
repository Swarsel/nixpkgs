{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  hdf5,
  mpi ? hdf5.mpi,
  mpiSupport ? hdf5.mpiSupport,
}:

assert mpiSupport -> mpi != null;

stdenv.mkDerivation (finalAttrs: {
  pname = "highfive${lib.optionalString mpiSupport "-mpi"}";
  version = "3.3.0";

  src = fetchFromGitHub {
    owner = "highfive-devs";
    repo = "highfive";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-BuDvoQgMdZIDHYwXqigM78DQ+WtT+K0FdXERMUjmXc0=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    hdf5
  ];

  cmakeFlags = [
    "-DHIGHFIVE_EXAMPLES=OFF"
    "-DHIGHFIVE_UNIT_TESTS=OFF"
  ]
  ++ (lib.optionals mpiSupport [ "-DHDF5_IS_PARALLEL=ON" ]);

  passthru = {
    inherit mpiSupport mpi;
  };

  meta = {
    description = "Header-only C++ HDF5 interface";
    homepage = "https://github.com/highfive-devs/highfive";
    changelog = "https://github.com/highfive-devs/highfive/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.boost;
    maintainers = with lib.maintainers; [ robertodr ];
    platforms = lib.platforms.unix;
  };
})
