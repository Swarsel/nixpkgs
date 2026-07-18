{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "bitrise";
  version = "2.40.7";

  src = fetchFromGitHub {
    owner = "bitrise-io";
    repo = "bitrise";
    rev = "v${finalAttrs.version}";
    hash = "sha256-kVFsVXLPul/2EP0X0q+uSBIGx95dt6Q2olzWBtr+uHI=";
  };

  vendorHash = null;
  env.CGO_ENABLED = 0;
  # many tests rely on writable $HOME/.bitrise and require network access
  doCheck = false;

  # resolves error: main module (github.com/bitrise-io/bitrise/v2) does not contain package github.com/bitrise-io/bitrise/v2/integrationtests/config
  excludedPackages = [
    "./integrationtests"
  ];

  ldflags = [
    "-X github.com/bitrise-io/bitrise/version.Commit=${finalAttrs.src.rev}"
    "-X github.com/bitrise-io/bitrise/version.BuildNumber=0"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "CLI for running your Workflows from Bitrise on your local machine";
    homepage = "https://bitrise.io/cli";
    changelog = "https://github.com/bitrise-io/bitrise/releases";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ofalvai ];
    platforms = lib.platforms.unix;
    mainProgram = "bitrise";
  };
})
