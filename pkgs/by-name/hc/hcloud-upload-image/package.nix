{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:

buildGoModule rec {
  pname = "hcloud-upload-image";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "apricote";
    repo = "hcloud-upload-image";
    tag = "v${version}";
    hash = "sha256-l2LFx1f7X4t8yELWqryJgLW8Mr5Wey9AbI2wCpA2GJ0=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-hKsyweWmLZ0zH8VRX//YWYszbdmwrH5LCHn/SKeDbuk=";
  env.GOWORK = "off";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    for shell in bash fish zsh; do
      $out/bin/hcloud-upload-image completion $shell > hcloud.$shell
      installShellCompletion hcloud.$shell
    done
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
  ];

  subPackages = [ "." ];

  meta = {
    description = "Quickly upload any raw disk images into your Hetzner Cloud projects";
    homepage = "https://github.com/apricote/hcloud-upload-image";
    changelog = "https://github.com/apricote/hcloud-upload-image/releases/tag/v${version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      sshine
    ];

    mainProgram = "hcloud-upload-image";
  };
}
