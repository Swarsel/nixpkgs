{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "okms-cli";
  version = "0.4.4";

  src = fetchFromGitHub {
    owner = "ovh";
    repo = "okms-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-S3A3X1Inrnqf4+Sz7e6mqL+vzrz2huIfvNSV6cV5NIU=";
  };

  vendorHash = "sha256-GJG6cZ1FIWUNjDvcuOav7gPrgaKsfEI7U9lkPq+2H7E=";

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
    "-X main.commit=${finalAttrs.src.rev}"
    "-X main.date=unknown"
  ];

  passthru = {
    tests.version = testers.testVersion {
      command = "okms version";
      package = finalAttrs.finalPackage;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Command Line Interface to interact with your OVHcloud KMS services";
    homepage = "https://github.com/ovh/okms-cli";
    changelog = "https://github.com/ovh/okms-cli/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.anthonyroussel ];
    mainProgram = "okms";
  };
})
