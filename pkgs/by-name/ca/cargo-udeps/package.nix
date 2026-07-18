{
  lib,
  stdenv,
  fetchFromGitHub,
  libiconv,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cargo-udeps";
  version = "0.1.61";

  src = fetchFromGitHub {
    owner = "est31";
    repo = "cargo-udeps";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-yT/EJWGGhQapbU1o1Gus1Vk5cAhso5ALTBecB3BH46g=";
  };

  nativeBuildInputs = [ pkg-config ];

  # TODO figure out how to use provided curl instead of compiling curl from curl-sys
  buildInputs = [
    openssl
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    libiconv
  ];

  cargoHash = "sha256-DGfAsBucFRFJkjmJkpTpNfQO79jaNa5NezXKf7hYYeM=";
  # Requires network access
  doCheck = false;

  meta = {
    description = "Find unused dependencies in Cargo.toml";
    homepage = "https://github.com/est31/cargo-udeps";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      b4dm4n
      matthiasbeyer
      chrjabs
    ];

    mainProgram = "cargo-udeps";
  };
})
