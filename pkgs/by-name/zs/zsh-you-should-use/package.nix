{
  lib,
  fetchFromGitHub,
  gitUpdater,
  ncurses,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "zsh-you-should-use";
  version = "1.11.1";

  src = fetchFromGitHub {
    owner = "MichaelAquilina";
    repo = "zsh-you-should-use";
    tag = finalAttrs.version;
    hash = "sha256-a/DNVxD55Bh6AmSh5C4z4JpZM5xUiQgoaFoDgYPQsbo=";
  };

  postPatch = ''
    substituteInPlace you-should-use.plugin.zsh \
      --replace-fail "tput" "${lib.getExe' ncurses "tput"}"
  '';

  strictDeps = true;

  installPhase = ''
    install -D you-should-use.plugin.zsh $out/share/zsh/plugins/you-should-use/you-should-use.plugin.zsh
  '';

  dontBuild = true;
  passthru.updateScript = gitUpdater { };

  meta = {
    description = "ZSH plugin that reminds you to use existing aliases for commands you just typed";
    homepage = "https://github.com/MichaelAquilina/zsh-you-should-use";
    changelog = "https://github.com/MichaelAquilina/zsh-you-should-use/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ tomodachi94 ];
  };
})
