{
  lib,
  stdenv,
  fetchFromGitHub,
  perl,
  sqlite,
  testers,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tippecanoe";
  version = "2.79.0";

  src = fetchFromGitHub {
    owner = "felt";
    repo = "tippecanoe";
    tag = finalAttrs.version;
    hash = "sha256-oEGjeOJWOV7ZO6GjpzC+rbvxyKDm7w64NQ6m43Wa30k=";
  };

  buildInputs = [
    sqlite
    zlib
  ];

  makeFlags = [ "PREFIX=$(out)" ];
  # https://github.com/felt/tippecanoe/issues/148
  doCheck = false;
  nativeCheckInputs = [ perl ];
  enableParallelBuilding = true;

  passthru.tests.version = testers.testVersion {
    version = "v${finalAttrs.version}";
    package = finalAttrs.finalPackage;
  };

  meta = {
    description = "Build vector tilesets from large collections of GeoJSON features";
    homepage = "https://github.com/felt/tippecanoe";
    license = lib.licenses.bsd2;
    platforms = lib.platforms.unix;
    mainProgram = "tippecanoe";
    teams = [ lib.teams.geospatial ];
  };
})
