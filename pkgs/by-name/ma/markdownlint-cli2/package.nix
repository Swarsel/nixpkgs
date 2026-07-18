{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  markdownlint-cli2,
  nix-update-script,
  runCommand,
}:

buildNpmPackage rec {
  pname = "markdownlint-cli2";
  version = "0.22.1";

  src = fetchFromGitHub {
    owner = "DavidAnson";
    repo = "markdownlint-cli2";
    tag = "v${version}";
    hash = "sha256-ln7uYSwVSsVFiZ+etkb/Vsa6wn0UvPHM6pPBfkQElso=";
  };

  postPatch = ''
    rm -f .npmrc
    ln -s ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-yUMqSjFrXDtH6lPUSCEDrQB+GssXEJKGvbPn8Dgeejo=";
  dontNpmBuild = true;

  passthru = {
    tests = {
      smoke = runCommand "${pname}-test" { nativeBuildInputs = [ markdownlint-cli2 ]; } ''
        markdownlint-cli2 ${markdownlint-cli2}/lib/node_modules/markdownlint-cli2/CHANGELOG.md > $out
      '';
    };

    updateScript = nix-update-script {
      extraArgs = [ "--generate-lockfile" ];
    };
  };

  meta = {
    description = "Fast, flexible, configuration-based command-line interface for linting Markdown/CommonMark files with the markdownlint library";
    homepage = "https://github.com/DavidAnson/markdownlint-cli2";
    changelog = "https://github.com/DavidAnson/markdownlint-cli2/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      anthonyroussel
      natsukium
    ];

    mainProgram = "markdownlint-cli2";
  };
}
