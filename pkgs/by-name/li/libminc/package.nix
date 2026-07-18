{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  hdf5,
  netcdf,
  nifticlib,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libminc";
  version = "2.5.0";

  src = fetchFromGitHub {
    owner = "BIC-MNI";
    repo = "libminc";
    tag = "release-${finalAttrs.version}";
    hash = "sha256-IQS8JDkZwLR73I5GpWKRT07zj7Ek2tdZ2TOjy02OjaQ=";
  };

  postPatch = ''
    patchShebangs .
  '';

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    zlib
    nifticlib
  ];

  propagatedBuildInputs = [
    netcdf
    hdf5
  ];

  cmakeFlags = [
    "-DLIBMINC_MINC1_SUPPORT=ON"
    "-DLIBMINC_BUILD_SHARED_LIBS=ON"
    "-DLIBMINC_USE_NIFTI=ON"
    "-DLIBMINC_USE_SYSTEM_NIFTI=ON"
  ];

  doCheck = !stdenv.hostPlatform.isDarwin;

  # -j1: see https://github.com/BIC-MNI/libminc/issues/110
  checkPhase = ''
    ctest -j1 --output-on-failure
  '';

  meta = {
    description = "Medical imaging library based on HDF5";
    homepage = "https://github.com/BIC-MNI/libminc";
    license = lib.licenses.free;
    maintainers = with lib.maintainers; [ bcdarwin ];
    platforms = lib.platforms.unix;
  };
})
