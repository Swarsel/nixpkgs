{
  lib,
  stdenv,
  fetchFromGitHub,
  curl,
  libiconv,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cargo-fund";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "acfoltzer";
    repo = "cargo-fund";
    tag = finalAttrs.version;
    hash = "sha256-8mnCwWwReNH9s/gbxIhe7XdJRIA6BSUKm5jzykU5qMU=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    openssl
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    libiconv
    curl
  ];

  cargoHash = "sha256-9NozPJzQIuF2KHaT6t4qBU0qKtBbM05mHxzmHlU3Dr4=";
  # The tests need a GitHub API token.
  doCheck = false;

  meta = {
    description = "Discover funding links for your project's dependencies";
    homepage = "https://github.com/acfoltzer/cargo-fund";

    license = with lib.licenses; [
      mit # or
      asl20
    ];

    maintainers = with lib.maintainers; [ johntitor ];
    mainProgram = "cargo-fund";
  };
})
