{
  lib,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "containerlab";
  version = "0.76.1";

  src = fetchFromGitHub {
    owner = "srl-labs";
    repo = "containerlab";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1BE3PZvXUYSMvs65MS5kT3xp0P7pPjTXJKq6dEcmKqw=";
  };

  nativeBuildInputs = [
    installShellFiles
    versionCheckHook
  ];

  vendorHash = "sha256-x9G80vupcewg0FtIAnWSTQiPPWDIvfjqSpmmjAradwA=";

  checkFlags = [
    # Not available in sandbox:
    # - docker.sock needed for TestVerifyLinks
    # - /proc/modules needed for KernelModulesLoaded
    "-skip=^TestVerifyLinks$|^TestIsKernelModuleLoaded$"
  ];

  preCheck = ''
    # Fix failed TestLabelsInit test
    export USER="runner"
  '';

  postInstall = ''
    local INSTALL="$out/bin/containerlab"
    installShellCompletion --cmd containerlab \
      --bash <($out/bin/containerlab completion bash) \
      --fish <($out/bin/containerlab completion fish) \
      --zsh <($out/bin/containerlab completion zsh)
  '';

  doInstallCheck = true;

  ldflags = [
    "-s"
    "-w"
    "-X github.com/srl-labs/containerlab/cmd.Version=${finalAttrs.version}"
    "-X github.com/srl-labs/containerlab/cmd.commit=${finalAttrs.src.rev}"
    "-X github.com/srl-labs/containerlab/cmd.date=1970-01-01T00:00:00Z"
  ];

  versionCheckProgramArg = "version";

  meta = {
    description = "Container-based networking lab";
    homepage = "https://containerlab.dev/";
    changelog = "https://github.com/srl-labs/containerlab/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ _0x4A6F ];
    platforms = lib.platforms.linux;
    mainProgram = "containerlab";
  };
})
