{
  lib,
  stdenv,
  fetchFromGitHub,
  fzf,
  git,
  installShellFiles,
  jq,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "git-worktree-switcher";
  version = "0.2.8";

  src = fetchFromGitHub {
    owner = "mateusauler";
    repo = "git-worktree-switcher";
    tag = "${finalAttrs.version}-fork";
    hash = "sha256-OXUVIL4bIqqxnLLwdO0+8gxCDMqA4TPvjIc2i8BeBmw=";
  };

  patches = [
    ./disable-update.patch # Disable update and auto update functionality
  ];

  nativeBuildInputs = [
    makeWrapper
    installShellFiles
  ];

  buildInputs = [
    fzf
    git
    jq
  ];

  installPhase = ''
    mkdir -p $out/bin

    cp wt $out/bin
    wrapProgram $out/bin/wt --prefix PATH : ${
      lib.makeBinPath [
        fzf
        git
        jq
      ]
    }

    installShellCompletion --zsh completions/_wt_completion
    installShellCompletion --bash completions/wt_completion
    installShellCompletion --fish completions/wt.fish
  '';

  meta = {
    description = "Switch between git worktrees with speed";
    homepage = "https://github.com/mateusauler/git-worktree-switcher";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      jiriks74
      mateusauler
    ];

    platforms = lib.platforms.all;
    mainProgram = "wt";
  };
})
