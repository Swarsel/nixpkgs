{
  lib,
  fetchFromGitHub,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rsrpc";
  version = "0.27.1";

  src = fetchFromGitHub {
    owner = "SpikeHD";
    repo = "rsRPC";
    tag = "v${finalAttrs.version}";
    hash = "sha256-QzPFhdnZXiJZ4g+J9kB2v8duM2PgShptNRHliTYW3AU=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  cargoHash = "sha256-6Krtsj9hm8NqkFQMQ0MAPrFAjnzcTt4q5C1Fs5mx2SM=";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Rust implementation of the Discord RPC server";
    homepage = "https://github.com/SpikeHD/rsRPC";
    changelog = "https://github.com/SpikeHD/rsRPC/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.pyrox0 ];
    mainProgram = "rsrpc-cli";
  };
})
