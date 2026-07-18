{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  gitMinimal,
  installShellFiles,
  makeWrapper,
  tmux,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:

buildGoModule (finalAttrs: {
  pname = "gwq";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "d-kuro";
    repo = "gwq";
    tag = "v${finalAttrs.version}";
    hash = "sha256-MfCYFbODWnfPxx+6sLlcMT6tqghgILHB13+ccYqVjBA=";
  };

  nativeBuildInputs = [
    installShellFiles
    makeWrapper
  ];

  vendorHash = "sha256-4K01Xf1EXl/NVX1loQ76l1bW8QglBAQdvlZSo7J4NPI=";

  nativeCheckInputs = [
    writableTmpDirAsHomeHook
  ];

  postInstall = ''
    wrapProgram $out/bin/gwq \
      --prefix PATH : ${
        lib.makeBinPath [
          gitMinimal
          tmux
        ]
      }
  ''
  + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd gwq \
      --bash <($out/bin/gwq completion bash) \
      --fish <($out/bin/gwq completion fish) \
      --zsh <($out/bin/gwq completion zsh)
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  __structuredAttrs = true;

  ldflags = [
    "-s"
    "-w"
    "-X github.com/d-kuro/gwq/internal/cmd.version=v${finalAttrs.version}"
  ];

  subPackages = [ "cmd/gwq" ];

  meta = {
    description = "Git worktree manager with fuzzy finder interface";
    homepage = "https://github.com/d-kuro/gwq";
    changelog = "https://github.com/d-kuro/gwq/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ojii3 ];
    platforms = lib.platforms.unix;
    mainProgram = "gwq";
  };
})
