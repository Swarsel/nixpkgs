{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "tlock";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "eklairs";
    repo = "tlock";
    tag = "v${finalAttrs.version}";
    hash = "sha256-O6erxzanSO5BjMnSSmn89w9SA+xyHhp0SSDkCk5hp8Y=";
    fetchSubmodules = true;
  };

  vendorHash = "sha256-G402CigSvloF/SI9Wbcts/So1impMUH5kroxDD/KKew=";

  excludedPackages = [
    "bubbletea"
    "scripts"
  ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/eklairs/tlock/tlock-internal/constants.VERSION=v${finalAttrs.version}"
  ];

  meta = {
    description = "Two-Factor Authentication Tokens Manager in Terminal";
    homepage = "https://github.com/eklairs/tlock";
    changelog = "https://github.com/eklairs/tlock/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ eklairs ];
    platforms = lib.platforms.unix;
    mainProgram = "tlock";
  };
})
