{
  lib,
  stdenv,
  fetchFromGitHub,
  oniguruma,
  pkg-config,
  rustPlatform,
  tailwindcss,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "oranda";
  version = "0.6.5";

  src = fetchFromGitHub {
    owner = "axodotdev";
    repo = "oranda";
    rev = "v${finalAttrs.version}";
    hash = "sha256-FVd8NQVtzlZsDY40ZMJDdaX+6Q5jUxZHUq2v+kDFVOk=";
  };

  nativeBuildInputs = [
    pkg-config
    tailwindcss
  ];

  buildInputs = [
    oniguruma
  ];

  cargoHash = "sha256-wPYgAbaoUVJoZT1nRCBsPziszkAubImZEKGrC2RAkEA=";

  env = {
    ORANDA_USE_TAILWIND_BINARY = true;
    RUSTONIG_SYSTEM_LIBONIG = true;
  }
  // lib.optionalAttrs stdenv.hostPlatform.isDarwin {
    # without this, tailwindcss fails with OpenSSL configuration error
    OPENSSL_CONF = "";
  };

  # requires internet access
  checkFlags = [
    "--skip=build"
    "--skip=integration"
  ];

  meta = {
    description = "Generate beautiful landing pages for your developer tools";
    homepage = "https://github.com/axodotdev/oranda";
    changelog = "https://github.com/axodotdev/oranda/blob/${finalAttrs.src.rev}/CHANGELOG.md";

    license = with lib.licenses; [
      asl20
      mit
    ];

    maintainers = [ ];
    mainProgram = "oranda";
  };
})
