{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nixosTests,
  pgweb,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "pgweb";
  version = "0.17.0";

  src = fetchFromGitHub {
    owner = "sosedoff";
    repo = "pgweb";
    rev = "v${finalAttrs.version}";
    hash = "sha256-3UWld72AN504+Bo8aIY31qMO1xIRL3MXG5ImzMeSoU8=";
  };

  postPatch = ''
    # Disable tests require network access.
    rm -f pkg/client/{client,dump}_test.go
  '';

  vendorHash = "sha256-7gfziA+rKwS6u63I6DaA2Fi/wvtr1rAJupSNJZB72dU=";

  checkFlags =
    let
      skippedTests = [
        # There is a `/tmp/foo` file on the test machine causing the test case to fail on macOS
        "TestParseOptions"
      ];
    in
    [
      "-skip"
      "${builtins.concatStringsSep "|" skippedTests}"
    ];

  ldflags = [
    "-s"
    "-w"
  ];

  passthru.tests = {
    version = testers.testVersion {
      version = "v${finalAttrs.version}";
      command = "pgweb --version";
      package = pgweb;
    };

    integration_test = nixosTests.pgweb;
  };

  meta = {
    description = "Web-based database browser for PostgreSQL";

    longDescription = ''
      A simple postgres browser that runs as a web server. You can view data,
      run queries and examine tables and indexes.
    '';

    homepage = "https://sosedoff.github.io/pgweb/";
    changelog = "https://github.com/sosedoff/pgweb/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      zupo
      luisnquin
    ];

    mainProgram = "pgweb";
  };
})
