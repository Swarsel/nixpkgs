{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  writableTmpDirAsHomeHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "alistral";
  version = "0.6.7";

  src = fetchFromGitHub {
    owner = "RustyNova016";
    repo = "Alistral";
    tag = "v${finalAttrs.version}";
    hash = "sha256-XsN4UyIXkd0YVtO/q9EcFP/sBYkH9leISmbJZ93ef6E=";
  };

  nativeBuildInputs = [
    pkg-config
  ]
  ++ lib.optionals (stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    installShellFiles
    # When invoked in postInstall, alistral tries to write logfiles to its config dir on invocation, and fails if it can't find a writable one.
    # The config dir falls back to a directory relative to $HOME on both Darwin and Linux, so setting a writable $HOME is enough.
    writableTmpDirAsHomeHook
  ];

  buildInputs = [
    openssl
  ];

  cargoHash = "sha256-KFNFioZ/5moC5FNXw+hA+NrPjsqu+3V8A5mtZ4FZUHw=";
  # Wants to create config file where it s not allowed
  doCheck = false;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd alistral \
      --bash <($out/bin/alistral --generate bash) \
      --fish <($out/bin/alistral --generate fish) \
      --zsh <($out/bin/alistral --generate zsh)
  '';

  # Would be cleaner with an "--all-features" option
  buildFeatures = [ "full" ];
  buildNoDefaultFeatures = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Power tools for Listenbrainz";
    homepage = "https://rustynova016.github.io/Alistral/";
    changelog = "https://github.com/RustyNova016/Alistral/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      jopejoe1
      RustyNova
    ];

    mainProgram = "alistral";
  };
})
