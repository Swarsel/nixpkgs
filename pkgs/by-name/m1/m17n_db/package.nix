{
  lib,
  stdenv,
  fetchurl,
  bash,
  gawk,
  gettext,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "m17n-db";
  version = "1.8.10";

  src = fetchurl {
    url = "mirror://savannah/m17n/m17n-db-${finalAttrs.version}.tar.gz";
    hash = "sha256-MQJOBRNTNEi5sx6jKU01pkJuZpDrRGKGgHMaqVXAwWw=";
  };

  strictDeps = true;
  nativeBuildInputs = [ gettext ];

  buildInputs = [
    gettext
    gawk
    bash
  ];

  configureFlags = [ "--with-charmaps=${stdenv.cc.libc}/share/i18n/charmaps" ];

  meta = {
    description = "Multilingual text processing library (database)";
    homepage = "https://www.nongnu.org/m17n/";

    changelog = "https://git.savannah.nongnu.org/cgit/m17n/m17n-db.git/plain/NEWS?h=REL-${
      lib.replaceStrings [ "." ] [ "-" ] finalAttrs.version
    }";

    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.linux;
    mainProgram = "m17n-db";
  };
})
