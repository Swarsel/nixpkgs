{
  lib,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  makeWrapper,
  nix-update-script,
  powerpipe,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "powerpipe";
  version = "1.2.7";

  src = fetchFromGitHub {
    owner = "turbot";
    repo = "powerpipe";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+8XgYi3ewso+UELkaUsghkOxYF58j1/cbo2wgKIeuIY=";
  };

  nativeBuildInputs = [
    installShellFiles
    makeWrapper
  ];

  vendorHash = "sha256-cTCgBCbXogd/5LYaXUVUc3nWZTJXMeRFB0hHWQfFi1g=";
  doCheck = true;

  checkFlags =
    let
      skippedTests = [
        # test fails in the original github.com/turbot/powerpipe project as well
        "TestGetAsSnapshotPropertyMap/card"
      ];
    in
    [ "-skip=^${builtins.concatStringsSep "$|^" skippedTests}$" ];

  postInstall = ''
    wrapProgram $out/bin/powerpipe \
      --set-default POWERPIPE_UPDATE_CHECK false \
      --set-default POWERPIPE_TELEMETRY none
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  proxyVendor = true;

  passthru = {
    tests.version = testers.testVersion {
      version = "v${finalAttrs.version}";
      command = "${lib.getExe powerpipe} --version";
      package = powerpipe;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Dynamically query your cloud, code, logs & more with SQL";
    homepage = "https://powerpipe.io/";
    changelog = "https://github.com/turbot/powerpipe/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ weitzj ];
    mainProgram = "powerpipe";
  };
})
