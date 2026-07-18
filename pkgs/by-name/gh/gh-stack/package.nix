{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "gh-stack";
  version = "0.0.4";

  src = fetchFromGitHub {
    owner = "github";
    repo = "gh-stack";
    tag = "v${finalAttrs.version}";
    hash = "sha256-sC8QQ4H2WsEVf4FjaWlPvMlVlVc3J6IVmdlqNbJ3M6I=";
  };

  vendorHash = "sha256-JnuqORtdW+xz8pAGAFXdjRey8jCEj+miJiyfY7gzRSU=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;

  ldflags = [
    "-s"
    "-w"
    "-X=github.com/github/gh-stack/cmd.Version=${finalAttrs.version}"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "GitHub CLI extension to use stacked PRs";
    homepage = "https://github.github.com/gh-stack/";
    changelog = "https://github.com/github/gh-stack/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ethancedwards8 ];
    mainProgram = "gh-stack";
    downloadPage = "https://github.com/github/gh-stack/";
  };
})
