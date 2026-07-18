{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  fetchpatch,
  gnutls,
  jansson,
  libcdada,
  libmysqlclient,
  libnetfilter_log,
  libpcap,
  libpq,
  libtool,
  numactl,
  pkg-config,
  rdkafka,
  sqlite,
  testers,
  zlib,
  gnutlsSupport ? false,
  withJansson ? true,
  # Optional Dependencies
  withKafka ? true,
  withMysql ? true,
  withNflog ? true,
  withPgSQL ? true,
  withSQLite ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pmacct";
  version = "1.7.9";

  src = fetchFromGitHub {
    owner = "pmacct";
    repo = "pmacct";
    rev = "v${finalAttrs.version}";
    hash = "sha256-3gV6GUhTQnH09NRIJQI0xBn05Bgo3AJsE2cSxNPXITo=";
  };

  patches = [
    # Fixes GCC15 compatability
    # Can be removed with the next release
    # Custom version of https://github.com/pmacct/pmacct/commit/6466578967d3d39c46f7ec10b308bca36568697d.patch
    # without the copyright date changes.
    ./gcc15-compat.patch
  ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    libtool
  ];

  buildInputs = [
    libcdada
    libpcap
  ]
  ++ lib.optional withKafka rdkafka
  ++ lib.optional withJansson jansson
  ++ lib.optional withNflog libnetfilter_log
  ++ lib.optional withSQLite sqlite
  ++ lib.optional withPgSQL libpq
  ++ lib.optionals withMysql [
    libmysqlclient
    zlib
    numactl
  ]
  ++ lib.optional gnutlsSupport gnutls;

  configureFlags = [
    "--with-pcap-includes=${libpcap}/include"
  ]
  ++ lib.optional withKafka "--enable-kafka"
  ++ lib.optional withJansson "--enable-jansson"
  ++ lib.optional withNflog "--enable-nflog"
  ++ lib.optional withSQLite "--enable-sqlite3"
  ++ lib.optional withPgSQL "--enable-pgsql"
  ++ lib.optional withMysql "--enable-mysql"
  ++ lib.optional gnutlsSupport "--enable-gnutls";

  env.MYSQL_CONFIG = lib.optionalString withMysql "${lib.getDev libmysqlclient}/bin/mysql_config";

  passthru.tests = {
    version = testers.testVersion {
      command = "pmacct -V";
      package = finalAttrs.finalPackage;
    };
  };

  meta = {
    description = "Small set of multi-purpose passive network monitoring tools";

    longDescription = ''
      pmacct is a small set of multi-purpose passive network monitoring tools
      [NetFlow IPFIX sFlow libpcap BGP BMP RPKI IGP Streaming Telemetry]
    '';

    homepage = "http://www.pmacct.net/";
    changelog = "https://github.com/pmacct/pmacct/blob/v${finalAttrs.version}/ChangeLog";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ _0x4A6F ];
    platforms = lib.platforms.unix;
  };
})
