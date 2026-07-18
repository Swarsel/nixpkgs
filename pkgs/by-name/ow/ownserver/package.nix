{
  lib,
  fetchFromGitHub,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ownserver";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "Kumassy";
    repo = "ownserver";
    tag = "v${finalAttrs.version}";
    hash = "sha256-bseDssSMerBlzlCvL3rD3X6ku5qDRYvI1wxq2W7As5k=";
  };

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    openssl
  ];

  cargoHash = "sha256-EzuG3ev/6EqTGi0J0wppZz+cZJiH12WbBQLKOrTxTzs=";
  # `proxy_client::fetch_token_test` spins up a warp server during `cargo test`.
  __darwinAllowLocalNetworking = true;
  # Bump vendored `metrics` past 0.24.2 which fixes a borrow-checker error
  # under newer rustc (https://github.com/rust-lang/rust/issues/141402).
  cargoPatches = [ ./bump-metrics.patch ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Expose your local game server to the Internet";
    homepage = "https://github.com/Kumassy/ownserver";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jaredmontoya ];
    mainProgram = "ownserver";
  };
})
