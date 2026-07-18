{
  lib,
  fetchFromGitHub,
  postgresql,
  postgresqlBuildExtension,
}:

postgresqlBuildExtension (finalAttrs: {
  pname = "pgmq";
  version = "1.11.1";

  src = fetchFromGitHub {
    owner = "pgmq";
    repo = "pgmq";
    tag = "v${finalAttrs.version}";
    hash = "sha256-BPOrQ7HcgTaTJIRzWUCG3iJN3mUjwIxa/wPxvJ1l4o4=";
  };

  dontConfigure = true;
  sourceRoot = "${finalAttrs.src.name}/pgmq-extension";

  meta = {
    description = "Lightweight message queue like AWS SQS and RSMQ but on Postgres";
    homepage = "https://tembo.io/pgmq";
    changelog = "https://github.com/pgmq/pgmq/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.postgresql;
    maintainers = with lib.maintainers; [ takeda ];
    platforms = postgresql.meta.platforms;
  };
})
