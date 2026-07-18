{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  nix-update-script,
  nodejs,
}:

buildNpmPackage rec {
  pname = "json-sort-cli";
  version = "3.0.1";

  src = fetchFromGitHub {
    owner = "tillig";
    repo = "json-sort-cli";
    tag = "v${version}";
    hash = "sha256-wUuVQmmcevGfcoYq5tPzEFRyPMMtbW/CeE5vNoCKFXQ=";
  };

  npmDepsHash = "sha256-4sjP3ri52CunwLcbIJF6+qGgciiPmZKsrLnm50HX0PQ=";
  doCheck = true;

  checkPhase = ''
    runHook preCheck
    npm run test
    runHook postCheck
  '';

  dontNpmBuild = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    inherit (nodejs.meta) platforms;
    description = "CLI interface to json-stable-stringify";
    homepage = "https://github.com/tillig/json-sort-cli";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hasnep ];
    mainProgram = "json-sort";
  };
}
