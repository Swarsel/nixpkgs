{
  lib,
  fetchFromGitHub,
  buildGoModule,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "gh-ost";
  version = "1.1.10";

  src = fetchFromGitHub {
    owner = "github";
    repo = "gh-ost";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1QdGPAvQgh533oAFwVxtGKPGJ7rfq7tG/zy8VUqJLq0=";
  };

  vendorHash = null;

  checkFlags =
    let
      # Skip tests that require docker daemon
      skippedTests = [
        "TestApplier"
        "TestEventsStreamer"
        "TestMigrator"
      ];
    in
    [ "-skip=^${builtins.concatStringsSep "$|^" skippedTests}$" ];

  ldflags = [
    "-s"
    "-w"
    "-X main.AppVersion=${finalAttrs.version}"
  ];

  passthru.tests.version = testers.testVersion {
    package = finalAttrs.finalPackage;
  };

  meta = {
    description = "Triggerless online schema migration solution for MySQL";
    homepage = "https://github.com/github/gh-ost";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ aaronjheng ];
    mainProgram = "gh-ost";
  };
})
