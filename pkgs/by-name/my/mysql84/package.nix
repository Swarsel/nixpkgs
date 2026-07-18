{
  lib,
  stdenv,
  fetchurl,
  bison,
  cctools,
  cmake,
  curl,
  darwin,
  icu,
  libedit,
  libevent,
  libfido2,
  libtirpc,
  lz4,
  ncurses,
  nixosTests,
  numactl,
  openssl,
  pkg-config,
  protobuf_21,
  re2,
  readline,
  rpcsvc-proto,
  zlib,
  zstd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mysql";
  version = "8.4.10";

  src = fetchurl {
    url = "https://dev.mysql.com/get/Downloads/MySQL-${lib.versions.majorMinor finalAttrs.version}/mysql-${finalAttrs.version}.tar.gz";
    hash = "sha256-1XpnMLrvFK4Rj39KbgKEW1tQkzdY32H7BuEE8nzMj5Y=";
  };

  outputs = [
    "out"
    "static"
  ];

  patches = [
    ./no-force-outline-atomics.patch # Do not force compilers to turn on -moutline-atomics switch
  ];

  ## NOTE: MySQL upstream frequently twiddles the invocations of libtool. When updating, you might proactively grep for libtool references.
  postPatch = ''
    substituteInPlace cmake/libutils.cmake --replace /usr/bin/libtool libtool
    substituteInPlace cmake/os/Darwin.cmake --replace /usr/bin/libtool libtool
  '';

  nativeBuildInputs = [
    bison
    cmake
    pkg-config
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [ rpcsvc-proto ];

  buildInputs = [
    (curl.override { inherit openssl; })
    icu
    libedit
    libevent
    lz4
    ncurses
    openssl
    protobuf_21
    re2
    readline
    zlib
    zstd
    libfido2
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    numactl
    libtirpc
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    cctools
    darwin.developer_cmds
    darwin.DarwinTools
  ];

  cmakeFlags = [
    "-DFORCE_UNSUPPORTED_COMPILER=1" # To configure on Darwin.
    "-DWITH_ROUTER=OFF" # It may be packaged separately.
    "-DWITH_SYSTEM_LIBS=ON"
    "-DWITH_UNIT_TESTS=OFF"
    "-DMYSQL_UNIX_ADDR=/run/mysqld/mysqld.sock"
    "-DMYSQL_DATADIR=/var/lib/mysql"
    "-DINSTALL_INFODIR=share/mysql/docs"
    "-DINSTALL_MANDIR=share/man"
    "-DINSTALL_PLUGINDIR=lib/mysql/plugin"
    "-DINSTALL_INCLUDEDIR=include/mysql"
    "-DINSTALL_DOCREADMEDIR=share/mysql"
    "-DINSTALL_SUPPORTFILESDIR=share/mysql"
    "-DINSTALL_MYSQLSHAREDIR=share/mysql"
    "-DINSTALL_MYSQLTESTDIR="
    "-DINSTALL_DOCDIR=share/mysql/docs"
    "-DINSTALL_SHAREDIR=share/mysql"
  ];

  postInstall = ''
    moveToOutput "lib/*.a" $static
    so=${stdenv.hostPlatform.extensions.sharedLibrary}
    ln -s libmysqlclient$so $out/lib/libmysqlclient_r$so
  '';

  passthru = {
    client = finalAttrs.finalPackage;
    connector-c = finalAttrs.finalPackage;
    mysqlVersion = lib.versions.majorMinor finalAttrs.version;
    server = finalAttrs.finalPackage;

    tests = {
      mysql =
        nixosTests.mysql."mysql${lib.versions.major finalAttrs.version}${lib.versions.minor finalAttrs.version}";

      mysql-root-can-be-kept-insecure =
        nixosTests.mysql-secure-root.can-be-insecure."mysql${lib.versions.major finalAttrs.version}${lib.versions.minor finalAttrs.version}";

      mysql-secure-root-by-default =
        nixosTests.mysql-secure-root.secure-by-default."mysql${lib.versions.major finalAttrs.version}${lib.versions.minor finalAttrs.version}";
    };
  };

  meta = {
    description = "World's most popular open source database";
    homepage = "https://www.mysql.com/";
    license = lib.licenses.gpl2;

    maintainers = [
    ];

    platforms = lib.platforms.unix;
  };
})
