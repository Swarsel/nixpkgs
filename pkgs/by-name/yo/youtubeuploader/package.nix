{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "youtubeuploader";
  version = "1.25.5";

  src = fetchFromGitHub {
    owner = "porjo";
    repo = "youtubeuploader";
    tag = "v${finalAttrs.version}";
    hash = "sha256-KG0x2+nTTB+d7Yon2xRdlhEqYr74jNPD4+3dKyccOdc=";
  };

  vendorHash = "sha256-wVfJnN9QgF7c2aI3OghfJW9Z6McZ+irgMRSkWvVi1DM=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-X main.appVersion=${finalAttrs.version}"
  ];

  versionCheckProgramArg = "-version";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Scripted uploads to Youtube using Golang";
    homepage = "https://github.com/porjo/youtubeuploader";
    changelog = "https://github.com/porjo/youtubeuploader/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    platforms = lib.platforms.unix;
    mainProgram = "youtubeuploader";
  };
})
