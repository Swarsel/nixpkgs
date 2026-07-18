{
  lib,
  fetchFromGitHub,
  buildKodiAddon,
  jurialmunkey,
}:

buildKodiAddon rec {
  pname = "texturemaker";
  version = "0.2.10";

  src = fetchFromGitHub {
    owner = "jurialmunkey";
    repo = namespace;
    rev = "v${version}";
    hash = "sha256-GtUDNc0qatGzgSqQdDJgZnrhI1f+SPyoG9Og+oRFxRM=";
  };

  propagatedBuildInputs = [
    jurialmunkey
  ];

  namespace = "script.texturemaker";

  meta = {
    description = "Texture Maker helps skinners build gradient based textures";
    homepage = "https://github.com/jurialmunkey/script.texturemaker/tree/main";
    license = lib.licenses.gpl3Plus;
    teams = [ lib.teams.kodi ];
  };
}
