{
  lib,
  fetchFromGitHub,
  pcsclite,
  pkg-config,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "age-plugin-openpgp-card";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "wiktor-k";
    repo = "age-plugin-openpgp-card";
    rev = "v${finalAttrs.version}";
    hash = "sha256-z1Q1Sg6qcQwhNDI6dCMf4BejZn5K9VzqLCVvkisB//k=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ pcsclite ];
  cargoHash = "sha256-MrtCm41Q/Zs3FZCkdsNX30vFFuxIHNHHz4fbhMXuxD4=";

  meta = {
    description = "Age plugin for using ed25519 on OpenPGP Card devices (Yubikeys, Nitrokeys)";
    homepage = "https://github.com/wiktor-k/age-plugin-openpgp-card";

    license = with lib.licenses; [
      asl20
      mit
    ];

    maintainers = with lib.maintainers; [ nukdokplex ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];

    mainProgram = "age-plugin-openpgp-card";
  };
})
