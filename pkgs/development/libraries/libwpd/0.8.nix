{
  lib,
  stdenv,
  fetchurl,
  bzip2,
  glib,
  libgsf,
  libxml2,
  pkg-config,
}:

stdenv.mkDerivation rec {
  pname = "libwpd";
  version = "0.8.14";

  src = fetchurl {
    url = "mirror://sourceforge/libwpd/libwpd-${version}.tar.gz";
    sha256 = "1syli6i5ma10cwzpa61a18pyjmianjwsf6pvmvzsh5md6yk4yx01";
  };

  patches = [ ./gcc-0.8.patch ];

  nativeBuildInputs = [
    pkg-config
    bzip2
  ];

  buildInputs = [
    glib
    libgsf
    libxml2
  ];

  meta = {
    description = "Library for importing WordPerfect documents";
    homepage = "https://libwpd.sourceforge.net";

    license = with lib.licenses; [
      lgpl21
      mpl20
    ];

    platforms = lib.platforms.unix;
  };
}
