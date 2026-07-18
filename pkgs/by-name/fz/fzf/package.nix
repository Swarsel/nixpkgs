{
  lib,
  fetchFromGitHub,
  bc,
  buildGoModule,
  installShellFiles,
  ncurses,
  runtimeShell,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "fzf";
  version = "0.74.0";

  src = fetchFromGitHub {
    owner = "junegunn";
    repo = "fzf";
    tag = "v${finalAttrs.version}";
    hash = "sha256-fsD/usMUfnjxpn5R/Bv4xuP32excEDgtZDEvikjDCY8=";
  };

  outputs = [
    "out"
    "man"
  ];

  # The vim plugin expects a relative path to the binary; patch it to abspath.
  postPatch = ''
    sed -i -e "s|expand('<sfile>:h:h')|'$out'|" plugin/fzf.vim

    if ! grep -q $out plugin/fzf.vim; then
        echo "Failed to replace vim base_dir path with $out"
        exit 1
    fi

    # fzf-tmux depends on bc
    substituteInPlace bin/fzf-tmux \
      --replace-fail "bc" "${lib.getExe bc}"
  '';

  nativeBuildInputs = [ installShellFiles ];
  buildInputs = [ ncurses ];
  vendorHash = "sha256-MLuoKPEAqrpCbUphYOCpHdo8MdW5kvueeDU/3loK33Q=";
  env.CGO_ENABLED = 0;

  postInstall = ''
    install bin/fzf-tmux $out/bin

    installManPage man/man1/fzf.1 man/man1/fzf-tmux.1

    install -D plugin/* -t $out/share/vim-plugins/fzf/plugin
    mkdir -p $out/share/nvim
    ln -s $out/share/vim-plugins/fzf $out/share/nvim/site

    # Install shell integrations
    install -D shell/* -t $out/share/fzf/

    cat <<SCRIPT > $out/bin/fzf-share
    #!${runtimeShell}
    # Run this script to find the fzf shared folder where all the shell
    # integration scripts are living.
    echo $out/share/fzf
    SCRIPT
    chmod +x $out/bin/fzf-share
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version} -X main.revision=${finalAttrs.src.rev}"
  ];

  meta = {
    description = "Command-line fuzzy finder written in Go";
    homepage = "https://github.com/junegunn/fzf";
    changelog = "https://github.com/junegunn/fzf/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      ma27
      zowoq
    ];

    platforms = lib.platforms.unix;
    mainProgram = "fzf";
  };
})
