{
  lib,
  fetchFromGitHub,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "agkozak-zsh-prompt";
  version = "3.11.5";

  src = fetchFromGitHub {
    owner = "agkozak";
    repo = "agkozak-zsh-prompt";
    tag = "v${finalAttrs.version}";
    hash = "sha256-C9lyOm2+RVLOUSO5Vz013uTobnN+SBE1Jm8GuJZ7T7U=";
  };

  strictDeps = true;

  installPhase = ''
    plugindir="$out/share/zsh/site-functions"

    mkdir -p "$plugindir"
    cp -r -- lib/*.zsh agkozak-zsh-prompt.plugin.zsh prompt_agkozak-zsh-prompt_setup "$plugindir"/
  '';

  dontBuild = true;
  dontConfigure = true;

  meta = {
    description = "Fast, asynchronous Zsh prompt";
    homepage = "https://github.com/agkozak/agkozak-zsh-prompt";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ambroisie ];
    platforms = lib.platforms.all;
  };
})
