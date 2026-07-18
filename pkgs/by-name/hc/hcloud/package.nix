{
  lib,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "hcloud";
  version = "1.66.0";

  src = fetchFromGitHub {
    owner = "hetznercloud";
    repo = "cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Ixx92yY0dC8g8YPQtqYUCMA5k2W9IAwRreSzwg73/04=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-f960IUoBBxOEIdFTuJG6J5CKFdcSrZBrKDrMk28RzM4=";

  postInstall = ''
    for shell in bash fish zsh; do
      $out/bin/hcloud completion $shell > hcloud.$shell
      installShellCompletion hcloud.$shell
    done
  '';

  ldflags = [
    "-s"
    "-w"
    "-X=github.com/hetznercloud/cli/internal/version.Version=${finalAttrs.version}"
  ];

  subPackages = [ "cmd/hcloud" ];

  meta = {
    description = "Command-line interface for Hetzner Cloud, a provider for cloud virtual private servers";
    homepage = "https://github.com/hetznercloud/cli";
    changelog = "https://github.com/hetznercloud/cli/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      zauberpony
      techknowlogick
    ];

    mainProgram = "hcloud";
  };
})
