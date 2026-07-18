{
  lib,
  stdenv,
  fetchgit,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ramfetch";
  version = "1.1.0a";

  src = fetchgit {
    url = "https://codeberg.org/jahway603/ramfetch.git";
    rev = finalAttrs.version;
    hash = "sha256-sUreZ6zm+a1N77OZszjnpS4mmo5wL1dhNGVldJCGoag=";
  };

  installPhase = ''
    runHook preInstall

    install -D ramfetch $out/bin/ramfetch

    runHook postInstall
  '';

  dontBuild = true;

  meta = {
    description = "Tool which displays memory information";
    homepage = "https://codeberg.org/jahway603/ramfetch";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.markbeep ];
    platforms = lib.platforms.linux;
    mainProgram = "ramfetch";
  };
})
