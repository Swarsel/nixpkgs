{
  lib,
  stdenv,
  fetchurl,
  notmuch,
  openssl,
  pkg-config,
  sqlite,
  xapian,
  zlib,
}:
stdenv.mkDerivation rec {
  pname = "muchsync";
  version = "7";

  src = fetchurl {
    url = "https://www.muchsync.org/src/${pname}-${version}.tar.gz";
    hash = "sha256-+D4vb80O9IE0df3cjTkoVoZlTaX0FWWh6ams14Gjvqw=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    notmuch
    openssl
    sqlite
    xapian
    zlib
  ];

  env.XAPIAN_CONFIG = "${xapian}/bin/xapian-config";

  passthru = {
    inherit version;
  };

  meta = {
    description = "Synchronize maildirs and notmuch databases";
    homepage = "http://www.muchsync.org/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "muchsync";
  };
}
