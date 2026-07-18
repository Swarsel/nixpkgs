{
  lib,
  stdenv,
  fetchurl,
  bzip2,
  glib,
  gnutls,
  libmaxminddb,
  ncurses,
  perl,
  pkg-config,
  sqlite,
  versionCheckHook,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ncdc";
  version = "1.25";

  src = fetchurl {
    url = "https://dev.yorhel.nl/download/ncdc-${finalAttrs.version}.tar.gz";
    # Hashes listed at https://dev.yorhel.nl/download
    sha256 = "b9be58e7dbe677f2ac1c472f6e76fad618a65e2f8bf1c7b9d3d97bc169feb740";
  };

  nativeBuildInputs = [
    perl
    pkg-config
    versionCheckHook
  ];

  buildInputs = [
    ncurses
    zlib
    bzip2
    sqlite
    glib
    gnutls
    libmaxminddb
  ];

  configureFlags = [ "--with-geoip" ];
  doInstallCheck = true;

  meta = {
    description = "Modern and lightweight direct connect client with a friendly ncurses interface";
    homepage = "https://dev.yorhel.nl/ncdc";
    changelog = "https://dev.yorhel.nl/ncdc/changes";
    license = lib.licenses.mit;
    mainProgram = "ncdc";
  };
})
