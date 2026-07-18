{
  lib,
  fetchFromGitHub,
  dbus,
  openssl,
  pkg-config,
  rustPlatform,
  udev,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cargo-v5";
  version = "0.12.1";

  src = fetchFromGitHub {
    owner = "vexide";
    repo = "cargo-v5";
    tag = "v${finalAttrs.version}";
    hash = "sha256-uIJcl1WfL96tvJ5QebbqnsP4nQqW7aCp4XYXgfu7CuY=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    dbus
    udev
    openssl
  ];

  cargoHash = "sha256-D7zRkzJwh0jBTUFJhggG7Bc5ixMZ4YLtaqZihEQN6hM=";

  meta = {
    description = "Cargo tool for working with VEX V5 Rust projects";
    homepage = "https://github.com/vexide/cargo-v5";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ max-niederman ];
    mainProgram = "cargo-v5";
  };
})
