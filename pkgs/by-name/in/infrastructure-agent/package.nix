{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
}:
buildGoModule (finalAttrs: {
  pname = "infrastructure-agent";
  version = "1.77.0";

  src = fetchFromGitHub {
    owner = "newrelic";
    repo = "infrastructure-agent";
    rev = finalAttrs.version;
    hash = "sha256-QgyQ5fP8yIgmqHqLRn927pRmngOeKcdSaxXLDkcIwqI=";
  };

  vendorHash = "sha256-+ajMZ+kZ+m1vxyAfM+zvzTfcwkN63agdGoXPTNPC2i0=";
  env.CGO_ENABLED = if stdenv.hostPlatform.isDarwin then "1" else "0";

  ldflags = [
    "-s"
    "-w"
    "-X main.buildVersion=${finalAttrs.version}"
    "-X main.gitCommit=${finalAttrs.src.rev}"
  ];

  subPackages = [
    "cmd/newrelic-infra"
    "cmd/newrelic-infra-ctl"
    "cmd/newrelic-infra-service"
  ];

  meta = {
    description = "New Relic Infrastructure Agent";
    homepage = "https://github.com/newrelic/infrastructure-agent.git";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ davsanchez ];
    mainProgram = "newrelic-infra";
  };
})
