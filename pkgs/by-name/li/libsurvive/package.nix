{
  lib,
  stdenv,
  fetchFromGitHub,
  blas,
  cmake,
  eigen,
  lapack,
  libglut,
  libusb1,
  pkg-config,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libsurvive";
  version = "1.01";

  src = fetchFromGitHub {
    owner = "collabora";
    repo = "libsurvive";
    tag = "v${finalAttrs.version}";
    hash = "sha256-NcxdTKra+YkLt/iu9+1QCeQZLV3/qlhma2Ns/+ZYVsk=";
    # Fixes 'Unknown CMake command "cnkalman_generate_code"'
    fetchSubmodules = true;
  };

  # https://github.com/collabora/libsurvive/issues/272
  postPatch = ''
    substituteInPlace survive.pc.in \
      libs/cnkalman/cnkalman.pc.in libs/cnkalman/libs/cnmatrix/cnmatrix.pc.in \
      --replace '$'{exec_prefix}/@CMAKE_INSTALL_LIBDIR@ @CMAKE_INSTALL_FULL_LIBDIR@
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    libglut
    lapack
    libusb1
    blas
    zlib
    eigen
  ];

  meta = {
    description = "Open Source Lighthouse Tracking System";
    homepage = "https://github.com/collabora/libsurvive";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})
