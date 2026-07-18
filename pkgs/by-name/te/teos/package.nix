{
  lib,
  fetchFromGitHub,
  openssl,
  pkg-config,
  protobuf,
  rustPlatform,
  rustfmt,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "teos";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "talaia-labs";
    repo = "rust-teos";
    tag = "v${finalAttrs.version}";
    hash = "sha256-UrzH9xmhVq12TcSUQ1AihCG1sNGcy/N8LDsZINVKFkY=";
  };

  nativeBuildInputs = [
    protobuf
    rustfmt
  ];

  cargoHash = "sha256-lod5I94T4wGwXEDtvh2AyaDYM0byCfaSBP8emKV7+3M=";
  __darwinAllowLocalNetworking = true;
  buildAndTestSubdir = "teos";
  passthru.updateScript = ./update.sh;

  meta = {
    description = "Lightning watchtower compliant with BOLT13, written in Rust";
    homepage = "https://github.com/talaia-labs/rust-teos";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ seberm ];
  };
})
