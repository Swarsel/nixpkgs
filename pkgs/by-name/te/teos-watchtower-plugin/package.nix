{
  lib,
  openssl,
  pkg-config,
  protobuf,
  rustPlatform,
  rustfmt,
  teos,
}:

rustPlatform.buildRustPackage {
  inherit (teos) version src;
  pname = "teos-watchtower-plugin";

  nativeBuildInputs = [
    pkg-config
    protobuf
    rustfmt
  ];

  buildInputs = [
    openssl
  ];

  cargoHash = "sha256-lod5I94T4wGwXEDtvh2AyaDYM0byCfaSBP8emKV7+3M=";
  __darwinAllowLocalNetworking = true;
  buildAndTestSubdir = "watchtower-plugin";

  meta = teos.meta // {
    description = "Lightning watchtower plugin for clightning";
    mainProgram = "watchtower-client";
  };
}
