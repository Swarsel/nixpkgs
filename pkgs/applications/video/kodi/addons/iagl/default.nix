{
  lib,
  fetchFromGitHub,
  archive_tool,
  buildKodiAddon,
  dateutil,
  infotagger,
  requests,
  routing,
  vfs-libarchive,
  youtube,
}:

buildKodiAddon rec {
  pname = "iagl";
  version = "3.0.9";

  src = fetchFromGitHub {
    owner = "zach-morris";
    repo = "plugin.program.iagl";
    rev = version;
    sha256 = "sha256-b8nO3D/xTnj/5UDshGlIJdiHd75VhIlkrGUi0vkZqG4=";
  };

  propagatedBuildInputs = [
    dateutil
    requests
    routing
    vfs-libarchive
    archive_tool
    youtube
    infotagger
  ];

  namespace = "plugin.program.iagl";

  meta = {
    description = "Launch Games from the Internet using Kodi";
    homepage = "https://github.com/zach-morris/plugin.program.iagl";
    license = lib.licenses.gpl3Plus;
    teams = [ lib.teams.kodi ];
  };
}
