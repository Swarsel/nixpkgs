{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  bzip2,
  cli11,
  cmake,
  expat,
  fmt_11,
  libosmium,
  libpq,
  lua,
  luajit,
  nlohmann_json,
  opencv,
  potrace,
  proj,
  protozero,
  python3,
  testers,
  zlib,
  withLuaJIT ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "osm2pgsql";
  version = "2.3.1";

  src = fetchFromGitHub {
    owner = "osm2pgsql-dev";
    repo = "osm2pgsql";
    rev = finalAttrs.version;
    hash = "sha256-tvcnXsbHjke/25PKfWMANHI9K3CModTW8uxI2JxCWi4=";
  };

  postPatch = ''
    # Remove bundled libraries
    rm -r contrib
  '';

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    boost
    bzip2
    cli11
    expat
    fmt_11
    libosmium
    libpq
    nlohmann_json
    opencv
    potrace
    proj
    protozero
    (python3.withPackages (
      p: with p; [
        psycopg2
        pyosmium
      ]
    ))
    zlib
  ]
  ++ lib.optional withLuaJIT luajit
  ++ lib.optional (!withLuaJIT) lua;

  cmakeFlags = [
    (lib.cmakeBool "EXTERNAL_LIBOSMIUM" true)
    (lib.cmakeBool "EXTERNAL_PROTOZERO" true)
    (lib.cmakeBool "EXTERNAL_FMT" true)
    (lib.cmakeBool "WITH_LUAJIT" withLuaJIT)
  ];

  passthru.tests.version = testers.testVersion {
    package = finalAttrs.finalPackage;
  };

  meta = {
    description = "OpenStreetMap data to PostgreSQL converter";
    homepage = "https://osm2pgsql.org";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      jglukasik
      das-g
    ];

    platforms = lib.platforms.unix;
    teams = [ lib.teams.geospatial ];
  };
})
