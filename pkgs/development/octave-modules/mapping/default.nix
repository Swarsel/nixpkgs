{
  lib,
  fetchurl,
  buildOctavePackage,
  gdal,
  geometry, # >= 4.0.0
  io, # >= 2.2.7
}:

buildOctavePackage rec {
  pname = "mapping";
  version = "1.4.3";

  src = fetchurl {
    url = "mirror://sourceforge/octave/${pname}-${version}.tar.gz";
    sha256 = "sha256-IYiyRjnHCHhAFy5gR/dcuKWY11gSCubggQzmMAqGmhs=";
  };

  propagatedBuildInputs = [
    gdal
  ];

  requiredOctavePackages = [
    io
    geometry
  ];

  meta = {
    description = "Simple mapping and GIS .shp .dxf and raster file functions";
    homepage = "https://gnu-octave.github.io/packages/mapping/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ravenjoad ];
  };
}
