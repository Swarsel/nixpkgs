{
  lib,
  fetchFromGitHub,
  gitUpdater,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "nerdfetch";
  version = "8.5.4";

  src = fetchFromGitHub {
    owner = "ThatOneCalculator";
    repo = "NerdFetch";
    tag = "v${finalAttrs.version}";
    hash = "sha256-tV8Ug7i/BTD+TxUCejwYdGLYauAYos18AnWQ1XgynWs=";
  };

  installPhase = ''
    mkdir -p $out/bin
      cp $src/nerdfetch $out/bin
  '';

  dontBuild = true;
  dontConfigure = true;
  dontUnpack = true;

  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
  };

  meta = {
    description = "POSIX *nix (Linux, macOS, Android, *BSD, etc) fetch script using Nerdfonts";
    homepage = "https://github.com/ThatOneCalculator/NerdFetch";
    changelog = "https://github.com/ThatOneCalculator/NerdFetch/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ByteSudoer ];
    platforms = lib.platforms.unix;
    mainProgram = "nerdfetch";
  };
})
