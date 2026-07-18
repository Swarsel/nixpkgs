{
  lib,
  fetchFromGitHub,
  buildKodiBinaryAddon,
  bzip2,
  libarchive,
  lz4,
  lzo,
  openssl,
  rel,
  xz,
  zlib,
}:
buildKodiBinaryAddon rec {
  pname = namespace;
  version = "20.1.0";

  src = fetchFromGitHub {
    owner = "xbmc";
    repo = namespace;
    rev = "${version}-${rel}";
    sha256 = "sha256-D0eLH+G+qF5xLBBX/FdJC+gKNQpqSb7LjRmi/99rPNg=";
  };

  extraBuildInputs = [
    libarchive
    xz
    bzip2
    zlib
    lz4
    lzo
    openssl
  ];

  namespace = "vfs.libarchive";

  meta = {
    description = "LibArchive Virtual Filesystem add-on for Kodi";
    homepage = "https://github.com/xbmc/vfs.libarchive";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.all;
    teams = [ lib.teams.kodi ];
  };
}
