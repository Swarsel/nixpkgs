{
  lib,
  fetchFromGitHub,
  buildKodiAddon,
  myconnpy,
}:

buildKodiAddon rec {
  pname = "mediathekview";
  version = "1.0.9";

  src = fetchFromGitHub {
    owner = pname;
    repo = namespace;
    rev = "release-${version}";
    hash = "sha256-XYyocXFTiYO7Ar0TtxjpCAy2Ywtnwb8BTxdKxwDWm4Y=";
  };

  propagatedBuildInputs = [
    myconnpy
  ];

  namespace = "plugin.video.mediathekview";

  meta = {
    description = "Access media libraries of German speaking broadcasting stations";
    homepage = "https://github.com/mediathekview/plugin.video.mediathekview";
    license = lib.licenses.mit;
    teams = [ lib.teams.kodi ];
  };
}
