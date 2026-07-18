{
  lib,
  fetchFromGitHub,
  buildGoModule,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "go-jsonnet";
  version = "0.22.0";

  src = fetchFromGitHub {
    owner = "google";
    repo = "go-jsonnet";
    tag = "v${finalAttrs.version}";
    hash = "sha256-O7b26aobvs1gHsUNM2RZ/WnIMpFJOa/XbupttTMJ8LA=";
  };

  vendorHash = "sha256-uFCvMmiZVaRYhaORI92W0pkDjDZNiWIcop70FssJiZo=";

  ldflags = [
    "-s"
    "-w"
  ];

  subPackages = [ "cmd/jsonnet*" ];

  passthru.tests.version = testers.testVersion {
    version = "v${finalAttrs.version}";
    package = finalAttrs.finalPackage;
  };

  meta = {
    description = "Implementation of Jsonnet in pure Go";
    homepage = "https://github.com/google/go-jsonnet";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      nshalman
    ];

    mainProgram = "jsonnet";
  };
})
