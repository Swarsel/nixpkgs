{
  lib,
  fetchFromGitHub,
  postgresql,
  postgresqlBuildExtension,
}:

postgresqlBuildExtension (finalAttrs: {
  pname = "pg_uuidv7";
  version = "1.7.0";

  src = fetchFromGitHub {
    owner = "fboulnois";
    repo = "pg_uuidv7";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1zZT3HqRnVw2pIkxFmXqYwYenXGbM91JB0jTwsdtgnw=";
  };

  meta = {
    description = "Tiny Postgres extension to create version 7 UUIDs";
    homepage = "https://github.com/fboulnois/pg_uuidv7";
    changelog = "https://github.com/fboulnois/pg_uuidv7/blob/main/CHANGELOG.md";
    license = lib.licenses.mpl20;
    maintainers = [ ];
    platforms = postgresql.meta.platforms;
  };
})
