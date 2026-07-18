{
  lib,
  libjail,
  libmemstat,
  libnetgraph,
  libutil,
  libxo,
  mkDerivation,
}:
mkDerivation {
  buildInputs = [
    libxo
    libutil
    libmemstat
    libjail
    libnetgraph
  ];

  path = "usr.bin/netstat";
  meta.mainProgram = "netstat";
  meta.platforms = lib.platforms.freebsd;
}
