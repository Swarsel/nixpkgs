{
  lib,
  stdenv,
  fetchFromGitHub,
  bison,
  boost,
  cmake,
  curl,
  cyrus_sasl,
  hash,
  libaio,
  libedit,
  libev,
  libevent,
  libgcrypt,
  libgpg-error,
  lz4,
  makeWrapper,
  ncurses,
  numactl,
  openssl,
  perlPackages,
  pkg-config,
  procps,
  protobuf,
  valgrind,
  version,
  xxd,
  zlib,
  extraPatches ? [ ],
  extraPostInstall ? "",
  fetchSubmodules ? false,
  ...
}:

stdenv.mkDerivation (finalAttrs: {
  inherit version;
  pname = "percona-xtrabackup";

  src = fetchFromGitHub {
    inherit hash fetchSubmodules;
    owner = "percona";
    repo = "percona-xtrabackup";
    rev = "percona-xtrabackup-${finalAttrs.version}";
  };

  patches = extraPatches;

  nativeBuildInputs = [
    bison
    boost
    cmake
    makeWrapper
    pkg-config
  ];

  buildInputs = [
    (curl.override { inherit openssl; })
    cyrus_sasl
    libaio
    libedit
    libevent
    libev
    libgcrypt
    libgpg-error
    lz4
    ncurses
    numactl
    openssl
    procps
    protobuf
    valgrind
    xxd
    zlib
  ]
  ++ (with perlPackages; [
    perl
    DBI
    DBDmysql
  ]);

  cmakeFlags = [
    "-DMYSQL_UNIX_ADDR=/run/mysqld/mysqld.sock"
    "-DBUILD_CONFIG=xtrabackup_release"
    "-DINSTALL_MYSQLTESTDIR=OFF"
    "-DWITH_BOOST=system"
    "-DWITH_CURL=system"
    "-DWITH_EDITLINE=system"
    "-DWITH_LIBEVENT=system"
    "-DWITH_LZ4=system"
    "-DWITH_PROTOBUF=system"
    "-DWITH_SASL=system"
    "-DWITH_SSL=system"
    "-DWITH_ZLIB=system"
    "-DWITH_VALGRIND=ON"
    "-DWITH_MAN_PAGES=OFF"
  ];

  postInstall = ''
    wrapProgram "$out"/bin/xtrabackup --prefix PERL5LIB : $PERL5LIB
    rm -r "$out"/lib/plugin/debug
  ''
  + extraPostInstall;

  passthru.mysqlVersion = lib.versions.majorMinor finalAttrs.version;

  meta = {
    description = "Non-blocking backup tool for MySQL";
    homepage = "http://www.percona.com/software/percona-xtrabackup";
    license = lib.licenses.gpl2Only;

    maintainers = [
      lib.maintainers.izorkin
      lib.maintainers.leona
      lib.maintainers.osnyx
    ];

    platforms = lib.platforms.linux;
  };
})
