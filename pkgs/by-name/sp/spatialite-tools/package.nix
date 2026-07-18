{
  lib,
  stdenv,
  fetchurl,
  expat,
  freexl,
  geos,
  librttopo,
  libspatialite,
  libxml2,
  libz,
  minizip,
  pkg-config,
  proj,
  readosm,
  spatialite-tools,
  sqlite,
  testers,
}:

stdenv.mkDerivation rec {
  pname = "spatialite-tools";
  version = "5.1.0a";

  src = fetchurl {
    url = "https://www.gaia-gis.it/gaia-sins/spatialite-tools-sources/spatialite-tools-${version}.tar.gz";
    hash = "sha256-EZ40dY6AiM27Q+2BtKbq6ojHZLC32hkAGlUUslRVAc4=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    expat
    freexl
    geos
    librttopo
    libspatialite
    libxml2
    libz
    minizip
    proj
    readosm
    sqlite
  ];

  env = {
    NIX_LDFLAGS = toString [
      "-lm"
      "-lxml2"
      (lib.optionalString stdenv.hostPlatform.isDarwin "-liconv")
    ];
  };

  enableParallelBuilding = true;

  passthru.tests.version = testers.testVersion {
    version = "${libspatialite.version}";
    command = "! spatialite_tool --version";
    package = spatialite-tools;
  };

  meta = {
    description = "Complete sqlite3-compatible CLI front-end for libspatialite";
    homepage = "https://www.gaia-gis.it/fossil/spatialite-tools";

    license = with lib.licenses; [
      mpl11
      gpl2Plus
      lgpl21Plus
    ];

    maintainers = with lib.maintainers; [ dotlambda ];
    platforms = lib.platforms.unix;
    mainProgram = "spatialite_tool";
    teams = [ lib.teams.geospatial ];
  };
}
