{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  writableTmpDirAsHomeHook,
}:
buildGoModule (finalAttrs: {
  pname = "gh-enhance";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "dlvhdr";
    repo = "gh-enhance";
    rev = "v${finalAttrs.version}";
    hash = "sha256-sfTAhrZZPUOAyltlblDIgd/pKMSdugXQqCZ0fBqMcQM=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-us25CXQC3cd3BTa+wOYArbBiMtwkgpfeCQoD3S7+3rU=";
  nativeCheckInputs = [ writableTmpDirAsHomeHook ];

  checkFlags = [
    # requires network
    "-skip=TestFullOutput"
  ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd gh-enhance \
      --bash <($out/bin/gh-enhance completion bash) \
      --fish <($out/bin/gh-enhance completion fish) \
      --zsh <($out/bin/gh-enhance completion zsh)
  '';

  doInstallCheck = true;

  ldflags = [
    "-s"
    "-w"
    "-X github.com/dlvhdr/gh-enhance/cmd.Version=${finalAttrs.version}"
  ];

  meta = {
    description = "Terminal UI for GitHub Actions";
    homepage = "https://www.gh-dash.dev/enhance";
    changelog = "https://github.com/dlvhdr/gh-enhance/releases/tag/${finalAttrs.src.rev}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ replicapra ];
    mainProgram = "gh-enhance";
  };
})
