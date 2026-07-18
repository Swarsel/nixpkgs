{
  lib,
  stdenv,
  fetchFromGitHub,
  libusb1,
  openssl,
  pkg-config,
  rage,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "age-plugin-ledger";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "Ledger-Donjon";
    repo = "age-plugin-ledger";
    tag = "v${finalAttrs.version}";
    hash = "sha256-g5GbWXhaGEafiM3qkGlRXHcOzPZl2pbDWEBPg4gQWcg=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libusb1
    openssl
  ];

  cargoHash = "sha256-zR7gJNIqno50bQo0kondCxEC0ZgssqXNqACF6fnLDrc=";

  nativeCheckInputs = [
    rage
  ];

  # rage (used in tests) panics on locale detection in the Nix sandbox without
  # a valid LANG set.
  preCheck = lib.optionalString stdenv.hostPlatform.isDarwin ''
    export LANG=en_US.UTF-8
  '';

  meta = {
    description = "Ledger Nano plugin for age";
    homepage = "https://github.com/Ledger-Donjon/age-plugin-ledger";

    license = with lib.licenses; [
      mit
      asl20
    ];

    maintainers = with lib.maintainers; [ erdnaxe ];
    mainProgram = "age-plugin-ledger";
  };
})
