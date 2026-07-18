{
  lib,
  fetchFromGitLab,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cargo-info";
  version = "0.7.7";

  src = fetchFromGitLab {
    owner = "imp";
    repo = "cargo-info";
    tag = finalAttrs.version;
    hash = "sha256-MrkYGUd1jsAqIVYWe7YDZaq7NPv/mHQqLS7GFrYYIo8=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  cargoHash = "sha256-C8BIgJeUPvFzf0LTBMZ3oyE0eWh5HH6aobhUAHBxxKU=";

  meta = {
    description = "Cargo subcommand to show crates info from crates.io";
    homepage = "https://gitlab.com/imp/cargo-info";
    changelog = "https://gitlab.com/imp/cargo-info/-/blob/${finalAttrs.src.tag}/CHANGELOG.md";

    license = with lib.licenses; [
      mit
      asl20
    ];

    maintainers = with lib.maintainers; [
      matthiasbeyer
    ];

    mainProgram = "cargo-info";
  };
})
