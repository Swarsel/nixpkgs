{
  lib,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  makeWrapper,
  nix-update-script,
  steampipe,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "steampipe";
  version = "2.3.6";

  src = fetchFromGitHub {
    owner = "turbot";
    repo = "steampipe";
    tag = "v${finalAttrs.version}";
    hash = "sha256-b7F3Eo+/vJq8EqWig4O3y2UkqllWhUg38pend/JKeWA=";
  };

  postPatch = ''
    # Patch test that relies on looking up homedir in user struct to prefer ~
    substituteInPlace pkg/steampipeconfig/shared_test.go \
      --replace-fail 'filehelpers "github.com/turbot/go-kit/files"' "" \
      --replace-fail 'app_specific.InstallDir, _ = filehelpers.Tildefy("~/.steampipe")' 'app_specific.InstallDir = "~/.steampipe"';
  '';

  nativeBuildInputs = [
    installShellFiles
    makeWrapper
  ];

  vendorHash = "sha256-Xu5bxjmFRzABifA6GsvHbwh8CJgKrOlwfNXIH8XYz6s=";
  env.CGO_ENABLED = 0;
  doCheck = true;

  checkFlags =
    let
      skippedTests = [
        # panic: could not create backups directory: mkdir /var/empty/.steampipe: operation not permitted
        "TestTrimBackups"
        # Requires network access
        "TestVersionCheckerBodyReadFailure"
        "TestVersionCheckerNetworkFailures"
        "TestVersionCheckerTimeout"
      ];
    in
    [ "-skip=^${builtins.concatStringsSep "$|^" skippedTests}$" ];

  postInstall = ''
    wrapProgram $out/bin/steampipe \
      --set-default STEAMPIPE_UPDATE_CHECK false \
      --set-default STEAMPIPE_TELEMETRY none

    INSTALL_DIR=$(mktemp -d)
    installShellCompletion --cmd steampipe \
      --bash <($out/bin/steampipe --install-dir $INSTALL_DIR completion bash) \
      --fish <($out/bin/steampipe --install-dir $INSTALL_DIR completion fish) \
      --zsh <($out/bin/steampipe --install-dir $INSTALL_DIR completion zsh)
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
    "-X main.commit=${finalAttrs.src.rev}"
    "-X main.date=unknown"
    "-X main.builtBy=nixpkgs"
  ];

  proxyVendor = true;

  passthru = {
    tests.version = testers.testVersion {
      version = "v${finalAttrs.version}";
      command = "${lib.getExe steampipe} --version";
      package = steampipe;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Dynamically query your cloud, code, logs & more with SQL";
    homepage = "https://steampipe.io/";
    changelog = "https://github.com/turbot/steampipe/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.agpl3Only;

    maintainers = with lib.maintainers; [
      hardselius
      anthonyroussel
    ];

    mainProgram = "steampipe";
  };
})
