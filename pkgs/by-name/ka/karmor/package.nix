{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  karmor,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "karmor";
  version = "1.4.9";

  src = fetchFromGitHub {
    owner = "kubearmor";
    repo = "kubearmor-client";
    rev = "v${finalAttrs.version}";
    hash = "sha256-iTXUb66B6ONeP7oz+vg2Zkte9OjQYrPffh+zanLWTO0=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-LA2qKCWR5akyVmK0qzVS4rCX8WNPGXrqq1585xTDDrE=";
  # integration tests require network access
  doCheck = false;

  postInstall = ''
    mv $out/bin/{kubearmor-client,karmor}
  ''
  + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd karmor \
      --bash <($out/bin/karmor completion bash) \
      --fish <($out/bin/karmor completion fish) \
      --zsh  <($out/bin/karmor completion zsh)
  '';

  ldflags = [
    "-s"
    "-w"
    "-X=github.com/kubearmor/kubearmor-client/selfupdate.BuildDate=1970-01-01"
    "-X=github.com/kubearmor/kubearmor-client/selfupdate.GitSummary=${finalAttrs.version}"
  ];

  passthru.tests = {
    version = testers.testVersion {
      command = "karmor version || true";
      package = karmor;
    };
  };

  meta = {
    description = "Client tool to help manage KubeArmor";
    homepage = "https://kubearmor.io";
    changelog = "https://github.com/kubearmor/kubearmor-client/releases/v${finalAttrs.version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      kashw2
    ];

    mainProgram = "karmor";
  };
})
