{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
}:
let
  version = "2.9.0";
in
rustPlatform.buildRustPackage {
  inherit version;
  pname = "catppuccin-whiskers";

  src = fetchFromGitHub {
    owner = "catppuccin";
    repo = "whiskers";
    tag = "v${version}";
    hash = "sha256-KU2cHBtz9rdfhulINRaQm+YZ7n8OBULrSHSSxmoitnk=";
  };

  cargoHash = "sha256-40IPDdxKTWYxsCfsECsXDGwfxXiTEIelxIGAFv3xlU4=";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Templating tool to simplify the creation of Catppuccin ports";
    homepage = "https://github.com/catppuccin/whiskers";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      Name
      isabelroses
    ];

    mainProgram = "whiskers";
  };
}
