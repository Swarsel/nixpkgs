{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "namespace-cli";
  version = "0.0.531";

  src = fetchFromGitHub {
    owner = "namespacelabs";
    repo = "foundation";
    tag = "v${finalAttrs.version}";
    hash = "sha256-HlCyUwGwc261p2e4DK8J0VEN5EIO1UpbnxQ5f6oxaSs=";
  };

  vendorHash = "sha256-joxaA0x1Ldn82O5k+H9A1rsirBkfpOw+83E4GHCwKb8=";

  ldflags = [
    "-s"
    "-w"
    "-X namespacelabs.dev/foundation/internal/cli/version.Tag=v${finalAttrs.version}"
  ];

  subPackages = [
    "cmd/nsc"
    "cmd/ns"
    "cmd/docker-credential-nsc"
  ];

  meta = {
    description = "Command line interface for the Namespaces platform";
    homepage = "https://github.com/namespacelabs/foundation";
    changelog = "https://github.com/namespacelabs/foundation/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ techknowlogick ];
    mainProgram = "nsc";
  };
})
