{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  kubevirt,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "kubevirt";
  version = "1.8.4";

  src = fetchFromGitHub {
    owner = "kubevirt";
    repo = "kubevirt";
    rev = "v${finalAttrs.version}";
    hash = "sha256-4MQtONb8opLDBLtGr+5oDrOQkkK1q4RlMXDcqyilarM=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = null;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd virtctl \
      --bash <($out/bin/virtctl completion bash) \
      --fish <($out/bin/virtctl completion fish) \
      --zsh <($out/bin/virtctl completion zsh)
  '';

  ldflags = [
    "-X kubevirt.io/client-go/version.gitCommit=v${finalAttrs.version}"
    "-X kubevirt.io/client-go/version.gitTreeState=clean"
    "-X kubevirt.io/client-go/version.gitVersion=v${finalAttrs.version}"
  ];

  subPackages = [ "cmd/virtctl" ];
  tags = [ "selinux" ];

  passthru.tests.version = testers.testVersion {
    version = "v${finalAttrs.version}";
    command = "virtctl version --client";
    package = kubevirt;
  };

  meta = {
    description = "Client tool to use advanced features such as console access";
    homepage = "https://kubevirt.io/";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      haslersn
      johanot
    ];

    mainProgram = "virtctl";
  };
})
