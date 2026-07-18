{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPackages,
  installShellFiles,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rattler-build";
  version = "0.68.0";

  src = fetchFromGitHub {
    owner = "prefix-dev";
    repo = "rattler-build";
    tag = "v${finalAttrs.version}";
    hash = "sha256-dS+PLxG5HfORy3hCEipS1rCoqCttHcqwsvIXwE5lQ/w=";
  };

  nativeBuildInputs = [
    pkg-config
    installShellFiles
  ];

  buildInputs = [
    openssl
  ];

  cargoHash = "sha256-uJjS0dE89XRy1irTZv1piH2Mm9/CqeNuUJl8Ntc4V8c=";
  doCheck = false; # test requires network access

  postInstall = lib.optionalString (stdenv.hostPlatform.emulatorAvailable buildPackages) (
    let
      emulator = stdenv.hostPlatform.emulator buildPackages;
    in
    ''
      installShellCompletion --cmd rattler-build \
        --bash <(${emulator} $out/bin/rattler-build completion --shell bash) \
        --fish <(${emulator} $out/bin/rattler-build completion --shell fish) \
        --zsh <(${emulator} $out/bin/rattler-build completion --shell zsh)
    ''
  );

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  cargoBuildFlags = [ "--bin rattler-build" ]; # other bin like `generate-cli-docs` shouldn't be distributed.
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Universal package builder for Windows, macOS and Linux";
    homepage = "https://rattler.build/";
    changelog = "https://github.com/prefix-dev/rattler-build/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      genga898
      xiaoxiangmoe
    ];

    mainProgram = "rattler-build";
  };
})
