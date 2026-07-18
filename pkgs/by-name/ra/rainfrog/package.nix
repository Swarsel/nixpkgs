{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rainfrog,
  rustPlatform,
  testers,
}:
let
  version = "0.3.20";
in
rustPlatform.buildRustPackage {
  inherit version;
  pname = "rainfrog";

  src = fetchFromGitHub {
    owner = "achristmascarl";
    repo = "rainfrog";
    tag = "v${version}";
    hash = "sha256-Il8/vj56xQQXLefg9cCKMCRZ65+kp/NcXzFQUU0lKbQ=";
  };

  cargoHash = "sha256-aRjQYQQVOQu5VQWyqC0br/0w/EdZWWpkVgoFZStUE3I=";

  passthru = {
    tests.version = testers.testVersion {
      command = ''
        RAINFROG_DATA="$(mktemp -d)" rainfrog --version
      '';

      package = rainfrog;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Database management TUI for postgres";
    homepage = "https://github.com/achristmascarl/rainfrog";
    changelog = "https://github.com/achristmascarl/rainfrog/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ patka ];
    mainProgram = "rainfrog";
  };
}
