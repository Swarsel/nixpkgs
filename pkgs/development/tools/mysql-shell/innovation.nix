{
  lib,
  stdenv,
  fetchurl,
  antlr,
  bison,
  cctools,
  cmake,
  curl,
  cyrus_sasl,
  darwin,
  git,
  icu,
  libedit,
  libevent,
  libfido2,
  libssh,
  libtirpc,
  lz4,
  makeWrapper,
  ncurses,
  openldap,
  openssl,
  pkg-config,
  protobuf,
  python3,
  re2,
  readline,
  rpcsvc-proto,
  zlib,
  zstd,
}:

let
  pythonDeps = with python3.pkgs; [
    certifi
    paramiko
    pyyaml
  ];

  mysqlShellVersion = "9.7.0";
  mysqlServerVersion = "9.7.0";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "mysql-shell-innovation";
  version = mysqlShellVersion;

  patches = [
    # No openssl bundling on macOS. It's not working.
    # See https://github.com/mysql/mysql-shell/blob/5b84e0be59fc0e027ef3f4920df15f7be97624c1/cmake/ssl.cmake#L53
    ./no-openssl-bundling.patch
  ];

  postPatch = ''
    substituteInPlace ../mysql/cmake/libutils.cmake --replace-fail /usr/bin/libtool libtool
    substituteInPlace ../mysql/cmake/os/Darwin.cmake --replace-fail /usr/bin/libtool libtool

    substituteInPlace cmake/libutils.cmake --replace-fail /usr/bin/libtool libtool

    ${lib.optionalString stdenv.hostPlatform.isDarwin ''
      patch -d .. -p1 < ${./mysql-server-libcxx-21.patch}
    ''}
  '';

  nativeBuildInputs = [
    pkg-config
    cmake
    git
    bison
    makeWrapper
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [ rpcsvc-proto ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    cctools
    darwin.DarwinTools
  ];

  buildInputs = [
    curl
    libedit
    libssh
    lz4
    openssl
    protobuf
    readline
    zlib
    zstd
    libevent
    icu
    re2
    ncurses
    libfido2
    cyrus_sasl
    openldap
    python3
    antlr.runtime.cpp
  ]
  ++ pythonDeps
  ++ lib.optionals stdenv.hostPlatform.isLinux [ libtirpc ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ darwin.libutil ];

  env = lib.optionalAttrs stdenv.cc.isGNU {
    NIX_CFLAGS_COMPILE = "-Wno-error=maybe-uninitialized -Wno-error=array-bounds";
  };

  preConfigure = ''
    # Build MySQL
    echo "Building mysqlclient mysqlxclient"

    cmake -DWITH_SYSTEM_LIBS=ON -DWITH_FIDO=system -DWITH_ROUTER=ON -DWITH_UNIT_TESTS=OFF \
      -DFORCE_UNSUPPORTED_COMPILER=1 -S ../mysql -B ../mysql/build

    cmake --build ../mysql/build --parallel ''${NIX_BUILD_CORES:-1} \
      --target mysqlclient mysqlxclient mysqlbinlog mysql_binlog_event_standalone mysqlrouter_all

    cmakeFlagsArray+=(
      "-DMYSQL_SOURCE_DIR=''${NIX_BUILD_TOP}/mysql"
      "-DMYSQL_BUILD_DIR=''${NIX_BUILD_TOP}/mysql/build"
      "-DMYSQL_CONFIG_EXECUTABLE=''${NIX_BUILD_TOP}/mysql/build/scripts/mysql_config"
      "-DWITH_ZSTD=system"
      "-DWITH_LZ4=system"
      "-DWITH_ZLIB=system"
      "-DWITH_PROTOBUF=system"
      "-DHAVE_PYTHON=1"
    )
  '';

  postFixup = ''
    wrapProgram $out/bin/mysqlsh --set PYTHONPATH "${lib.makeSearchPath python3.sitePackages pythonDeps}"
  '';

  postUnpack = ''
    mv mysql-${mysqlServerVersion} mysql
  '';

  sourceRoot = "mysql-shell-${finalAttrs.version}-src";

  srcs = [
    (fetchurl {
      hash = "sha256-dLV0urxWsOy2MqvTWdITxnlOz0Qq5Ekov8WB+z1iMG0=";
      url = "https://dev.mysql.com/get/Downloads/MySQL-${lib.versions.majorMinor mysqlServerVersion}/mysql-${mysqlServerVersion}.tar.gz";
    })
    (fetchurl {
      hash = "sha256-s/omxSFTC/n3B8OtYddDqXzCd4GE4b5O8NUKbLdvwRI=";
      url = "https://dev.mysql.com/get/Downloads/MySQL-Shell/mysql-shell-${finalAttrs.version}-src.tar.gz";
    })
  ];

  meta = {
    description = "New command line scriptable shell for MySQL";
    homepage = "https://dev.mysql.com/doc/mysql-shell/${lib.versions.majorMinor finalAttrs.version}/en/";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ aaronjheng ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "mysqlsh";
  };
})
