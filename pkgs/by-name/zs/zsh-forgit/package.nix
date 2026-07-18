{
  lib,
  fetchFromGitHub,
  bash,
  coreutils,
  findutils,
  fzf,
  gawk,
  git,
  gnugrep,
  gnused,
  makeWrapper,
  perl,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "zsh-forgit";
  version = "26.07.0";

  src = fetchFromGitHub {
    owner = "wfxr";
    repo = "forgit";
    tag = finalAttrs.version;
    hash = "sha256-Ks/kUuQLtzKLjwIDpfkh6pL90aII8Rfh8ijxDmlFvmg=";
  };

  postPatch = ''
    substituteInPlace forgit.plugin.zsh \
      --replace-fail "\$FORGIT_INSTALL_DIR/bin/git-forgit" "$out/bin/git-forgit"
  '';

  strictDeps = true;
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    install -D bin/git-forgit $out/bin/git-forgit
    install -D completions/_git-forgit $out/share/zsh/site-functions/_git-forgit
    install -D forgit.plugin.zsh $out/share/zsh/zsh-forgit/forgit.plugin.zsh
    wrapProgram $out/bin/git-forgit \
      --prefix PATH : ${
        lib.makeBinPath [
          bash
          coreutils
          findutils
          fzf
          gawk
          git
          gnugrep
          gnused
          perl
        ]
      }

    runHook postInstall
  '';

  dontBuild = true;

  meta = {
    description = "Utility tool powered by fzf for using git interactively";
    homepage = "https://github.com/wfxr/forgit";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ deejayem ];
    platforms = lib.platforms.all;
    mainProgram = "git-forgit";
  };
})
