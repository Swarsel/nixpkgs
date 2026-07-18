{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  m17n_db,
  pkg-config,
}:
stdenv.mkDerivation rec {
  pname = "m17n-lib";
  version = "1.8.6";

  src = fetchurl {
    url = "mirror://savannah/m17n/${pname}-${version}.tar.gz";
    hash = "sha256-cSn+O3rVAPiLivhgXvB7lsh6deyYamlf/8CkCfRKfIY=";
  };

  strictDeps = true;

  # reconf needed to successfully cross-compile
  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    # requires m17n-db tool at build time
    m17n_db
  ];

  enableParallelBuilding = true;

  meta = {
    description = "Multilingual text processing library (runtime)";
    homepage = "https://www.nongnu.org/m17n/";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.linux;
  };
}
