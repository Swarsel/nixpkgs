{
  lib,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "go-graft";
  version = "0.2.19";

  src = fetchFromGitHub {
    owner = "mzz2017";
    repo = "gg";
    rev = "v${finalAttrs.version}";
    hash = "sha256-DXW0NtFYvcCX4CgMs5/5HPaO9f9eFtw401wmJdCbHPU=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-fnM4ycqDyruCdCA1Cr4Ki48xeQiTG4l5dLVuAafEm14=";
  env.CGO_ENABLED = 0;

  postInstall = ''
    installShellCompletion --cmd gg \
    --bash completion/bash/gg \
    --fish completion/fish/gg.fish \
    --zsh completion/zsh/_gg
  '';

  ldflags = [
    "-X github.com/mzz2017/gg/cmd.Version=${finalAttrs.version}"
    "-s"
    "-w"
  ];

  meta = {
    description = "Command-line tool for one-click proxy in your research and development without installing v2ray or anything else";
    homepage = "https://github.com/mzz2017/gg";
    changelog = "https://github.com/mzz2017/gg/releases/tag/${finalAttrs.src.rev}";
    license = lib.licenses.agpl3Only;

    maintainers = with lib.maintainers; [
      xyenon
      oluceps
    ];

    platforms = lib.platforms.linux;
    mainProgram = "gg";
  };
})
