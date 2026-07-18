{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  nix-update-script,
  nodejs,
  npmHooks,
  yarnBuildHook,
  yarnConfigHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "get-graphql-schema";
  version = "2.1.1";

  src = fetchFromGitHub {
    owner = "prisma-labs";
    repo = "get-graphql-schema";
    rev = "v${finalAttrs.version}";
    hash = "sha256-ujc0LGAqmo4SmItm4VcbBOtmUvL6aV1ppMm4fMmuSRs=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    npmHooks.npmInstallHook
    nodejs
  ];

  yarnOfflineCache = fetchYarnDeps {
    hash = "sha256-TZGNX8UHbolLyBmQNGTnFjgx3/3f2HNVQf/h9rIVJKs=";
    yarnLock = "${finalAttrs.src}/yarn.lock";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Fetch and print the GraphQL schema from a GraphQL HTTP endpoint";
    homepage = "https://github.com/prisma-labs/get-graphql-schema";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "get-graphql-schema";
  };
})
