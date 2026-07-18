{
  lib,
  stdenv,
  fetchFromGitHub,
  antlr2,
  coreutils,
  curl,
  flex,
  gsl,
  libtool,
  netcdf,
  netcdfcxx4,
  udunits,
  which,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nco";
  version = "5.3.2";

  src = fetchFromGitHub {
    owner = "nco";
    repo = "nco";
    rev = finalAttrs.version;
    hash = "sha256-p7GUUgMlZFnJ5kA3x4QpcVmQUQNsjMr2Q8Mrzf6k54Q=";
  };

  postPatch = ''
    substituteInPlace src/nco/nco_fl_utl.c \
      --replace "/bin/cp" "${coreutils}/bin/cp"

    substituteInPlace src/nco/nco_fl_utl.c \
      --replace "/bin/mv" "${coreutils}/bin/mv"
  '';

  nativeBuildInputs = [
    antlr2
    flex
    which
  ];

  buildInputs = [
    coreutils
    curl
    gsl
    netcdf
    netcdfcxx4
    udunits
  ];

  makeFlags = lib.optionals stdenv.hostPlatform.isDarwin [ "LIBTOOL=${libtool}/bin/libtool" ];
  enableParallelBuilding = true;

  meta = {
    description = "NetCDF Operator toolkit";
    longDescription = "The NCO (netCDF Operator) toolkit manipulates and analyzes data stored in netCDF-accessible formats, including DAP, HDF4, and HDF5";
    homepage = "https://nco.sourceforge.net/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ bzizou ];
    platforms = lib.platforms.unix;
  };
})
