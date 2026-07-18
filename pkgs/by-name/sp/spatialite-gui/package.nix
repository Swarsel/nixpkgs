{
  lib,
  stdenv,
  fetchurl,
  curl,
  desktopToDarwinBundle,
  freexl,
  geos,
  libpq,
  librasterlite2,
  librttopo,
  libspatialite,
  libwebp,
  libxlsxwriter,
  libxml2,
  lz4,
  minizip,
  openjpeg,
  pkg-config,
  proj,
  sqlite,
  virtualpg,
  wxwidgets_3_2,
  xz,
  zstd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "spatialite-gui";
  version = "2.1.0-beta1";

  src = fetchurl {
    url = "https://www.gaia-gis.it/gaia-sins/spatialite-gui-sources/spatialite_gui-${finalAttrs.version}.tar.gz";
    hash = "sha256-ukjZbfGM68P/I/aXlyB64VgszmL0WWtpuuMAyjwj2zM=";
  };

  nativeBuildInputs = [
    libpq.pg_config
    pkg-config
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin desktopToDarwinBundle;

  buildInputs = [
    curl
    freexl
    geos
    libpq
    librasterlite2
    librttopo
    libspatialite
    libwebp
    libxlsxwriter
    libxml2
    lz4
    minizip
    openjpeg
    proj
    sqlite
    virtualpg
    wxwidgets_3_2
    xz
    zstd
  ];

  postFixup = lib.optionalString stdenv.hostPlatform.isDarwin ''
    rm -fr $out/share
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Graphical user interface for SpatiaLite";
    homepage = "https://www.gaia-gis.it/fossil/spatialite_gui";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.unix;
    mainProgram = "spatialite_gui";
    teams = [ lib.teams.geospatial ];
  };
})
