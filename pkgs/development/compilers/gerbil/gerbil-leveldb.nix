{
  lib,
  fetchFromGitHub,
  leveldb,
  pkgs,
  ...
}:

{
  pname = "gerbil-leveldb";
  version = "unstable-2023-09-23";
  nativeBuildInputs = [ pkgs.pkg-config ];
  buildInputs = [ leveldb ];
  gerbil-package = "clan";
  gerbilInputs = [ ];
  git-version = "c62e47f";

  pre-src = {
    fun = fetchFromGitHub;
    owner = "mighty-gerbils";
    repo = "gerbil-leveldb";
    rev = "c62e47f352377b6843fb3e4b27030762a510a0d8";
    sha256 = "177zn1smv2zq97mlryf8fi7v5gbjk07v5i0dix3r2wsanphaawvl";
  };

  softwareName = "Gerbil-LevelDB";
  version-path = "";

  meta = {
    description = "LevelDB bindings for Gerbil";
    homepage = "https://github.com/mighty-gerbils/gerbil-leveldb";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fare ];
    platforms = lib.platforms.unix;
  };
  # "-L${leveldb}/lib"
}
