{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  curl,
  docbook_xsl,
  expat,
  gnutls,
  gpgme,
  libgcrypt,
  libxml2,
  libxslt,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libdatovka";
  version = "0.7.2";

  src = fetchurl {
    url = "https://gitlab.nic.cz/datovka/libdatovka/-/archive/v${finalAttrs.version}/libdatovka-v${finalAttrs.version}.tar.gz";
    sha256 = "sha256-pct+COy7ibyNtwB8l/vDnEHBUEihlo5OaoXWXVRJBrQ=";
  };

  patches = [
    ./libdatovka-deprecated-fn-curl.patch
  ];

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
  ];

  buildInputs = [
    expat
    gpgme
    libgcrypt
    libxml2
    libxslt
    gnutls
    curl
    docbook_xsl
  ];

  configureFlags = [
    "--with-docbook-xsl-stylesheets=${docbook_xsl}/xml/xsl/docbook"
  ];

  meta = {
    description = "Client library for accessing SOAP services of Czech government-provided Databox infomation system";
    homepage = "https://gitlab.nic.cz/datovka/libdatovka";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.ovlach ];
    platforms = lib.platforms.linux;
  };
})
