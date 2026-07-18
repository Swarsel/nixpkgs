{
  lib,
  fetchFromGitHub,
  gitUpdater,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "uosc-danmaku";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "Tony15246";
    repo = "uosc_danmaku";
    tag = "v${finalAttrs.version}";
    hash = "sha256-r4HcrDh4iW8ErfClfX1gkEWp7lVKbLE88fpj3tjYBAI=";
  };

  installPhase = ''
    runHook preInstall

    install -Dm644 main.lua $out/share/mpv/scripts/uosc_danmaku/main.lua
    cp -r modules apis dicts $out/share/mpv/scripts/uosc_danmaku/

    runHook postInstall
  '';

  dontBuild = true;
  dontConfigure = true;

  passthru = {
    scriptName = "uosc_danmaku";
    updateScript = gitUpdater { };
  };

  meta = {
    description = "Load DanDanPlay danmaku in MPV player";
    homepage = "https://github.com/Tony15246/uosc_danmaku";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ puiyq ];
  };
})
