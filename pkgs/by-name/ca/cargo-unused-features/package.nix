{
  lib,
  curl,
  fetchCrate,
  libgit2,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cargo-unused-features";
  version = "0.2.0";

  src = fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-gdwIbbQDw/DgBV9zY2Rk/oWjPv1SS/+oFnocsMo2Axo=";
  };

  nativeBuildInputs = [
    curl.dev
    pkg-config
  ];

  buildInputs = [
    curl
    libgit2
    openssl
  ];

  cargoHash = "sha256-IiS4d6knNKqoUkt0sRSJ+vNluqllS3mTsnphrafugIo=";

  env = {
    LIBGIT2_NO_VENDOR = 1;
  };

  meta = {
    description = "Tool to find potential unused enabled feature flags and prune them";
    homepage = "https://github.com/timonpost/cargo-unused-features";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      matthiasbeyer
    ];

    mainProgram = "unused-features";
  };
})
