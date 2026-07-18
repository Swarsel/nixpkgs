{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  buildPackages,
  installShellFiles,
  nix-update-script,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:
buildGoModule (finalAttrs: {
  pname = "foxglove-cli";
  version = "1.0.32";

  src = fetchFromGitHub {
    owner = "foxglove";
    repo = "foxglove-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-bc2YNCkTbO6qO2PyBI4UH7O48GNMgDfKKXWXjYaznBI=";
  };

  nativeBuildInputs = [
    installShellFiles
  ];

  vendorHash = "sha256-IXmkO7WIvy4ETMMHHJF6hS8ACRat/vnoiqaXyhw8u+M=";
  env.CGO_ENABLED = 0;

  checkFlags =
    let
      skippedTests = [
        "TestDoExport"
        "TestExport"
        "TestExportCommand"
        "TestImport"
        "TestImportCommand"
        "TestLogin"
        "TestLoginCommand"
      ];
    in
    [ "-skip=^${builtins.concatStringsSep "$|^" skippedTests}$" ];

  postInstall = lib.optionalString (stdenv.hostPlatform.emulatorAvailable buildPackages) (
    let
      emulator = stdenv.hostPlatform.emulator buildPackages;
    in
    ''
      installShellCompletion --cmd foxglove \
        --bash <(${emulator} $out/bin/foxglove completion bash) \
        --fish <(${emulator} $out/bin/foxglove completion fish) \
        --zsh <(${emulator} $out/bin/foxglove completion zsh)
    ''
  );

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
    writableTmpDirAsHomeHook
  ];

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${finalAttrs.version}"
  ];

  modRoot = "foxglove";
  tags = [ "netgo" ];
  versionCheckKeepEnvironment = [ "HOME" ];
  versionCheckProgram = "${placeholder "out"}/bin/${finalAttrs.meta.mainProgram}";
  versionCheckProgramArg = "version";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Interact with the Foxglove platform";
    homepage = "https://docs.foxglove.dev/docs/cli";
    changelog = "https://github.com/foxglove/foxglove-cli/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sascha8a ];
    mainProgram = "foxglove";
    downloadPage = "https://github.com/foxglove/foxglove-cli";
  };
})
