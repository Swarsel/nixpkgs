{
  lib,
  fetchFromGitHub,
  buildGoLatestModule,
  nix-update-script,
  nixosTests,
}:
let
  version = "2.17.4";
in
buildGoLatestModule {
  inherit version;
  pname = "wakapi";

  src = fetchFromGitHub {
    owner = "muety";
    repo = "wakapi";
    tag = version;
    hash = "sha256-pcKHDZH8CvRpKPaLyWPsHx7/U50xEq8JzbnEQG/9uYI=";
  };

  # Fix up reported version
  postPatch = "echo ${version} > version.txt";
  vendorHash = "sha256-bXIbHSclJ61D3u1+nXEIRhzw611uosnnXWqT9boDMP0=";
  # <https://github.com/muety/wakapi/blob/8c9442b348e4280b388e1073d805058a951ae78e/.github/workflows/release.yml#L60>
  env.GOEXPERIMENT = "greenteagc,jsonv2";

  checkFlags =
    let
      skippedTests = [
        # Skip tests that require network access
        "TestLoginHandlerTestSuite"
        "TestLoadOidcProviders"
        "TestUser_MinDataAge"
        "TestPublicNetUrl"
        "TestConfigTestSuite"
        "TestWakatimeRelayMiddlewareTestSuite"
        "TestServeHTTP_SkipNonPost"
        "TestWakatimeUtils"
        "TestWakatimeImporterTestSuite/TestCheckUrl"
      ];
    in
    [ "-skip=^${builtins.concatStringsSep "$|^" skippedTests}$" ];

  # Not a go module required by the project, contains development utilities
  excludedPackages = [ "scripts" ];

  ldflags = [
    "-s"
    "-w"
  ];

  passthru = {
    nixos = nixosTests.wakapi;
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Minimalist self-hosted WakaTime-compatible backend for coding statistics";
    homepage = "https://wakapi.dev/";
    changelog = "https://github.com/muety/wakapi/releases/tag/${version}";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      t4ccer
      isabelroses
    ];

    mainProgram = "wakapi";
  };
}
