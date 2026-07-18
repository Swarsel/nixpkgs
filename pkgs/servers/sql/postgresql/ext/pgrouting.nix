{
  lib,
  fetchFromGitHub,
  boost,
  cmake,
  perl,
  postgresql,
  postgresqlBuildExtension,
}:

postgresqlBuildExtension (finalAttrs: {
  pname = "pgrouting";
  version = "4.0.1";

  src = fetchFromGitHub {
    owner = "pgRouting";
    repo = "pgrouting";
    tag = "v${finalAttrs.version}";
    hash = "sha256-j3dlVcENhBveVmkuzWaLfHWy73OMDpC2FxrNQ4W6m9k=";
  };

  nativeBuildInputs = [
    cmake
    perl
  ];

  buildInputs = [ boost ];

  meta = {
    description = "PostgreSQL/PostGIS extension that provides geospatial routing functionality";
    homepage = "https://pgrouting.org/";
    changelog = "https://github.com/pgRouting/pgrouting/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ steve-chavez ];
    platforms = postgresql.meta.platforms;
    teams = [ lib.teams.geospatial ];
  };
})
