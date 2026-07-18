{
  lib,
  fetchFromGitHub,
  buildGoModule,
  gh-markdown-preview,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "gh-markdown-preview";
  version = "1.11.1";

  src = fetchFromGitHub {
    owner = "yusukebe";
    repo = "gh-markdown-preview";
    rev = "v${finalAttrs.version}";
    hash = "sha256-CD3ZasrkAijC1msOSBJZAfIfrGKKHPIom57t+wmFdMY=";
  };

  vendorHash = "sha256-O6Q9h5zcYAoKLjuzGu7f7UZY0Y5rL2INqFyJT2QZJ/E=";
  # Tests need network
  doCheck = false;

  ldflags = [
    "-s"
    "-w"
    "-X github.com/yusukebe/gh-markdown-preview/cmd.Version=${finalAttrs.version}"
  ];

  passthru.tests = {
    version = testers.testVersion { package = gh-markdown-preview; };
  };

  meta = {
    description = "gh extension to preview Markdown looking like on GitHub";
    homepage = "https://github.com/yusukebe/gh-markdown-preview";
    changelog = "https://github.com/yusukebe/gh-markdown-preview/releases/tag/${finalAttrs.src.rev}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ matthiasbeyer ];
    mainProgram = "gh-markdown-preview";
  };
})
