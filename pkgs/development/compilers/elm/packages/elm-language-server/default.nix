{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  nix-update-script,
}:

buildNpmPackage (finalAttrs: {
  pname = "elm-language-server";
  version = "2.8.0";

  src = fetchFromGitHub {
    owner = "elm-tooling";
    repo = "elm-language-server";
    tag = finalAttrs.version;
    hash = "sha256-OU6VoMu5Qnawxt02vT0B/37VipiBzlLBlZbQbnu8PEE=";
  };

  npmDepsHash = "sha256-jb59LiP2EZpTkc4o/t+9j287W01tDgbwFpAsWZCCL/k=";
  npmBuildScript = "compile";
  npmFlags = [ "--ignore-scripts" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Language server implementation for Elm";
    homepage = "https://github.com/elm-tooling/elm-language-server";
    changelog = "https://github.com/elm-tooling/elm-language-server/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "elm-language-server";
  };
})
