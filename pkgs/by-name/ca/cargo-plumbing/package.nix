{
  lib,
  fetchFromGitHub,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  stdenvNoCC,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cargo-plumbing";
  version = "0.0.3";

  src = fetchFromGitHub {
    owner = "crate-ci";
    repo = "cargo-plumbing";
    tag = "v${finalAttrs.version}";
    hash = "sha256-x8xH7XH91FtOn5knVL7mkcDTGvXtVVL70HIi8V9z54o=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
  cargoHash = "sha256-16rY8uk9ViEaYIqiZHHU1UApAdNXAETqgFzUWNto6po=";
  doCheck = !stdenvNoCC.hostPlatform.isDarwin;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Proposed plumbing commands for cargo";
    homepage = "https://github.com/crate-ci/cargo-plumbing";
    changelog = "https://github.com/crate-ci/cargo-plumbing/blob/v${finalAttrs.version}/CHANGELOG.md";

    license = with lib.licenses; [
      asl20 # or
      mit
    ];

    maintainers = with lib.maintainers; [
      secona
    ];
  };
})
