{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "tint";
  version = "0.1.7";

  src = fetchFromGitHub {
    owner = "ashish0kumar";
    repo = "tint";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Y2Jb/YF7rpEAmDVI5wEB+Sy7Ap2XxNrKQfnAogVdYSY=";
  };

  vendorHash = null;
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Command-line tool to recolor images using theme palettes";
    homepage = "https://github.com/ashish0kumar/tint";
    changelog = "https://github.com/ashish0kumar/tint/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ashish0kumar ];
    platforms = lib.platforms.unix;
    mainProgram = "tint";
  };
})
