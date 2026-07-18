{
  lib,
  fetchFromGitHub,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "trunk";
  version = "0.21.14";

  src = fetchFromGitHub {
    owner = "trunk-rs";
    repo = "trunk";
    rev = "v${finalAttrs.version}";
    hash = "sha256-0T8ZkBA1Zf4z2HXYeBwJ+2EGoUpxGrqSb4fS4CnL28A=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
  cargoHash = "sha256-/5zvbSlMzZHxnAwuu0Jd6WVVjxJtIAQpRwZZHgYyPbs=";
  # requires network
  checkFlags = [ "--skip=tools::tests::download_and_install_binaries" ];

  meta = {
    description = "Build, bundle & ship your Rust WASM application to the web";
    homepage = "https://github.com/trunk-rs/trunk";
    license = with lib.licenses; [ asl20 ];
    maintainers = with lib.maintainers; [ ctron ];
    mainProgram = "trunk";
  };
})
