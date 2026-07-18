{
  lib,
  fetchFromGitHub,
  biliass,
  buildLua,
  nix-update-script,
}:

buildLua {
  pname = "bdanmaku";
  version = "0-unstable-2025-01-15";

  src = fetchFromGitHub {
    owner = "UlyssesZh";
    repo = "bdanmaku";
    rev = "c9f2dca413a7148a662f006b8c524ccbd7a1945b";
    hash = "sha256-XbkKXZoC+Rqn0gSyyw8sn2VJO73MlatOS0lm2tcwcfY=";
  };

  scriptPath = "bdanmaku.lua";

  passthru.extraWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [ biliass ])
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Mpv plugin to correctly display Bilibili danmaku, powered by biliass";
    homepage = "https://github.com/UlyssesZh/bdanmaku";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ulysseszhan ];
  };
}
