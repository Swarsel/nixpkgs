{
  lib,
  fetchFromGitHub,
  gitUpdater,
  postgresql,
  postgresqlBuildExtension,
  postgresqlTestExtension,
  testers,
}:

postgresqlBuildExtension (finalAttrs: {
  pname = "pg_repack";
  version = "1.5.3";

  src = fetchFromGitHub {
    owner = "reorg";
    repo = "pg_repack";
    tag = "ver_${finalAttrs.version}";
    hash = "sha256-Ufh/dKrKumRKeQ/CpwvxbjAmgILAn04BduPZMRvS+nU=";
  };

  buildInputs = postgresql.buildInputs;

  passthru.tests = {
    version = testers.testVersion {
      package = finalAttrs.finalPackage;
    };

    extension = postgresqlTestExtension {
      inherit (finalAttrs) finalPackage;
      sql = "CREATE EXTENSION pg_repack;";
    };
  };

  passthru.updateScript = gitUpdater {
    rev-prefix = "ver_";
  };

  meta = {
    inherit (postgresql.meta) platforms;
    description = "Reorganize tables in PostgreSQL databases with minimal locks";

    longDescription = ''
      pg_repack is a PostgreSQL extension which lets you remove bloat from tables and indexes, and optionally restore
      the physical order of clustered indexes. Unlike CLUSTER and VACUUM FULL it works online, without holding an
      exclusive lock on the processed tables during processing. pg_repack is efficient to boot,
      with performance comparable to using CLUSTER directly.
    '';

    homepage = "https://github.com/reorg/pg_repack";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    mainProgram = "pg_repack";
  };
})
