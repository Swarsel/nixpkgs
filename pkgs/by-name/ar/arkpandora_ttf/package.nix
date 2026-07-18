{
  lib,
  fetchurl,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation rec {
  pname = "arkpandora";
  version = "2.04";

  src = fetchurl {
    hash = "sha256-ofyVPJjQD8w+8WgETF2UcJlfbSsKQgBsH3ob+yjvrpo=";

    urls = [
      "http://distcache.FreeBSD.org/ports-distfiles/ttf-arkpandora-${version}.tgz"
      "ftp://ftp.FreeBSD.org/pub/FreeBSD/ports/distfiles/ttf-arkpandora-${version}.tgz"
      "http://www.users.bigpond.net.au/gavindi/ttf-arkpandora-${version}.tgz"
    ];
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/fonts/truetype
    cp *.ttf $out/share/fonts/truetype

    runHook postInstall
  '';

  meta = {
    description = "Font, metrically identical to Arial and Times New Roman";
    license = lib.licenses.bitstreamVera;
  };
}
