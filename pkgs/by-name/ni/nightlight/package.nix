{
  lib,
  fetchFromGitHub,
  makeWrapper,
  nix-update-script,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "nightlight";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "smudge";
    repo = "nightlight";
    tag = "v${version}";
    hash = "sha256-NOphjrqsnO5693Zw3NkX3c74I3PdJ8W6sxYwOEJ1yCU=";
  };

  cargoHash = "sha256-v5Oo1AxwvJs66l9CtVjO+WfwgsM16zSLT1SSnDi1kSo=";

  checkFlags = [
    "--skip=repl"
    "--skip=printer::tests"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "CLI tool for configuring Night Shift macOS";
    homepage = "https://github.com/smudge/nightlight";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ aspauldingcode ];
    platforms = lib.platforms.darwin;
    mainProgram = "nightlight";
  };
}
