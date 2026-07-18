{
  lib,
  stdenv,
  fetchurl,
  libiconv,
  openssl,
  pam,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ngircd";
  version = "27";

  src = fetchurl {
    url = "https://ngircd.barton.de/pub/ngircd/ngircd-${finalAttrs.version}.tar.xz";
    sha256 = "sha256-aJeIAxndXi5zwckBlhNQn4jrW42qWCGjb7yj14XCR7g=";
  };

  buildInputs = [
    zlib
    pam
    openssl
    libiconv
  ];

  configureFlags = [
    "--with-syslog"
    "--with-zlib"
    "--with-pam"
    "--with-openssl"
    "--enable-ipv6"
    "--with-iconv"
  ];

  meta = {
    description = "Next Generation IRC Daemon";
    homepage = "https://ngircd.barton.de";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.all;
    mainProgram = "ngircd";
  };
})
