{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  nix-update-script,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "tektoncd-cli-pac";
  version = "0.41.1";

  src = fetchFromGitHub {
    owner = "openshift-pipelines";
    repo = "pipelines-as-code";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ZuYaYBSDpU2NCBssw+j3cP4jV6t+pCezFrQRQBS/zKk=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = null;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd tkn-pac \
      --bash <($out/bin/tkn-pac completion bash) \
      --fish <($out/bin/tkn-pac completion fish) \
      --zsh <($out/bin/tkn-pac completion zsh)
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/openshift-pipelines/pipelines-as-code/pkg/params/version.Version=${finalAttrs.version}"
  ];

  subPackages = [ "cmd/tkn-pac" ];
  versionCheckProgramArg = "version";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "v([0-9.]+)"
    ];
  };

  meta = {
    description = "CLI for interacting with Tekton Pipelines as Code";

    longDescription = ''
      tkn-pac CLI Plugin – Easily manage Pipelines-as-Code repositories.
    '';

    homepage = "https://pipelinesascode.com";
    changelog = "https://github.com/openshift-pipelines/pipelines-as-code/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      netbrain
      vdemeester
      chmouel
    ];

    mainProgram = "tkn-pac";
  };
})
