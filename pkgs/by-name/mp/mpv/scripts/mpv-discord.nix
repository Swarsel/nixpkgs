{
  lib,
  fetchFromGitHub,
  buildGoModule,
  buildLua,
}:
let
  version = "1.6.1";

  src = fetchFromGitHub {
    owner = "tnychn";
    repo = "mpv-discord";
    rev = "v${version}";
    hash = "sha256-P1UaXGboOiqrXapfLzJI6IT3esNtflkQkcNXt4Umukc=";
  };

  core = buildGoModule {
    inherit version;
    src = "${src}/mpv-discord";
    vendorHash = "sha256-xe1jyWFQUD+Z4qBAVQ0SBY0gdxmi5XG9t29n3f/WKDs=";
    name = "mpv-discord-core";
  };
in
buildLua {
  inherit version src;
  pname = "mpv-discord";

  postInstall = ''
    substituteInPlace $out/share/mpv/scripts/discord.lua \
      --replace-fail 'binary_path = ""' 'binary_path = "${core}/bin/mpv-discord"'
  '';

  scriptPath = "scripts/discord.lua";

  meta = {
    description = "Cross-platform Discord Rich Presence integration for mpv with no external dependencies";
    homepage = "https://github.com/tnychn/mpv-discord";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bddvlpr ];
    platforms = lib.platforms.all;
  };
}
