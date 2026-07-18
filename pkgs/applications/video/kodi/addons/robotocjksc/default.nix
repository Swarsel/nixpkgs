{
  lib,
  fetchFromGitHub,
  buildKodiAddon,
}:

buildKodiAddon rec {
  pname = "robotocjksc";
  version = "0.0.3";

  src = fetchFromGitHub {
    owner = "jurialmunkey";
    repo = namespace;
    rev = "v${version}";
    hash = "sha256-s/h/KKlGYGMvf7RdI9ONk4S+NCzlaDX5w3CdNfbC2KE=";
  };

  namespace = "resource.font.robotocjksc";

  meta = {
    description = "Roboto CJKSC fonts";
    homepage = "https://github.com/jurialmunkey/resource.font.robotocjksc";
    license = lib.licenses.asl20;
    teams = [ lib.teams.kodi ];
  };
}
