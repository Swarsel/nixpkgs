{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  graphqurl,
  nix-update-script,
  testers,
}:

buildNpmPackage rec {
  pname = "graphqurl";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "hasura";
    repo = "graphqurl";
    rev = "v${version}";
    hash = "sha256-q46DX/luUwBoVskKy9+hXOkpGmlh+lNRvwfcTn6DPN8=";
  };

  npmDepsHash = "sha256-TfKQWghcsVPPfn/a1A84sh0FT57WSnQt9uuiO1ScoAY=";
  dontNpmBuild = true;

  passthru = {
    tests = {
      graphqurl-version = testers.testVersion {
        package = graphqurl;
      };
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "CLI and JS library for making GraphQL queries";
    homepage = "https://github.com/hasura/graphqurl";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ bbigras ];
    mainProgram = "gq";
  };
}
