{
  lib,
  fetchFromGitHub,
  buildGoModule,
  testers,
  wakatime-cli,
  writableTmpDirAsHomeHook,
}:

buildGoModule (finalAttrs: {
  pname = "wakatime-cli";
  version = "2.15.0";

  src = fetchFromGitHub {
    owner = "wakatime";
    repo = "wakatime-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-jEQ9c0dejAEAgIyUeJ/PSsAFDUkNPsaU0FW3AVDmL7g=";
  };

  vendorHash = "sha256-xrIvtUfOFOgcKJ+2VgUgOzF2Cwp3NPBf39yXgAHN/cQ=";
  nativeCheckInputs = [ writableTmpDirAsHomeHook ];

  checkFlags =
    let
      skippedTests = [
        "TestLoadParams_APIKey_FromVault_Err_Darwin"
      ];
    in
    [ "-skip=^${builtins.concatStringsSep "$|^" skippedTests}$" ];

  __darwinAllowLocalNetworking = true;

  ldflags = [
    "-s"
    "-w"
    "-X github.com/wakatime/wakatime-cli/pkg/version.Version=${finalAttrs.version}"
  ];

  passthru.tests.version = testers.testVersion {
    command = "HOME=$(mktemp -d) wakatime-cli --version";
    package = wakatime-cli;
  };

  meta = {
    description = "WakaTime command line interface";
    homepage = "https://wakatime.com/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ sigmanificient ];
    mainProgram = "wakatime-cli";
  };
})
