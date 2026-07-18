{
  lib,
  fetchFromGitHub,
  buildGoModule,
  crossplane-cli,
  nix-update-script,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "crossplane-cli";
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "crossplane";
    repo = "cli";
    rev = "v${finalAttrs.version}";
    hash = "sha256-pD91bH+K0nWDXv51mWtNlQVtBLi/zDEjAxAJ6ywd69g=";
  };

  vendorHash = "sha256-d7ZgiRF5LVxJoOwqfe0nHyJmakbexGEA7865QXUotP8=";

  ldflags = [
    "-s"
    "-w"
    "-X github.com/crossplane/crossplane-runtime/v2/pkg/version.version=v${finalAttrs.version}"
  ];

  subPackages = [ "cmd/crossplane" ];

  passthru.tests.version = testers.testVersion {
    version = "v${finalAttrs.version}";
    command = "crossplane version --client";
    package = crossplane-cli;
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Utility to make using Crossplane easier";
    homepage = "https://www.crossplane.io/";
    changelog = "https://github.com/crossplane/crossplane/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      selfuryon
      LorenzBischof
    ];

    mainProgram = "crossplane";
  };
})
