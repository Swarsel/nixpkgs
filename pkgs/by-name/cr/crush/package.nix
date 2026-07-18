{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGo126Module,
  installShellFiles,
  nix-update-script,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:

buildGo126Module (finalAttrs: {
  pname = "crush";
  version = "0.81.0";

  src = fetchFromGitHub {
    owner = "charmbracelet";
    repo = "crush";
    tag = "v${finalAttrs.version}";
    hash = "sha256-FOvkCQxDW1dipzIzgQz2uvHIv6bm/TVV1WwhrvmBDWg=";
  };

  nativeBuildInputs = [
    installShellFiles
  ];

  vendorHash = "sha256-4gHvyEqiFhEvZ90lJbXeI/1fMMo6L19P/PD5Eu5YUmI=";
  nativeCheckInputs = [ writableTmpDirAsHomeHook ];

  checkFlags =
    let
      # these tests fail in the sandbox
      skippedTests = [
        "TestCoderAgent"
        "TestOpenAIClientStreamChoices"
        "TestGrepWithIgnoreFiles"
        "TestSearchImplementations"
        "TestDispatch_BinaryPassthroughExecutes"
      ];
    in
    [ "-skip=^${builtins.concatStringsSep "$|^" skippedTests}$" ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd crush \
      --bash <($out/bin/crush completion bash) \
      --fish <($out/bin/crush completion fish) \
      --zsh <($out/bin/crush completion zsh)
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __darwinAllowLocalNetworking = true;

  ldflags = [
    "-s"
    "-X=github.com/charmbracelet/crush/internal/version.Version=${finalAttrs.version}"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Glamourous AI coding agent for your favourite terminal";
    homepage = "https://github.com/charmbracelet/crush";
    changelog = "https://github.com/charmbracelet/crush/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.fsl11Mit;

    maintainers = with lib.maintainers; [
      x123
      malik
      davinci42
    ];

    mainProgram = "crush";
  };
})
