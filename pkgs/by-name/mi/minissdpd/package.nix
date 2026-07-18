{
  lib,
  stdenv,
  fetchurl,
  libnfnetlink,
}:

stdenv.mkDerivation rec {
  pname = "minissdpd";
  version = "1.6.0";

  src = fetchurl {
    url = "http://miniupnp.free.fr/files/download.php?file=${pname}-${version}.tar.gz";
    sha256 = "sha256-9MLepqRy4KXMncotxMH8NrpVOOrPjXk4JSkyUXJVRr0=";
    name = "${pname}-${version}.tar.gz";
  };

  patches = [
    ./makefile-install-dir.patch
  ];

  buildInputs = [ libnfnetlink ];
  doCheck = true;
  enableParallelBuilding = true;

  installFlags = [
    "PREFIX=$(out)"
    "INSTALLPREFIX=$(out)"
  ];

  meta = {
    description = "Small daemon to speed up UPnP device discoveries";

    longDescription = ''
      MiniSSDPd receives NOTIFY packets and stores (caches) that information
      for later use by UPnP Control Points on the machine. MiniSSDPd receives
      M-SEARCH packets and answers on behalf of the UPnP devices running on
      the machine. Software must be patched in order to take advantage of
      MiniSSDPd, and MiniSSDPd must be started before any other UPnP program.
    '';

    homepage = "http://miniupnp.free.fr/minissdpd.html";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux;
    mainProgram = "minissdpd";
    downloadPage = "http://miniupnp.free.fr/files/";
  };
}
