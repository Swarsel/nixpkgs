{
  lib,
  fetchFromGitHub,
  buildKodiAddon,
}:
buildKodiAddon rec {
  pname = "osmc-skin";
  version = "21.1.1";

  src = fetchFromGitHub {
    owner = "osmc";
    repo = namespace;
    tag = "v${version}-August-update";
    hash = "sha256-3BR6HfKefuyybDv9c/ZkkZMRDyWNZWpftulXyUAD9nY=";
  };

  namespace = "skin.osmc";

  meta = {
    description = "Default skin for OSMC";
    homepage = "https://github.com/osmc/skin.osmc";
    license = lib.licenses.cc-by-nc-sa-30;
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
}
