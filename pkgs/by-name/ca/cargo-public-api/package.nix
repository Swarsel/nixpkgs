{
  lib,
  curl,
  fetchCrate,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cargo-public-api";
  version = "0.52.0";

  src = fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-Z0r3lcuteU3DcXarBInYzkMaJSwfStdGi6ng2uRMXn8=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    curl
    openssl
  ];

  cargoHash = "sha256-k846yNUwytLTDjrEwQU5eMj2jIuAI6B1RtttZluijDY=";
  # Tests fail
  doCheck = false;

  meta = {
    description = "List and diff the public API of Rust library crates between releases and commits. Detect breaking API changes and semver violations";
    homepage = "https://github.com/cargo-public-api/cargo-public-api";
    changelog = "https://github.com/cargo-public-api/cargo-public-api/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ matthiasbeyer ];
    mainProgram = "cargo-public-api";
  };
})
