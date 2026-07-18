{
  lib,
  fetchFromGitHub,
  gitUpdater,
  postgresql,
  postgresqlBuildExtension,
}:

postgresqlBuildExtension (finalAttrs: {
  pname = "hypopg";
  version = "1.4.3";

  src = fetchFromGitHub {
    owner = "HypoPG";
    repo = "hypopg";
    tag = finalAttrs.version;
    hash = "sha256-d8j1mvn/9R8LEQCqstBxddRqQYZ9k4hcOrlQp7cPtYI=";
  };

  passthru = {
    updateScript = gitUpdater {
      ignoredVersions = "beta";
    };
  };

  meta = {
    description = "Hypothetical Indexes for PostgreSQL";
    homepage = "https://hypopg.readthedocs.io";
    changelog = "https://github.com/HypoPG/hypopg/releases/tag/${finalAttrs.version}";
    license = lib.licenses.postgresql;
    maintainers = with lib.maintainers; [ bbigras ];
    platforms = postgresql.meta.platforms;
  };
})
