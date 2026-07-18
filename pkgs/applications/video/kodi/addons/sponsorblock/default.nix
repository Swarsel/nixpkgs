{
  lib,
  fetchFromGitHub,
  buildKodiAddon,
  requests,
  six,
}:
buildKodiAddon rec {
  pname = "sponsorblock";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "siku2";
    repo = namespace;
    rev = "v${version}";
    hash = "sha256-9+0gIY12C+bZNsCRzla1IFmtVZiiGnS4TL3srkOBWsQ=";
  };

  propagatedBuildInputs = [
    six
    requests
  ];

  namespace = "script.service.sponsorblock";

  passthru = {
    pythonPath = "resources/lib";
  };

  meta = {
    description = "Port of SponsorBlock for Invidious and YouTube Plugin";
    homepage = "https://github.com/siku2/script.service.sponsorblock";
    license = lib.licenses.mit;
    teams = [ lib.teams.kodi ];
  };
}
