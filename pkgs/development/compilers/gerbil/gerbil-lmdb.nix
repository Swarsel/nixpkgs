{
  lib,
  fetchFromGitHub,
  lmdb,
  pkgs,
  ...
}:

{
  pname = "gerbil-lmdb";
  version = "unstable-2023-09-23";
  nativeBuildInputs = [ pkgs.pkg-config ];
  buildInputs = [ lmdb ];
  gerbil-package = "clan";
  gerbilInputs = [ ];
  git-version = "6d64813";

  pre-src = {
    fun = fetchFromGitHub;
    owner = "mighty-gerbils";
    repo = "gerbil-lmdb";
    rev = "6d64813afe5766776a0d7ef45f80c784b820742c";
    sha256 = "12kywxx4qjxchmhcd66700r2yfqjnh12ijgqnpqaccvigi07iq9b";
  };

  softwareName = "Gerbil-LMDB";
  version-path = "";

  meta = {
    description = "LMDB bindings for Gerbil";
    homepage = "https://github.com/mighty-gerbils/gerbil-lmdb";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fare ];
    platforms = lib.platforms.unix;
  };
  # "-L${lmdb.out}/lib"
}
