{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
}:

buildNpmPackage rec {
  pname = "pgraphs";
  version = "0.6.17";

  src = fetchFromGitHub {
    owner = "pg-format";
    repo = "pgraphs";
    tag = "v${version}";
    hash = "sha256-0Zo8Vg2KHhEGvO+vrbcP0ZTnfLtNTE2fqxq5LwPsJGs=";
  };

  npmDepsHash = "sha256-47zT3wlCnVIcv0Sst4lUWLUMiWftgvP60cOmHu65vB8=";
  dontNpmBuild = true;

  meta = {
    description = "Property Graph Exchange Format (PG) converter";
    homepage = "https://github.com/pg-format/pgraphs";
    changelog = "https://github.com/pg-format/pgraphs/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ luftmensch-luftmensch ];
    mainProgram = "pgraphs";
  };
}
