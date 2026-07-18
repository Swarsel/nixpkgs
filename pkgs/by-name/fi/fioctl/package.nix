{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  fioctl,
  installShellFiles,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "fioctl";
  version = "0.43";

  src = fetchFromGitHub {
    owner = "foundriesio";
    repo = "fioctl";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-hZ8jkIbNY2z4M7sHCYq6vVacetThcoYPJjkr8PFQmQA=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-SUjHHsZGi5C5juYdJJ0Z7i6P6gySQOdn1VaReCIwfzU=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd fioctl \
      --bash <($out/bin/fioctl completion bash) \
      --fish <($out/bin/fioctl completion fish) \
      --zsh <($out/bin/fioctl completion zsh)
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/foundriesio/fioctl/subcommands/version.Commit=${finalAttrs.src.rev}"
  ];

  passthru.tests.version = testers.testVersion {
    version = "v${finalAttrs.version}";
    command = "HOME=$(mktemp -d) fioctl version";
    package = fioctl;
  };

  meta = {
    description = "Simple CLI to manage your Foundries Factory";
    homepage = "https://github.com/foundriesio/fioctl";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      matthewcroughan
    ];

    mainProgram = "fioctl";
  };
})
