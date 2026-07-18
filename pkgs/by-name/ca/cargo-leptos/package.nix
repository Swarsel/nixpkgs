{
  lib,
  stdenv,
  fetchFromGitHub,
  openssl,
  pkg-config,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cargo-leptos";
  version = "0.3.7";

  src = fetchFromGitHub {
    owner = "leptos-rs";
    repo = "cargo-leptos";
    rev = "v${finalAttrs.version}";
    hash = "sha256-w1kd/eOjNHYAramUvHdgj0ogFqgHDQ1P+ItKTTLL9hU=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
  cargoHash = "sha256-p0mku5B9RtU0E7ny1Izhr2diBLgDH8HR2/B92MvBfws=";

  env = {
    OPENSSL_NO_VENDOR = 1;
  }
  // lib.optionalAttrs stdenv.hostPlatform.isDarwin {
    # Fix for C++ compiler version on darwin for wasm-opt
    CRATE_CC_NO_DEFAULTS = 1;
  };

  doCheck = false; # Check phase tries to query crates.io
  # https://github.com/leptos-rs/cargo-leptos#dependencies
  buildFeatures = [ "no_downloads" ]; # cargo-leptos will try to install missing dependencies on its own otherwise

  meta = {
    description = "Build tool for the Leptos web framework";
    homepage = "https://github.com/leptos-rs/cargo-leptos";
    changelog = "https://github.com/leptos-rs/cargo-leptos/releases/tag/v${finalAttrs.version}";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ benwis ];
    mainProgram = "cargo-leptos";
  };
})
