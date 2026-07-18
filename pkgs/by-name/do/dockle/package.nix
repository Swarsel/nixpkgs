{
  lib,
  fetchFromGitHub,
  btrfs-progs,
  buildGoModule,
  lvm2,
  pkg-config,
}:

buildGoModule (finalAttrs: {
  pname = "dockle";
  version = "0.4.15";

  src = fetchFromGitHub {
    owner = "goodwithtech";
    repo = "dockle";
    rev = "v${finalAttrs.version}";
    hash = "sha256-YoDgTKhXpN4UVF/+NDFxaEFwMj81RJaqfjr29t1UdLY=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    btrfs-progs
    lvm2
  ];

  vendorHash = "sha256-RMuTsPgqQoD2pdEaflNOOBZK5R8LbtcBzpAGocG8OGk=";

  preCheck = ''
    # Remove tests that use networking
    rm pkg/scanner/scan_test.go
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    runHook preInstallCheck
    $out/bin/dockle --help
    $out/bin/dockle --version | grep "dockle version ${finalAttrs.version}"
    runHook postInstallCheck
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/goodwithtech/dockle/pkg.version=${finalAttrs.version}"
  ];

  meta = {
    description = "Container Image Linter for Security";

    longDescription = ''
      Container Image Linter for Security.
      Helping build the Best-Practice Docker Image.
      Easy to start.
    '';

    homepage = "https://containers.goodwith.tech";
    changelog = "https://github.com/goodwithtech/dockle/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ jk ];
    mainProgram = "dockle";
  };
})
