{
  lib,
  fetchFromGitHub,
  buildKodiAddon,
}:
buildKodiAddon rec {
  pname = "pdfreader";
  version = "2.0.3";

  src = fetchFromGitHub {
    owner = "i96751414";
    repo = "plugin.image.pdfreader";
    rev = "v${version}";
    sha256 = "sha256-J93poR5VO9fAgNCEGftJVYnpXOsJSxnhHI6TAJZ2LeI=";
  };

  namespace = "plugin.image.pdf";
  passthru.pythonPath = "lib/api";

  meta = {
    description = "Comic book reader";
    homepage = "https://forum.kodi.tv/showthread.php?tid=187421";
    license = lib.licenses.gpl2Plus;
    teams = [ lib.teams.kodi ];
  };
}
