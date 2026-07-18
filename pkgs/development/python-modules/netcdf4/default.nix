{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  certifi,
  cftime,
  curl,
  cython,
  hdf5,
  isPyPy,
  libjpeg,
  netcdf,
  numpy,
  oldest-supported-numpy,
  python,
  setuptools-scm,
  wheel,
  zlib,
}:

let
  version = "1.7.2";
  suffix = lib.optionalString (lib.match ''.*\.post[0-9]+'' version == null) "rel";
  tag = "v${version}${suffix}";
in
buildPythonPackage {
  inherit version;
  pname = "netcdf4";

  src = fetchFromGitHub {
    inherit tag;
    owner = "Unidata";
    repo = "netcdf4-python";
    hash = "sha256-orwCHKOSam+2eRY/yAduFYWREOkJlWIJGIZPZwQZ/RI=";
  };

  buildInputs = [
    curl
    hdf5
    libjpeg
    netcdf
    zlib
  ];

  env = {
    CURL_DIR = curl.dev;
    HDF5_DIR = lib.getDev hdf5;
    JPEG_DIR = libjpeg.dev;
    NETCDF4_DIR = netcdf;
    # Variables used to configure the build process
    USE_NCCONFIG = "0";
  }
  // lib.optionalAttrs stdenv.cc.isClang { NIX_CFLAGS_COMPILE = "-Wno-error=int-conversion"; };

  checkPhase = ''
    runHook preCheck

    pushd test/
    NO_NET=1 NO_CDL=1 ${python.interpreter} run_all.py

    runHook postCheck
  '';

  build-system = [
    cython
    oldest-supported-numpy
    setuptools-scm
    wheel
  ];

  dependencies = [
    certifi
    cftime
    numpy
  ];

  disabled = isPyPy;
  pyproject = true;
  pythonImportsCheck = [ "netCDF4" ];

  meta = {
    description = "Interface to netCDF library (versions 3 and 4)";
    homepage = "https://github.com/Unidata/netcdf4-python";
    changelog = "https://github.com/Unidata/netcdf4-python/raw/${tag}/Changelog";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
