{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "pluto";
  version = "5.24.0";

  src = fetchFromGitHub {
    owner = "FairwindsOps";
    repo = "pluto";
    rev = "v${finalAttrs.version}";
    hash = "sha256-s46O/lSrF7kNaUWOrWnxQpLxWh/jbvI9k+t2jZqOAjU=";
  };

  vendorHash = "sha256-mNY1BmugJ7OauR3nSoiD7EpJ8dlk5PKPL/4urvPtOIY=";
  __darwinAllowLocalNetworking = true; # for tests

  ldflags = [
    "-w"
    "-s"
    "-X main.version=v${finalAttrs.version}"
  ];

  meta = {
    description = "Find deprecated Kubernetes apiVersions";
    homepage = "https://github.com/FairwindsOps/pluto";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      kashw2
    ];

    mainProgram = "pluto";
  };
})
