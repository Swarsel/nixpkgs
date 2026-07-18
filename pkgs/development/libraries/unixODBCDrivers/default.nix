{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  cmake,
  config,
  dpkg,
  fetchpatch,
  fixDarwinDylibNames,
  libiconv,
  libkrb5,
  libuuid,
  libxml2,
  mariadb,
  openssl,
  patchelf,
  psqlodbc,
  sqlite,
  unixodbc,
  zlib,
}:

# Each of these ODBC drivers can be configured in your odbcinst.ini file using
# the various passthru and meta values. Of note are:
#
#   * `passthru.fancyName`, the typical name used to reference the driver
#   * `passthru.driver`, the path to the driver within the built package
#   * `meta.description`, a short description of the ODBC driver
#
# For example, you might generate it as follows:
#
# ''
# [${package.fancyName}]
# Description = ${package.meta.description}
# Driver = ${package}/${package.driver}
# ''

{
  mariadb = stdenv.mkDerivation rec {
    pname = "mariadb-connector-odbc";
    version = "3.2.6";

    src = fetchFromGitHub {
      owner = "mariadb-corporation";
      repo = "mariadb-connector-odbc";
      rev = version;
      hash = "sha256-FdnA3/xDxnk2910LCMPWQTcUUSYfUsnnZ3Hqj0uey5s=";
      # this driver only seems to build correctly when built against the mariadb-connect-c subrepo
      # (see https://github.com/NixOS/nixpkgs/issues/73258)
      fetchSubmodules = true;
    };

    patches = [
      # Fix `call to undeclared function 'sleep'` with clang 16
      ./mariadb-connector-odbc-unistd.patch

      ./mariadb-connector-odbc-musl.patch

      # Fix build with gcc15
      # https://github.com/mariadb-corporation/mariadb-connector-odbc/pull/63
      (fetchpatch {
        hash = "sha256-GZITSryfRdAgNxZehasoBModGNZo575Dd5aokwNWzpY=";
        name = "mariadb-connector-odbc-add-include-cstdint-gcc15.patch";
        url = "https://github.com/mariadb-corporation/mariadb-connector-odbc/commit/a3ced654db2ef93de0a818f2d66171f6084e5f2d.patch";
      })
    ];

    nativeBuildInputs = [ cmake ];

    buildInputs = [
      unixodbc
      openssl
      libiconv
      zlib
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [ libkrb5 ];

    cmakeFlags = [
      "-DWITH_EXTERNAL_ZLIB=ON"
      "-DODBC_LIB_DIR=${lib.getLib unixodbc}/lib"
      "-DODBC_INCLUDE_DIR=${lib.getDev unixodbc}/include"
      "-DWITH_OPENSSL=ON"
      # on darwin this defaults to ON but we want to build against unixodbc
      "-DWITH_IODBC=OFF"
    ];

    buildFlags = if stdenv.hostPlatform.isDarwin then [ "maodbc" ] else null;

    env = lib.optionalAttrs stdenv.cc.isGNU {
      NIX_CFLAGS_COMPILE = "-Wno-error=incompatible-pointer-types";
    };

    installTargets = if stdenv.hostPlatform.isDarwin then [ "install/fast" ] else null;

    # see the top of the file for an explanation
    passthru = {
      driver = "lib/libmaodbc${stdenv.hostPlatform.extensions.sharedLibrary}";
      fancyName = "MariaDB";
    };

    meta = {
      description = "MariaDB ODBC database driver";
      homepage = "https://downloads.mariadb.org/connector-odbc/";
      license = lib.licenses.gpl2;
      platforms = lib.platforms.linux ++ lib.platforms.darwin;
    };
  };

  msodbcsql17 = stdenv.mkDerivation rec {
    pname = "msodbcsql17";
    version = "${versionMajor}.${versionMinor}.${versionAdditional}-1";

    src = fetchurl {
      url = "https://packages.microsoft.com/debian/10/prod/pool/main/m/msodbcsql17/msodbcsql${versionMajor}_${version}_amd64.deb";
      sha256 = "0vwirnp56jibm3qf0kmi4jnz1w7xfhnsfr8imr0c9hg6av4sk3a6";
    };

    nativeBuildInputs = [
      dpkg
      patchelf
    ];

    buildPhase = "";

    installPhase = ''
      mkdir -p $out
      mkdir -p $out/lib
      cp -r opt/microsoft/msodbcsql${versionMajor}/lib64 opt/microsoft/msodbcsql${versionMajor}/share $out/
    '';

    postFixup = ''
      patchelf --set-rpath ${
        lib.makeLibraryPath [
          unixodbc
          openssl
          libkrb5
          libuuid
          stdenv.cc.cc
        ]
      } \
        $out/lib/libmsodbcsql-${versionMajor}.${versionMinor}.so.${versionAdditional}
    '';

    unpackPhase = "dpkg -x $src ./";
    versionAdditional = "1.1";
    versionMajor = "17";
    versionMinor = "7";

    # see the top of the file for an explanation
    passthru = {
      driver = "lib/libmsodbcsql-${versionMajor}.${versionMinor}.so.${versionAdditional}";
      fancyName = "ODBC Driver ${versionMajor} for SQL Server";
    };

    meta = {
      description = "ODBC Driver ${versionMajor} for SQL Server";
      homepage = "https://docs.microsoft.com/en-us/sql/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server?view=sql-server-2017";
      license = lib.licenses.unfree;
      sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
      maintainers = with lib.maintainers; [ spencerjanssen ];
      platforms = lib.platforms.linux;
      broken = stdenv.hostPlatform.isDarwin;
    };
  };

  msodbcsql18 = stdenv.mkDerivation (finalAttrs: {
    pname = "msodbcsql${finalAttrs.versionMajor}";
    version = "${finalAttrs.versionMajor}.${finalAttrs.versionMinor}.${finalAttrs.versionAdditional}${finalAttrs.versionSuffix}";

    src = fetchurl {
      url =
        {
          aarch64-darwin = "https://download.microsoft.com/download/6/4/0/64006503-51e3-44f0-a6cd-a9b757d0d61b/msodbcsql${finalAttrs.versionMajor}-${finalAttrs.version}-arm64.tar.gz";
          aarch64-linux = "https://packages.microsoft.com/debian/11/prod/pool/main/m/msodbcsql${finalAttrs.versionMajor}/msodbcsql${finalAttrs.versionMajor}_${finalAttrs.version}_arm64.deb";
          x86_64-linux = "https://packages.microsoft.com/debian/11/prod/pool/main/m/msodbcsql${finalAttrs.versionMajor}/msodbcsql${finalAttrs.versionMajor}_${finalAttrs.version}_amd64.deb";
        }
        .${stdenv.system} or (throw "Unsupported system: ${stdenv.system}");

      hash =
        {
          aarch64-darwin = "sha256:116xl8r2apr5b48jnq6myj9fwqs88yccw5176yfyzh4534fznj5x";
          aarch64-linux = "sha256:0zphnbvkqdbkcv6lvv63p7pyl68h5bs2dy6vv44wm6bi89svms4a";
          x86_64-linux = "sha256:1f0rmh1aynf1sqmjclbsyh2wz5jby0fixrwz71zp6impxpwvil52";
        }
        .${stdenv.system} or (throw "Unsupported system: ${stdenv.system}");
    };

    nativeBuildInputs =
      if stdenv.hostPlatform.isDarwin then
        [
          # Fix up the names encoded into the dylib, and make them absolute.
          fixDarwinDylibNames
        ]
      else
        [
          dpkg
          patchelf
        ];

    installPhase =
      if stdenv.hostPlatform.isDarwin then
        ''
          mkdir -p $out
          tar xf $src --strip-components=1 -C $out
        ''
      else
        ''
          mkdir -p $out
          mkdir -p $out/lib
          cp -r opt/microsoft/msodbcsql${finalAttrs.versionMajor}/lib64 opt/microsoft/msodbcsql${finalAttrs.versionMajor}/share $out/
        '';

    postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
      patchelf --set-rpath ${
        lib.makeLibraryPath [
          unixodbc
          openssl
          libkrb5
          libuuid
          stdenv.cc.cc
        ]
      } \
        $out/${finalAttrs.passthru.driver}
    '';

    # Replace the hard-coded paths in the dylib with nixpkgs equivalents.
    fixupPhase = lib.optionalString stdenv.hostPlatform.isDarwin ''
      ${stdenv.cc.bintools.targetPrefix}install_name_tool \
        -change /usr/lib/libiconv.2.dylib ${libiconv}/lib/libiconv.2.dylib \
        -change /opt/homebrew/lib/libodbcinst.2.dylib ${unixodbc}/lib/libodbcinst.2.dylib \
        $out/${finalAttrs.passthru.driver}
    '';

    unpackPhase = lib.optionalString stdenv.hostPlatform.isLinux ''
      dpkg -x $src ./
    '';

    versionAdditional = "1.1";
    versionMajor = "18";
    versionMinor = "1";
    versionSuffix = lib.optionalString stdenv.hostPlatform.isLinux "-1";

    # see the top of the file for an explanation
    passthru = {
      driver = "lib/libmsodbcsql${
        if stdenv.hostPlatform.isDarwin then
          ".${finalAttrs.versionMajor}.dylib"
        else
          "-${finalAttrs.versionMajor}.${finalAttrs.versionMinor}.so.${finalAttrs.versionAdditional}"
      }";

      fancyName = "ODBC Driver ${finalAttrs.versionMajor} for SQL Server";
    };

    meta = {
      description = finalAttrs.passthru.fancyName;
      homepage = "https://learn.microsoft.com/en-us/sql/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server?view=sql-server-ver16";
      license = lib.licenses.unfree;
      sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
      maintainers = with lib.maintainers; [ SamirTalwar ];
      platforms = lib.platforms.unix;
    };
  });

  psql = psqlodbc.override {
    withLibiodbc = false;
    withUnixODBC = true;
  };

  redshift = stdenv.mkDerivation rec {
    pname = "redshift-odbc";
    version = "1.4.49.1000";

    src = fetchurl {
      url = "https://s3.amazonaws.com/redshift-downloads/drivers/odbc/${version}/AmazonRedshiftODBC-64-bit-${version}-1.x86_64.deb";
      sha256 = "sha256-r5HvsZjB7+x+ClxtWoONkE1/NAbz90NbHfzxC6tf7jA=";
    };

    nativeBuildInputs = [ dpkg ];
    buildInputs = [ unixodbc ];

    # `unixodbc` is loaded with `dlopen`, so `autoPatchElfHook` cannot see it, and `patchELF` phase would strip the manual patchelf. Thus:
    # - Manually patchelf with `unixODCB` libraries
    # - Disable automatic `patchELF` phase
    installPhase = ''
      mkdir -p $out/lib
      cp opt/amazon/redshiftodbc/lib/64/* $out/lib
      patchelf --set-rpath ${unixodbc}/lib/ $out/lib/libamazonredshiftodbc64.so
    '';

    dontPatchELF = true;

    unpackPhase = ''
      dpkg -x $src src
      cd src
    '';

    # see the top of the file for an explanation
    passthru = {
      driver = "lib/libamazonredshiftodbc64.so";
      fancyName = "Amazon Redshift (x64)";
    };

    meta = {
      description = "Amazon Redshift ODBC driver";
      homepage = "https://docs.aws.amazon.com/redshift/latest/mgmt/configure-odbc-connection.html";
      license = lib.licenses.unfree;
      sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
      maintainers = with lib.maintainers; [ sir4ur0n ];
      platforms = lib.platforms.linux;
      broken = stdenv.hostPlatform.isDarwin;
    };
  };

  sqlite = stdenv.mkDerivation rec {
    pname = "sqlite-connector-odbc";
    version = "0.99991";

    src = fetchurl {
      url = "http://www.ch-werner.de/sqliteodbc/sqliteodbc-${version}.tar.gz";
      hash = "sha256-TZStuNPN4fqUoorrDfzHvnMUW8383z1eIlQ02zHcilw=";
    };

    patches = [
      # Fix build with gcc15
      (fetchpatch {
        hash = "sha256-IAZDujEkAyU40sKa4GC+upURNt7vplCDAx91Eeny+bU=";
        name = "sqlite-connector-odbc-fix-incompatible-pointer-compilation-error.patch";
        url = "https://src.fedoraproject.org/rpms/sqliteodbc/raw/e3d93f5909c884fd8846b36b71ba67a3ad65da2a/f/sqliteodbc-0.99991-Fix-incompatible-pointer-compilation-error.patch";
      })
    ];

    buildInputs = [
      unixodbc
      sqlite
      zlib
      libxml2
    ];

    configureFlags = [
      "--with-odbc=${unixodbc}"
      "--with-sqlite3=${sqlite.dev}"
    ];

    # move libraries to $out/lib where they're expected to be
    postInstall = ''
      mkdir -p "$out/lib"
      mv "$out"/*.* "$out/lib"
    '';

    installTargets = [ "install-3" ];

    # see the top of the file for an explanation
    passthru = {
      driver = "lib/libsqlite3odbc.so";
      fancyName = "SQLite";
    };

    meta = {
      description = "ODBC driver for SQLite";
      homepage = "http://www.ch-werner.de/sqliteodbc";
      changelog = "http://www.ch-werner.de/sqliteodbc/html/index.html#changelog";
      license = lib.licenses.bsd2;
      maintainers = with lib.maintainers; [ vlstill ];
      platforms = lib.platforms.unix;
    };
  };
}
// lib.optionalAttrs config.allowAliases {
  mysql = throw "unixodbcDrivers.mysql has been removed because it has been marked as broken since 2016."; # Added 2025-10-11
}
