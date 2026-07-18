{
  lib,
  addonUpdateScript,
  buildKodiAddon,
  defusedxml,
  fetchzip,
  kodi-six,
  rel,
}:

buildKodiAddon rec {
  pname = "keymap";
  version = "1.4.0";

  src = fetchzip {
    url = "https://mirrors.kodi.tv/addons/${lib.toLower rel}/${namespace}/${namespace}-${version}.zip";
    sha256 = "sha256-sbyI6ZK8HvXgMxNDtm2Tb/ub93IcdXB5PSdxoL+QIqU=";
  };

  propagatedBuildInputs = [
    defusedxml
    kodi-six
  ];

  namespace = "script.keymap";

  passthru = {
    updateScript = addonUpdateScript {
      attrPath = "kodi.packages.keymap";
    };
  };

  meta = {
    description = "GUI for configuring mappings for remotes, keyboard and other inputs supported by Kodi";
    homepage = "https://github.com/tamland/xbmc-keymap-editor";
    license = lib.licenses.gpl3Plus;
    teams = [ lib.teams.kodi ];
  };
}
