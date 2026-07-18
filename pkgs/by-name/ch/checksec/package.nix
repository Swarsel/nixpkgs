{
  lib,
  fetchFromGitHub,
  buildGoModule,
  checksec,
  # tests
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "checksec";
  version = "3.2.0";

  src = fetchFromGitHub {
    owner = "slimm609";
    repo = "checksec";
    tag = finalAttrs.version;
    hash = "sha256-vvfr5JsCTq1NWUfOOlHIjf+ToNNzP5Xps09XPLlG1zc=";
  };

  vendorHash = "sha256-sW2C39xhMQCyR8S1m0ZplVQxu42w+tNqjxH7VO5stGw=";

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  passthru.tests = {
    version = testers.testVersion {
      inherit (finalAttrs) version;
      package = checksec;
    };
  };

  meta = {
    description = "Tool for checking security bits on executables";
    homepage = "https://slimm609.github.io/checksec/";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      thoughtpolice
      sdht0
    ];

    platforms = lib.platforms.linux;
    mainProgram = "checksec";
  };
})
