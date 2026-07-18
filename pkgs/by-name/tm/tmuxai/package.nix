{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:

buildGoModule (finalAttrs: {
  pname = "tmuxai";
  version = "2.3.1";

  src = fetchFromGitHub {
    owner = "alvinunreal";
    repo = "tmuxai";
    tag = "v${finalAttrs.version}";
    hash = "sha256-CZDGiOi0eD/HTpOXhlRyCw1MaA0gRZI1k0ET5O2xC3I=";
  };

  vendorHash = "sha256-Wzc7EDaW0fA76Fh4obqyAHiowXXxNbJXknkHXFBcKjY=";
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
    writableTmpDirAsHomeHook
  ];

  __darwinAllowLocalNetworking = true;

  ldflags = [
    "-s"
    "-X=github.com/alvinunreal/tmuxai/internal.Version=v${finalAttrs.version}"
    "-X=github.com/alvinunreal/tmuxai/internal.Commit=${finalAttrs.src.rev}"
    "-X=github.com/alvinunreal/tmuxai/internal.Date=1970-01-01T00:00:00Z"
  ];

  versionCheckKeepEnvironment = [ "HOME" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "AI-Powered, Non-Intrusive Terminal Assistant";
    homepage = "https://github.com/alvinunreal/tmuxai";
    changelog = "https://github.com/alvinunreal/tmuxai/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ vinnymeller ];
    mainProgram = "tmuxai";
  };
})
