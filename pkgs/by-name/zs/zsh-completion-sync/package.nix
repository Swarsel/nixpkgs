{
  lib,
  fetchFromGitHub,
  gitUpdater,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "zsh-completion-sync";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "BronzeDeer";
    repo = "zsh-completion-sync";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-GMZ0W8d0Qd5EhrwA/SkeOqDzoUchxDermcTR0iKYP8M=";
  };

  strictDeps = true;

  installPhase = ''
    install -D zsh-completion-sync.plugin.zsh  $out/share/zsh-completion-sync/zsh-completion-sync.plugin.zsh
  '';

  dontBuild = true;
  dontConfigure = true;

  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
  };

  meta = {
    description = "Automatically loads completions added dynamically to FPATH or XDG_DATA_DIRS";
    homepage = "https://github.com/BronzeDeer/zsh-completion-sync";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      ambroisie
      BronzeDeer
    ];

    platforms = lib.platforms.unix;
  };
})
