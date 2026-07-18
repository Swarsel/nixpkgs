{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "spirit";
  version = "0.15.1";

  src = fetchFromGitHub {
    owner = "block";
    repo = "spirit";
    tag = "v${finalAttrs.version}";
    hash = "sha256-kcFNDW02ReUEbwLVos2Jth/bSAEAWZZ1Tpv3xpxY9jE=";
  };

  vendorHash = "sha256-qgLmkZ1pYvnZ5lr9GCvg9mC8oW/34BjoFXY3NKzpRwA=";

  ldflags = [
    "-s"
    "-w"
    "-X=main.version=${finalAttrs.version}"
    "-X=main.commit=${finalAttrs.src.rev}"
    "-X=main.date=1970-01-01T00:00:00Z"
  ];

  subPackages = [ "cmd/spirit" ];

  passthru = {
    tests.version = testers.testVersion {
      package = finalAttrs.finalPackage;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Online schema change tool for MySQL";
    homepage = "https://github.com/block/spirit";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ aaronjheng ];
    mainProgram = "spirit";
  };
})
