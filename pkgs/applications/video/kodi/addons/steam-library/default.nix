{
  lib,
  fetchFromGitHub,
  buildKodiAddon,
  requests,
  requests-cache,
  routing,
}:

buildKodiAddon rec {
  pname = "steam-library";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "aanderse";
    repo = namespace;
    rev = "v${version}";
    sha256 = "sha256-HwPNBqD+zS5sDNXtiGEmoc1RJ1SFCRzVOzUCjunMCnU=";
  };

  propagatedBuildInputs = [
    requests
    requests-cache
    routing
  ];

  namespace = "plugin.program.steam.library";

  meta = {
    description = "View your entire Steam library right from Kodi";
    homepage = "https://github.com/aanderse/plugin.program.steam.library";
    license = lib.licenses.gpl3Plus;
    teams = [ lib.teams.kodi ];
  };
}
