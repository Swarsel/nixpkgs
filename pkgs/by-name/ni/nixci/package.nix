{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  nix,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "nixci";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "srid";
    repo = "nixci";
    tag = finalAttrs.version;
    hash = "sha256-0VvZFclqwAcKN95eusQ3lgV0pp1NRUDcVXpVUC0P4QI=";
  };

  nativeBuildInputs = [
    pkg-config
    installShellFiles
    nix
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    openssl
  ];

  cargoHash = "sha256-iRsmB+ak6pWFtAdXEmGSc9dGdIuSbgLp3UT3SdOUOGQ=";

  # The rust program expects an environment (at build time) that points to the
  # devour-flake flake.
  env.DEVOUR_FLAKE = fetchFromGitHub {
    hash = "sha256-Vey9n9hIlWiSAZ6CCTpkrL6jt4r2JvT2ik9wa2bjeC0=";
    owner = "srid";
    repo = "devour-flake";
    tag = "v4";
  };

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd nixci \
      --bash <($out/bin/nixci completion bash) \
      --fish <($out/bin/nixci completion fish) \
      --zsh <($out/bin/nixci completion zsh)
  '';

  meta = {
    description = "Define and build CI for Nix projects anywhere";
    homepage = "https://github.com/srid/nixci";
    license = lib.licenses.agpl3Only;

    maintainers = with lib.maintainers; [
      shivaraj-bh
      rsrohitsingh682
    ];

    mainProgram = "nixci";
  };
})
