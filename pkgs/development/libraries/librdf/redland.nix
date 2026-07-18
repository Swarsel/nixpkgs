{
  lib,
  stdenv,
  fetchurl,
  curl,
  db,
  gmp,
  libmysqlclient,
  libpq,
  librdf_rasqal,
  libxml2,
  libxslt,
  openssl,
  perl,
  pkg-config,
  sqlite,
  withBdb ? false,
  withMysql ? false,
  withPostgresql ? false,
  withSqlite ? true,
}:

stdenv.mkDerivation rec {
  pname = "redland";
  version = "1.0.17";

  src = fetchurl {
    url = "https://download.librdf.org/source/redland-${version}.tar.gz";
    sha256 = "de1847f7b59021c16bdc72abb4d8e2d9187cd6124d69156f3326dd34ee043681";
  };

  nativeBuildInputs = [
    perl
    pkg-config
  ]
  ++ lib.optional withPostgresql libpq.pg_config;

  buildInputs = [
    openssl
    libxslt
    curl
    libxml2
    gmp
  ]
  ++ lib.optional withMysql libmysqlclient
  ++ lib.optional withSqlite sqlite
  ++ lib.optional withPostgresql libpq
  ++ lib.optional withBdb db;

  propagatedBuildInputs = [ librdf_rasqal ];

  configureFlags = [
    "--with-threads"
  ]
  ++ lib.optionals withBdb [
    "--with-bdb-include=${db.dev}/include"
    "--with-bdb-lib=${db.out}/lib"
  ];

  # Fix broken DT_NEEDED in lib/redland/librdf_storage_sqlite.so.
  env.NIX_CFLAGS_LINK = "-lraptor2";
  doCheck = false; # fails 1 out of 17 tests with a segmentation fault
  postInstall = "rm -rvf $out/share/gtk-doc";

  meta = {
    description = "C libraries that provide support for the Resource Description Framework (RDF)";
    homepage = "https://librdf.org/";
    license = lib.licenses.asl20;
    platforms = lib.platforms.unix;
  };
}
