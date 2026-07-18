{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  nix-update-script,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:
buildGoModule (finalAttrs: {
  pname = "az-pim-cli";
  version = "1.15.0";

  src = fetchFromGitHub {
    owner = "netr0m";
    repo = "az-pim-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Pqc8pWicVORcoTXg7oT8SX1BwDRSjLHuqyyBZ6q7eio=";
  };

  patches = [
    # removes info we don't have from version command
    ./version-build-info.patch
  ];

  nativeBuildInputs = [
    installShellFiles
  ];

  vendorHash = "sha256-K4tv3IlVygV/aDR9twh60FX8pe4f0sXxoGNIsIV2oUA=";
  env.CGO_ENABLED = 0;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd az-pim-cli \
      --bash <($out/bin/az-pim-cli completion bash) \
      --fish <($out/bin/az-pim-cli completion fish) \
      --zsh <($out/bin/az-pim-cli completion zsh)
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    writableTmpDirAsHomeHook
    versionCheckHook
  ];

  ldflags = [
    "-s"
    "-X github.com/netr0m/az-pim-cli/cmd.version=v${finalAttrs.version}"
  ];

  versionCheckKeepEnvironment = [ "HOME" ];
  versionCheckProgramArg = "version";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "List and activate Azure Entra ID Privileged Identity Management roles from the CLI";
    homepage = "https://github.com/netr0m/az-pim-cli";
    changelog = "https://github.com/netr0m/az-pim-cli/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.da157 ];
    mainProgram = "az-pim-cli";
  };
})
