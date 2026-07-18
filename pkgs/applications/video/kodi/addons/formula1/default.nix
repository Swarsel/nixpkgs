{
  lib,
  addonUpdateScript,
  buildKodiAddon,
  fetchzip,
  rel,
  requests,
}:

buildKodiAddon rec {
  pname = "formula1";
  version = "2.0.7";

  src = fetchzip {
    url = "https://mirrors.kodi.tv/addons/${lib.toLower rel}/${namespace}/${namespace}-${version}.zip";
    sha256 = "sha256-yz9SB0hiw5JKURGNvAazxazL+bMtfziNXlOLLoGUPOU=";
  };

  propagatedBuildInputs = [
    requests
  ];

  namespace = "plugin.video.formula1";

  passthru = {
    updateScript = addonUpdateScript {
      attrPath = "kodi.packages.formula1";
    };
  };

  meta = {
    description = "Videos from the Formula 1 website";
    homepage = "https://github.com/jaylinski/kodi-addon-formula1";
    license = lib.licenses.mit;
    teams = [ lib.teams.kodi ];
  };
}
