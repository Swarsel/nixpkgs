{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  cxxtools,
  libmysqlclient,
  libpq,
  openssl,
  sqlite,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tntdb";
  version = "1.4";

  src = fetchFromGitHub {
    owner = "maekitalo";
    repo = "tntdb";
    rev = "V${finalAttrs.version}";
    hash = "sha256-ciqHv077sXnvCx+TJjdY1uPrlCP7/s972koXjGLgWhU=";
  };

  nativeBuildInputs = [
    autoreconfHook
    libpq.pg_config
  ];

  buildInputs = [
    cxxtools
    libpq
    libmysqlclient
    sqlite
    zlib
    openssl
  ];

  enableParallelBuilding = true;

  meta = {
    description = "C++ library which makes accessing SQL databases easy and robust";
    homepage = "http://www.tntnet.org/tntdb.html";
    license = lib.licenses.lgpl21;
    maintainers = [ lib.maintainers.juliendehos ];
    platforms = lib.platforms.linux;
  };
})
