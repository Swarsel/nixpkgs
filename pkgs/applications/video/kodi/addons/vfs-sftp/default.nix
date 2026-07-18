{
  lib,
  fetchFromGitHub,
  buildKodiBinaryAddon,
  libssh,
  openssl,
  rel,
  zlib,
}:
buildKodiBinaryAddon rec {
  pname = namespace;
  version = "21.0.2";

  src = fetchFromGitHub {
    owner = "xbmc";
    repo = namespace;
    rev = "${version}-${rel}";
    sha256 = "sha256-aD0AEr406urgnGVfB6C9JGaNmZAFL7WghnTZhbMfzA8=";
  };

  extraBuildInputs = [
    openssl
    libssh
    zlib
  ];

  namespace = "vfs.sftp";

  meta = {
    description = "SFTP Virtual Filesystem add-on for Kodi";
    homepage = "https://github.com/xbmc/vfs.sftp";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.all;
    teams = [ lib.teams.kodi ];
  };
}
