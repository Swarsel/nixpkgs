{
  lib,
  fetchFromGitHub,
  addonUpdateScript,
  buildKodiAddon,
}:
buildKodiAddon rec {
  pname = "infotagger";
  version = "0.0.8";

  src = fetchFromGitHub {
    owner = "jurialmunkey";
    repo = namespace;
    rev = "v${version}";
    hash = "sha256-Ns1OjrYLKz4znXRxqUErDLcmC0HBjBFVYI9GFqDVurY=";
  };

  namespace = "script.module.infotagger";

  passthru = {
    # Unusual Python path.
    pythonPath = "resources/modules";

    updateScript = addonUpdateScript {
      attrPath = "kodi.packages.infotagger";
    };
  };

  meta = {
    description = "Wrapper for new Nexus InfoTagVideo ListItem methods to maintain backwards compatibility";
    homepage = "https://github.com/jurialmunkey/script.module.infotagger";
    license = lib.licenses.gpl3Plus;
    teams = [ lib.teams.kodi ];
  };
}
