{
  lib,
  fetchFromGitHub,
  buildKodiBinaryAddon,
  rel,
  tinyxml,
}:
buildKodiBinaryAddon rec {
  pname = namespace;
  version = "20.1.0";

  src = fetchFromGitHub {
    owner = "xbmc";
    repo = namespace;
    rev = "${version}-${rel}";
    sha256 = "sha256-8IEYA2gNchCa7O9kzrCbO5DxYWJqPzQN3SJIr9zCWc8=";
  };

  extraBuildInputs = [ tinyxml ];
  namespace = "vfs.rar";

  meta = {
    description = "RAR archive Virtual Filesystem add-on for Kodi";
    homepage = "https://github.com/xbmc/vfs.rar";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.all;
    teams = [ lib.teams.kodi ];
  };
}
