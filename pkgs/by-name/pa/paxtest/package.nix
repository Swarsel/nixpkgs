{
  lib,
  stdenv,
  fetchurl,
  paxctl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "paxtest";
  version = "0.9.15";

  src = fetchurl {
    url = "https://www.grsecurity.net/~spender/paxtest-${finalAttrs.version}.tar.gz";
    sha256 = "0zv6vlaszlik98gj9200sv0irvfzrvjn46rnr2v2m37x66288lym";
  };

  makeFlags = [
    "PAXBIN=${paxctl}/bin/paxctl"
    "BINDIR=$(out)/bin"
    "RUNDIR=$(out)/lib/paxtest"
  ];

  enableParallelBuilding = true;
  installFlags = [ "DESTDIR=\"\"" ];
  makefile = "Makefile.psm";

  meta = {
    description = "Test various memory protection measures";
    license = lib.licenses.gpl2Only;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "paxtest";
  };
})
