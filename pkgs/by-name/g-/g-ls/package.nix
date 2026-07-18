{
  lib,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "g-ls";
  version = "0.31.2";

  src = fetchFromGitHub {
    owner = "Equationzhao";
    repo = "g";
    tag = "v${finalAttrs.version}";
    hash = "sha256-krir/F+USTbVRFwC7d2rA5d4EcOG+2CNpwSqCUJP5fU=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-j1zsulX1wySlWivVU9ajJFmx8Ww2/sxVMV41fUJa1DU=";

  postInstall = ''
    installShellCompletion \
      --bash completions/bash/g-completion.bash \
      --zsh completions/zsh/_g \
      --fish completions/fish/g.fish
  '';

  ldflags = [
    "-s"
    "-w"
  ];

  subPackages = [ "." ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Powerful ls alternative written in Go";
    homepage = "https://github.com/Equationzhao/g";
    changelog = "https://github.com/Equationzhao/g/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ Ruixi-rebirth ];
    mainProgram = "g";
  };
})
