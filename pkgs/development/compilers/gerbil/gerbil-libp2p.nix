{ lib, fetchFromGitHub, ... }:

{
  pname = "gerbil-libp2p";
  version = "unstable-2022-02-03";
  buildInputs = [ ]; # Note: at *runtime*, this depends on go-libp2p-daemon running
  gerbil-package = "vyzo";
  git-version = "15b3246";

  pre-src = {
    fun = fetchFromGitHub;
    owner = "vyzo";
    repo = "gerbil-libp2p";
    rev = "15b32462e683d89ffce0ff15ad373d293ea0ee5d";
    sha256 = "059lydp7d6pjgrd4pdnqq2zffzlba62ch102f01rgzf9aps3c8lz";
  };

  softwareName = "Gerbil-libp2p";

  meta = {
    description = "Gerbil libp2p: use libp2p from Gerbil";
    homepage = "https://github.com/vyzo/gerbil-libp2p";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fare ];
    platforms = lib.platforms.unix;
  };
}
