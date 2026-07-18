{
  lib,
  fetchFromGitHub,
  buildGoModule,
  mercure,
  nix-update-script,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "mercure";
  version = "0.21.8";

  src = fetchFromGitHub {
    owner = "dunglas";
    repo = "mercure";
    rev = "v${finalAttrs.version}";
    hash = "sha256-M/RzcR0FPkjBCRw0faRHF2ML25vzxcmNbAnnSWo+NFU=";
  };

  vendorHash = "sha256-KtjKrCqu+MAJpSL/HbLipxKbLOqDvzPOA5QN9ppu2aY=";
  doCheck = false;
  excludedPackages = [ "../cmd/mercure" ];

  ldflags = [
    "-s"
    "-w"
    "-X 'github.com/caddyserver/caddy/v2.CustomVersion=Mercure.rocks v${finalAttrs.version} Caddy'"
  ];

  sourceRoot = "${finalAttrs.src.name}/caddy";
  subPackages = [ "mercure" ];

  passthru = {
    tests.version = testers.testVersion {
      version = "v${finalAttrs.version}";
      command = "mercure version";
      package = mercure;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Open, easy, fast, reliable and battery-efficient solution for real-time communications";
    homepage = "https://github.com/dunglas/mercure";
    changelog = "https://github.com/dunglas/mercure/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Only;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "mercure";
  };
})
