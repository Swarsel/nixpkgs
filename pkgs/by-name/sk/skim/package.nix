{
  lib,
  fetchFromGitHub,
  hexdump,
  installShellFiles,
  nix-update-script,
  runtimeShell,
  rustPlatform,
  tmux,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "skim";
  version = "5.1.0";

  src = fetchFromGitHub {
    owner = "skim-rs";
    repo = "skim";
    tag = "v${finalAttrs.version}";
    hash = "sha256-AB/73sU02/DHV/bnQXpBqmzmGy+roXyIWd4BnN6GWGw=";
  };

  outputs = [
    "out"
    "man"
    "vim"
  ];

  postPatch = ''
    substituteInPlace plugin/skim.vim \
      --replace-fail "expand('<sfile>:h:h')" "'$out'"
  '';

  nativeBuildInputs = [ installShellFiles ];
  cargoHash = "sha256-tPNAwaefZrwhH7AoQnAkQYQUfKOKWMehHHeoUf7i4yE=";

  postBuild = ''
    cat <<SCRIPT > sk-share
    #! ${runtimeShell}
    # Run this script to find the skim shared folder where all the shell
    # integration scripts are living.
    echo $out/share/skim
    SCRIPT
  '';

  nativeCheckInputs = [
    tmux
    hexdump
  ];

  checkPhase = ''
    cargo nextest run --release --offline --lib --bins --examples --tests
  '';

  postInstall = ''
    installBin bin/sk-tmux
    install -D -m 444 plugin/skim.vim -t $vim/plugin
    install -D -m 444 shell/* -t $out/share/skim

    installBin sk-share
    installManPage $(find man -type f)
    installShellCompletion \
      --cmd sk \
      --bash shell/completion.bash \
      --fish shell/completion.fish \
      --zsh shell/completion.zsh
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  __darwinAllowLocalNetworking = true;
  __structuredAttrs = true;
  useNextest = true;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Command-line fuzzy finder written in Rust";
    homepage = "https://github.com/skim-rs/skim";
    changelog = "https://github.com/skim-rs/skim/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      dywedir
      getchoo
      krovuxdev
    ];

    mainProgram = "sk";
  };
})
