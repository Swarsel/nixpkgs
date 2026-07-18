{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  cunit,
  docbook5,
  gdalMinimal,
  geos,
  jitSupport,
  json_c,
  libiconv,
  libtool,
  libxml2,
  libxslt,
  llvm,
  pcre2,
  perl,
  pkg-config,
  postgresql,
  postgresqlBuildExtension,
  postgresqlTestExtension,
  postgresqlTestHook,
  proj,
  protobufc,
  sfcgal,
  which,
  withSfcgal ? false,
}:

let
  gdal = gdalMinimal;
in
postgresqlBuildExtension (finalAttrs: {
  pname = "postgis";
  version = "3.6.4";

  src = fetchFromGitHub {
    owner = "postgis";
    repo = "postgis";
    tag = finalAttrs.version;
    hash = "sha256-ZRBrZ23s0w3noFU6L3Ke9G/Z8d7xGGg3qo/2GPDpbK4=";
  };

  outputs = [
    "out"
    "doc"
  ];

  nativeBuildInputs = [
    autoconf
    automake
    libtool
    libxml2
    perl
    pkg-config
    protobufc
    which
  ]
  ++ lib.optional jitSupport llvm;

  buildInputs = [
    geos
    proj
    gdal
    json_c
    protobufc
    pcre2.dev
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin libiconv
  ++ lib.optional withSfcgal sfcgal;

  configureFlags =
    let
      isCross = stdenv.hostPlatform.config != stdenv.buildPlatform.config;
    in
    [
      (lib.withFeatureAs true "pgconfig" "${postgresql.pg_config}/bin/pg_config")
      (lib.withFeatureAs true "gdalconfig" "${gdal}/bin/gdal-config")
      (lib.withFeatureAs true "jsondir" (lib.getDev json_c))
      (lib.withFeatureAs true "xml2config" (lib.getExe' (lib.getDev libxml2) "xml2-config"))
      (lib.withFeatureAs withSfcgal "sfcgal" "${sfcgal}/bin/sfcgal-config")
      (lib.withFeature (!isCross) "json") # configure: error: cannot check for file existence when cross compiling
    ];

  makeFlags = [
    "PERL=${perl}/bin/perl"
  ];

  # postgis config directory assumes /include /lib from the same root for json-c library
  env.NIX_LDFLAGS = "-L${lib.getLib json_c}/lib";

  preConfigure = ''
    ./autogen.sh
  '';

  doCheck = stdenv.hostPlatform.isLinux;

  nativeCheckInputs = [
    postgresql
    postgresqlTestHook
    libxslt
  ];

  checkInputs = [
    cunit
  ];

  preCheck = ''
    substituteInPlace doc/postgis-out.xml --replace-fail "http://docbook.org/xml/5.0/dtd/docbook.dtd" "${docbook5}/xml/dtd/docbook/docbookx.dtd"
    # The test suite hardcodes it to use /tmp.
    export PGIS_REG_TMPDIR="$TMPDIR/pgis_reg"
  '';

  # create aliases for all commands adding version information
  postInstall = ''
    for prog in $out/bin/*; do # */
      ln -s $prog $prog-${finalAttrs.version}
    done

    mkdir -p $doc/share/doc/postgis
    mv doc/* $doc/share/doc/postgis/
  '';

  dontDisableStatic = true;
  postgresqlTestUserOptions = "LOGIN SUPERUSER";
  setOutputFlags = false;

  passthru.tests.extension = postgresqlTestExtension {
    inherit (finalAttrs) finalPackage;

    asserts = [
      {
        description = "postgis_version() returns correct values.";
        expected = "'${lib.versions.major finalAttrs.version}.${lib.versions.minor finalAttrs.version} USE_GEOS=1 USE_PROJ=1 USE_STATS=1'";
        query = "postgis_version()";
      }
    ]
    ++ lib.optional withSfcgal {
      description = "postgis_sfcgal_version() returns correct value.";
      expected = "'${sfcgal.version}'";
      query = "postgis_sfcgal_version()";
    };

    sql = ''
      CREATE EXTENSION postgis;
      CREATE EXTENSION postgis_raster;
      CREATE EXTENSION postgis_topology;
      -- st_makepoint goes through c code
      select st_makepoint(1, 1);
    ''
    + lib.optionalString withSfcgal ''
      CREATE EXTENSION postgis_sfcgal;
      CREATE TABLE geometries (
        name varchar,
        geom geometry(PolygonZ) NOT NULL
      );

      INSERT INTO geometries(name, geom) VALUES
        ('planar geom', 'PolygonZ((1 1 0, 1 2 0, 2 2 0, 2 1 0, 1 1 0))'),
        ('nonplanar geom', 'PolygonZ((1 1 1, 1 2 -1, 2 2 2, 2 1 0, 1 1 1))');

      SELECT name from geometries where cg_isplanar(geom);
    '';
  };

  meta = {
    inherit (postgresql.meta) platforms;
    description = "Geographic Objects for PostgreSQL";
    homepage = "https://postgis.net/";
    changelog = "https://git.osgeo.org/postgis/postgis/raw/tag/${finalAttrs.version}/NEWS";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    teams = [ lib.teams.geospatial ];
  };
})
