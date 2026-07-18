{
  lib,
  fetchFromGitHub,
  curl,
  flex,
  json_c,
  postgresql,
  postgresqlBuildExtension,
}:

postgresqlBuildExtension (finalAttrs: {
  pname = "repmgr";
  version = "5.5.0";

  src = fetchFromGitHub {
    owner = "EnterpriseDB";
    repo = "repmgr";
    tag = "v${finalAttrs.version}";
    hash = "sha256-8G2CzzkWTKEglpUt1Gr7d/DuHJvCIEjsbYDMl3Zt3cs=";
  };

  nativeBuildInputs = [ flex ];

  buildInputs = postgresql.buildInputs ++ [
    curl
    json_c
  ];

  meta = {
    description = "Replication manager for PostgreSQL cluster";
    homepage = "https://repmgr.org/";
    license = lib.licenses.postgresql;
    maintainers = with lib.maintainers; [ zimbatm ];
    platforms = postgresql.meta.platforms;
  };
})
