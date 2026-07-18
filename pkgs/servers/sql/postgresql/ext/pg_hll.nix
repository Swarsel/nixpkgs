{
  lib,
  fetchFromGitHub,
  fetchpatch,
  postgresql,
  postgresqlBuildExtension,
}:

postgresqlBuildExtension (finalAttrs: {
  pname = "pg_hll";
  version = "2.18";

  src = fetchFromGitHub {
    owner = "citusdata";
    repo = "postgresql-hll";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Latdxph1Ura8yKEokEjalJ+/GY+pAKOT3GXjuLprj6c=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-gF4f+B4Gu/QEyCGMfKLmRK6lNwgfd8lML55wMkhsSY4=";
      name = "fix-postgresql-18.patch";
      url = "https://github.com/citusdata/postgresql-hll/commit/f998e234653ea397ddddc1278d1c02d8d011bd16.patch";
    })
  ];

  meta = {
    description = "HyperLogLog for PostgreSQL";
    homepage = "https://github.com/citusdata/postgresql-hll";
    changelog = "https://github.com/citusdata/postgresql-hll/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ thoughtpolice ];
    platforms = postgresql.meta.platforms;
  };
})
