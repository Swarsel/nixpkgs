{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "podman-tui";
  version = "1.11.3";

  src = fetchFromGitHub {
    owner = "containers";
    repo = "podman-tui";
    tag = "v${finalAttrs.version}";
    hash = "sha256-qeUYn9FDhuLaNjeJekmQYjR1PJJx4/sKBuxT5qOLCj8=";
  };

  vendorHash = null;
  env.CGO_ENABLED = 0;

  checkFlags =
    let
      skippedTests = [
        # Disable flaky tests
        "TestDialogs"
        "TestVoldialogs"
      ];
    in
    [ "-skip=^${builtins.concatStringsSep "$|^" skippedTests}$" ];

  ldflags = [
    "-s"
    "-w"
  ];

  tags = [
    "containers_image_openpgp"
    "remote"
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin "darwin";

  passthru.tests.version = testers.testVersion {
    version = "v${finalAttrs.version}";
    command = "HOME=$(mktemp -d) podman-tui version";
    package = finalAttrs.finalPackage;
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Podman Terminal UI";
    homepage = "https://github.com/containers/podman-tui";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ aaronjheng ];
    mainProgram = "podman-tui";
  };
})
