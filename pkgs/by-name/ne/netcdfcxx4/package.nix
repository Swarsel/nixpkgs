{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  curl,
  fetchpatch,
  hdf5,
  netcdf,
  ninja,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "netcdf-cxx4";
  version = "4.3.1";

  src = fetchFromGitHub {
    owner = "Unidata";
    repo = "netcdf-cxx4";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-GZ6n7dW3l8Kqrk2Xp2mxRTUWWQj0XEd2LDTG9EtrfhY=";
  };

  patches = [
    # This fix is included upstream, remove with next upgrade
    ./cmake-h5free.patch
    ./netcdf.patch
    (fetchpatch {
      hash = "sha256-AS2nQIXEW1iSR2LAzvTB04M+kyureJAn63+mPNoCq+0=";
      name = "cmake-4.patch";
      url = "https://github.com/Unidata/netcdf-cxx4/commit/8455a69867a420cffa226978174bc0f99029bc8b.patch?full_index=1";
    })
  ];

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    netcdf
    hdf5
    curl
  ];

  preConfigure = ''
    appendToVar cmakeFlags "-Dabs_top_srcdir=$(readlink -f ./)"
  '';

  doCheck = true;

  preCheck = ''
    export HDF5_PLUGIN_PATH=${netcdf}/lib/hdf5-plugins
  '';

  enableParallelChecking = false;

  meta = {
    description = "C++ API to manipulate netcdf files";
    homepage = "https://www.unidata.ucar.edu/software/netcdf/";
    license = lib.licenses.free;
    platforms = lib.platforms.unix;
    mainProgram = "ncxx4-config";
    broken = stdenv.hostPlatform.isDarwin;
  };
})
