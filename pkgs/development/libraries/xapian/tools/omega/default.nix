{
  lib,
  stdenv,
  fetchurl,
  libmagic,
  pcre2,
  perl,
  pkg-config,
  xapian,
  zlib,
}:

stdenv.mkDerivation rec {
  inherit (xapian) version;
  pname = "xapian-omega";

  src = fetchurl {
    url = "https://oligarchy.co.uk/xapian/${version}/xapian-omega-${version}.tar.xz";
    hash = "sha256-p9+2CN2LPqU93oUjbUdXloJgacTRJhieozp5M0myMXo=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    xapian
    perl
    pcre2
    zlib
    libmagic
  ];

  postInstall = ''
    mkdir -p $out/share/omega
    cp -r templates $out/share/omega
  '';

  meta = {
    description = "Indexer and CGI search front-end built on Xapian library";
    homepage = "https://xapian.org/";
    changelog = "https://xapian.org/docs/xapian-omega-${version}/NEWS";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
  };
}
