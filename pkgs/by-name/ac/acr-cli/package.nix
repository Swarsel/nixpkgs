{
  lib,
  fetchFromGitHub,
  acr-cli,
  buildGoModule,
  nix-update-script,
  testers,
}:
buildGoModule (finalAttrs: {
  pname = "acr-cli";
  version = "0.19";

  src = fetchFromGitHub {
    owner = "Azure";
    repo = "acr-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Tb1OVVkEH6XmYjbe5ktgqRO/Ko1jhzpbhycZFalhgVg=";
  };

  vendorHash = null;
  # Test checks for legacy error which has been changed in newer go versions.
  checkFlags = [ "-skip=^TestParseDuration" ];
  # Required for some tests on darwin.
  __darwinAllowLocalNetworking = true;
  executable = [ "acr" ];

  ldflags = [
    "-s"
    "-w"
    "-X=github.com/Azure/acr-cli/version.Version=${finalAttrs.version}"
    "-X=github.com/Azure/acr-cli/version.Revision=${finalAttrs.src.rev}"
  ];

  passthru.tests.version = testers.testVersion {
    command = "acr version";
    package = acr-cli;
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Command Line Tool for interacting with Azure Container Registry Images";
    homepage = "https://github.com/Azure/acr-cli";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hausken ];
    mainProgram = "acr-cli";
  };
})
