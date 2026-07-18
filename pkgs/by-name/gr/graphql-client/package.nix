{
  lib,
  fetchCrate,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "graphql-client";
  version = "0.16.0";

  src = fetchCrate {
    inherit (finalAttrs) version;
    hash = "sha256-zWNarJDBSnZeFPQnF8nHOkFG8x0UDChi8l79OBNFA6A=";
    crateName = "graphql_client_cli";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  cargoHash = "sha256-LYRdK+wOoaJ/qkJoNC+enaqlMfeACDvNA1iyNEgTXCg=";

  meta = {
    description = "GraphQL tool for Rust projects";
    homepage = "https://github.com/graphql-rust/graphql-client";

    license = with lib.licenses; [
      asl20 # or
      mit
    ];

    maintainers = with lib.maintainers; [ bbigras ];
    mainProgram = "graphql-client";
  };
})
