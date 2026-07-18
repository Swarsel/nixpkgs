{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "steamguard-cli";
  version = "0.18.2";

  src = fetchFromGitHub {
    owner = "dyc3";
    repo = "steamguard-cli";
    rev = "v${finalAttrs.version}";
    hash = "sha256-+WqqByn15UBcZzNqNNxt1NjTH6cCeCIpaCOeTFR1XB0=";
  };

  nativeBuildInputs = [ installShellFiles ];
  cargoHash = "sha256-AKkMx0FzNGPHPTja1Hll1+qvHtCzSUI44sGpU3OEkpc=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd steamguard \
      --bash <($out/bin/steamguard completion --shell bash) \
      --fish <($out/bin/steamguard completion --shell fish) \
      --zsh <($out/bin/steamguard completion --shell zsh)
  '';

  buildFeatures = [
    "keyring"
    "qr"
  ];

  # disable update check
  buildNoDefaultFeatures = true;

  meta = {
    description = "Linux utility for generating 2FA codes for Steam and managing Steam trade confirmations";
    homepage = "https://github.com/dyc3/steamguard-cli";
    changelog = "https://github.com/dyc3/steamguard-cli/releases/tag/v${finalAttrs.version}";
    license = with lib.licenses; [ gpl3Only ];

    maintainers = with lib.maintainers; [
      surfaceflinger
      sigmasquadron
    ];

    platforms = lib.platforms.linux;
    mainProgram = "steamguard";
  };
})
