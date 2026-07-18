{
  lib,
  stdenv,
  fetchurl,
  glib,
  libidn,
  openssl,
  pkg-config,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "loudmouth";
  version = "1.5.4";

  src = fetchurl {
    url = "https://mcabber.com/files/loudmouth/loudmouth-${finalAttrs.version}.tar.bz2";
    hash = "sha256-McvJHB/dzFNGszc7j7RVlOnqnMf+NtBZXokSxHrZTQ0=";
  };

  nativeBuildInputs = [ pkg-config ];

  propagatedBuildInputs = [
    openssl
    libidn
    glib
    zlib
  ];

  configureFlags = [ "--with-ssl=openssl" ];
  env.NIX_CFLAGS_COMPILE = "-Wno-error=deprecated-declarations";

  meta = {
    description = "Lightweight C library for the Jabber protocol";
    changelog = "https://mcabber.com/";
    license = lib.licenses.lgpl21;
    platforms = lib.platforms.all;
    downloadPage = "http://mcabber.com/files/loudmouth/";
  };
})
