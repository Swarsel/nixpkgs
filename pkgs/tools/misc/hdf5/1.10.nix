{
  lib,
  stdenv,
  fetchurl,
  jdk,
  removeReferencesTo,
  zlib,
  cppSupport ? true,
  enableShared ? !stdenv.hostPlatform.isStatic,
  javaSupport ? false,
  zlibSupport ? true,
}:

let
  inherit (lib) optional;
in

stdenv.mkDerivation rec {
  pname = "hdf5";
  version = "1.10.11";

  src = fetchurl {
    url = "https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-${lib.versions.majorMinor version}/${pname}-${version}/src/${pname}-${version}.tar.bz2";
    sha256 = "sha256-Cvx32lxGIXcJR1u++8qRwMtvHqYozNjDYZbPbFpN4wQ=";
  };

  outputs = [
    "out"
    "dev"
  ];

  patches = [ ];
  nativeBuildInputs = [ removeReferencesTo ];
  buildInputs = optional javaSupport jdk;
  propagatedBuildInputs = optional zlibSupport zlib;

  configureFlags =
    optional enableShared "--enable-shared"
    ++ optional javaSupport "--enable-java"
    ++ optional cppSupport "--enable-cxx";

  postInstall = ''
    find "$out" -type f -exec remove-references-to -t ${stdenv.cc} '{}' +
    moveToOutput 'bin/h5cc' "''${!outputDev}"
    moveToOutput 'bin/h5c++' "''${!outputDev}"
    moveToOutput 'bin/h5fc' "''${!outputDev}"
    moveToOutput 'bin/h5pcc' "''${!outputDev}"
  '';

  meta = {
    description = "Data model, library, and file format for storing and managing data";

    longDescription = ''
      HDF5 supports an unlimited variety of datatypes, and is designed for flexible and efficient
      I/O and for high volume and complex data. HDF5 is portable and is extensible, allowing
      applications to evolve in their use of HDF5. The HDF5 Technology suite includes tools and
      applications for managing, manipulating, viewing, and analyzing data in the HDF5 format.
    '';

    homepage = "https://www.hdfgroup.org/HDF5/";
    license = lib.licenses.bsd3; # Lawrence Berkeley National Labs BSD 3-Clause variant
    maintainers = with lib.maintainers; [ stephen-huan ];
    platforms = lib.platforms.unix;
  };
}
