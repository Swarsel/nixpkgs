{
  lib,
  stdenv,
  fetchFromGitHub,
  blas,
  cmake,
  lapack,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hmat-oss";
  version = "1.10.0";

  src = fetchFromGitHub {
    owner = "jeromerobert";
    repo = "hmat-oss";
    tag = finalAttrs.version;
    hash = "sha256-GnFlvZCEzSCcBVLjFWLe+AKXVA6UMs/gycrOJ2TBqrE=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    blas
    lapack
  ];

  cmakeFlags = [
    (lib.cmakeBool "HMAT_GIT_VERSION" false)
    # Find BLAS/LAPACK via pkg-config to avoid linking against Accelerate on Darwin.
    (lib.cmakeBool "BLA_PREFER_PKGCONFIG" true)
    (lib.cmakeFeature "CBLAS_INCLUDE_DIR" "${lib.getDev blas}/include")
  ];

  meta = {
    description = "Hierarchical matrix C/C++ library";
    homepage = "https://github.com/jeromerobert/hmat-oss";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ gdinh ];
    platforms = lib.platforms.unix;
  };
})
