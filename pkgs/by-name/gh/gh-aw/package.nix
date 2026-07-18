{
  lib,
  fetchFromGitHub,
  buildGoModule,
  versionCheckHook,
}:
buildGoModule (finalAttrs: {
  pname = "gh-aw";
  version = "0.80.9";

  src = fetchFromGitHub {
    owner = "github";
    repo = "gh-aw";
    tag = "v${finalAttrs.version}";
    hash = "sha256-2BGFKy/X8j0jYQc+W2rLZmZmPgCvZ+QOZweQaAQQJLM=";
  };

  vendorHash = "sha256-jxh8R/X12/QHxZOIKsTvS6FcDQSmJ7RJEvDnJuUr93A=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;

  ldflags = [
    "-s"
    "-w"
    "-X"
    "main.version=${finalAttrs.version}"
  ];

  subPackages = [ "cmd/gh-aw" ];

  meta = {
    description = "gh extension for GitHub Agentic Workflows";

    longDescription = ''
      Repository automation, running the coding agents you know and
      love, with strong guardrails in GitHub Actions.
    '';

    homepage = "https://github.com/github/gh-aw";
    changelog = "https://github.com/github/gh-aw/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ MH0386 ];
    mainProgram = "gh-aw";
    downloadPage = "https://github.com/github/gh-aw/releases";
  };
})
