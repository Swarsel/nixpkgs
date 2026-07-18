{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  roxctl,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "roxctl";
  version = "4.11.1";

  src = fetchFromGitHub {
    owner = "stackrox";
    repo = "stackrox";
    rev = finalAttrs.version;
    sha256 = "sha256-1+I/piqSFIJsy3PCSs1z7BNmi4Sz+SeuVfAoi0k11IU=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-mNZCsk7qZVej7yN8z/gAYWgSheCBj2sTF7pkmJbkW1w=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd roxctl \
      --bash <($out/bin/roxctl completion bash) \
      --fish <($out/bin/roxctl completion fish) \
      --zsh <($out/bin/roxctl completion zsh)
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/stackrox/rox/pkg/version/internal.MainVersion=${finalAttrs.version}"
  ];

  subPackages = [ "roxctl" ];

  passthru.tests.version = testers.testVersion {
    command = "roxctl version";
    package = roxctl;
  };

  meta = {
    description = "Command-line client of the StackRox Kubernetes Security Platform";
    homepage = "https://www.stackrox.io";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ stehessel ];
    mainProgram = "roxctl";
  };
})
