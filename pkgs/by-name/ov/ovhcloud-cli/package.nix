{
  lib,
  fetchFromGitHub,
  buildGo126Module,
  installShellFiles,
  testers,
}:

buildGo126Module (finalAttrs: {
  pname = "ovhcloud-cli";
  version = "0.12.0";

  src = fetchFromGitHub {
    owner = "ovh";
    repo = "ovhcloud-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-t9opJiNvSWhaVVILkhvfXRh9fQKrrbzuJZDJ+vRNvEc=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-gN6XQj0bjkeJq9coB7jBliyurrt4L+detXkTDSTN5lo=";
  env.CGO_ENABLED = 0;
  excludedPackages = [ "cmd/docgen" ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/ovh/ovhcloud-cli/internal/version.Version=${finalAttrs.version}"
  ];

  passthru.tests.version = testers.testVersion {
    command = "ovhcloud version";
    package = finalAttrs.finalPackage;
  };

  meta = {
    description = "Command Line Interface to manage your OVHcloud services";
    homepage = "https://github.com/ovh/ovhcloud-cli";
    changelog = "https://github.com/ovh/ovhcloud-cli/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.anthonyroussel ];
    mainProgram = "ovhcloud";
  };
})
