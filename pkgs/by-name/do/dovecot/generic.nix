{
  hash,
  patches,
  version,
}:
{
  lib,
  stdenv,
  autoreconfHook,
  bison,
  buildPackages,
  bzip2,
  clucene-core_2,
  coreutils,
  cyrus_sasl,
  dovecot_pigeonhole,
  fetchpatch,
  fetchzip,
  flex,
  icu75,
  inotify-tools,
  libapparmor,
  libcap,
  libexttextcat,
  libmysqlclient,
  libpq,
  libsodium,
  libstemmer,
  libtirpc,
  libunwind,
  libxcrypt,
  lua5_3,
  lz4,
  nixosTests,
  openldap,
  openssl,
  pam,
  pcre2,
  perl,
  pkg-config,
  rpcsvc-proto,
  sqlite,
  systemd,
  xapian,
  xz,
  zlib,
  zstd,
  withApparmor ? false,
  withLDAP ? true,
  withLua ? false,
  # Auth modules
  withMySQL ? false,
  withPCRE2 ? lib.strings.versionAtLeast version "2.4",
  withPgSQL ? false,
  withSQLite ? true,
  withUnwind ? false,
}:
let
  # The `nativeBuildInputs` version of `mysql_config` emits headers and libraries for
  # the build platform, not the host platform; `pkg-config` emits the correct versions.
  fake_mysql_config = buildPackages.writeShellScriptBin "mysql_config" ''
    if [ "$1" == "--include" ]; then
      "$PKG_CONFIG" --cflags mysqlclient
    elif [ "$1" == "--libs" ]; then
      "$PKG_CONFIG" --libs mysqlclient
    else
      echo "fake_mysql_config: unsupported option: $1" >&2
      exit 1
    fi
  '';
in
stdenv.mkDerivation (finalAttrs: {
  inherit version;
  pname = "dovecot";

  src = fetchzip {
    inherit hash;
    url = "https://dovecot.org/releases/${lib.versions.majorMinor finalAttrs.version}/dovecot-${finalAttrs.version}.tar.gz";
  };

  patches =
    (patches fetchpatch)
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      # fix timespec calls
      ./timespec.patch
    ];

  postPatch = ''
    sed -i -E \
      -e 's!/bin/sh\b!${stdenv.shell}!g' \
      -e 's!([^[:alnum:]/_-])/bin/([[:alnum:]]+)\b!\1${coreutils}/bin/\2!g' \
      -e 's!([^[:alnum:]/_-])(head|sleep|cat)\b!\1${coreutils}/bin/\2!g' \
      src/lib-program-client/test-program-client-local.c

    patchShebangs src/lib-smtp/test-bin/*.sh
    sed -i -s -E 's!\bcat\b!${coreutils}/bin/cat!g' src/lib-smtp/test-bin/*.sh

    patchShebangs src/config/settings-get.pl
  ''
  + (
    let
      filePath =
        if lib.strings.versionAtLeast version "2.4" then
          "src/lib-auth/test-password-scheme.c"
        else
          "src/auth/test-libpassword.c";
    in
    ''
      # DES-encrypted passwords are not supported by Nixpkgs anymore
      sed '/test_password_scheme("CRYPT"/d' -i ${filePath}
    ''
  )
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    export systemdsystemunitdir=$out/etc/systemd/system
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    substituteInPlace configure.ac \
    --replace-fail \
      'NOPLUGIN_LDFLAGS="-no-undefined"' \
      'NOPLUGIN_LDFLAGS="-undefined dynamic_lookup"'
  '';

  strictDeps = true;

  nativeBuildInputs = [
    flex
    bison
    perl
    pkg-config
  ]
  ++ lib.optionals (stdenv.hostPlatform.isLinux && !stdenv.hostPlatform.isDarwin) [ rpcsvc-proto ]
  ++ lib.optionals (stdenv.hostPlatform.isDarwin) [ autoreconfHook ]
  ++ lib.optional (withMySQL && lib.versionOlder version "2.4") fake_mysql_config;

  buildInputs = [
    openssl
    bzip2
    lz4
    zlib
    zstd
    xz
    clucene-core_2
    icu75
    libexttextcat
    libsodium
    libxcrypt
    libstemmer
    cyrus_sasl.dev
  ]
  ++ lib.optionals (lib.versionAtLeast version "2.4") [
    # fts_flatcurve built-in
    xapian
  ]
  ++ lib.optionals (stdenv.hostPlatform.isLinux) [
    systemd
    pam
    libcap
    inotify-tools
  ]
  ++ lib.optional (stdenv.hostPlatform.isLinux && !stdenv.hostPlatform.isDarwin) libtirpc
  ++ lib.optional withApparmor libapparmor
  ++ lib.optional withLDAP openldap
  ++ lib.optional withPCRE2 pcre2
  ++ lib.optional withUnwind libunwind
  ++ lib.optional withMySQL libmysqlclient
  ++ lib.optional withPgSQL libpq
  ++ lib.optional withSQLite sqlite
  ++ lib.optional withLua lua5_3;

  configureFlags = [
    # It will hardcode this for /var/lib/dovecot.
    # http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=626211
    "--localstatedir=/var"
    # We need this so utilities default to reading /etc/dovecot/dovecot.conf file.
    "--sysconfdir=/etc"
    "--with-moduledir=${placeholder "out"}/lib/dovecot/modules"
    "--with-ssl=openssl"
    "--with-zlib"
    "--with-bzlib"
    "--with-lz4"
    "--with-lucene"
    "--with-icu"
    "--with-textcat"
    "--with-lua=${lib.boolToYesNo withLua}"
  ]
  ++ lib.optionals (stdenv.hostPlatform != stdenv.buildPlatform) [
    "i_cv_epoll_works=${lib.boolToYesNo stdenv.hostPlatform.isLinux}"
    "i_cv_posix_fallocate_works=${lib.boolToYesNo stdenv.hostPlatform.isDarwin}"
    "i_cv_inotify_works=${lib.boolToYesNo stdenv.hostPlatform.isLinux}"
    "i_cv_signed_size_t=no"
    "i_cv_signed_time_t=yes"
    "i_cv_c99_vsnprintf=yes"
    "lib_cv_va_copy=yes"
    "i_cv_mmap_plays_with_write=yes"
    "i_cv_gmtime_max_time_t=${toString stdenv.hostPlatform.parsed.cpu.bits}"
    "i_cv_signed_time_t=yes"
    "i_cv_fd_passing=yes"
    "lib_cv_va_copy=yes"
    "lib_cv___va_copy=yes"
    "lib_cv_va_val_copy=yes"
  ]
  ++ lib.optional stdenv.hostPlatform.isLinux "--with-systemd"
  ++ lib.optional stdenv.hostPlatform.isDarwin "--enable-static"
  ++ lib.optional withLDAP "--with-ldap"
  ++ lib.optional withPCRE2 "--with-pcre2"
  ++ lib.optional withMySQL "--with-mysql"
  ++ lib.optional withPgSQL "--with-pgsql"
  ++ lib.optional withSQLite "--with-sqlite";

  env.NIX_LDFLAGS = lib.optionalString stdenv.hostPlatform.isDarwin "-liconv";

  preBuild =
    lib.optionalString (lib.strings.versionOlder version "2.4" && stdenv.hostPlatform.isDarwin)
      ''
        export NIX_LDFLAGS="$NIX_LDFLAGS -undefined dynamic_lookup"
      '';

  doCheck = !stdenv.hostPlatform.isDarwin;

  postInstall = ''
    cp -r $out/$out/* $out
    rm -rf $out/$(echo "$out" | cut -d "/" -f2)
  '';

  enableParallelBuilding = true;
  # We need this for sysconfdir, see remark below.
  installFlags = [ "DESTDIR=$(out)" ];

  passthru = {
    inherit dovecot_pigeonhole;

    tests = {
      inherit (nixosTests) dovecot;
      opensmtpd-interaction = nixosTests.opensmtpd;
    };
  };

  meta = {
    description = "Open source IMAP and POP3 email server written with security primarily in mind";
    homepage = "https://dovecot.org/";

    license = with lib.licenses; [
      mit
      publicDomain
      lgpl21Only
      bsd3
      bsdOriginal
    ];

    maintainers = with lib.maintainers; [
      das_j
      fpletz
      helsinki-Jo
      jappie3
      prince213
    ];

    platforms = lib.platforms.unix;
    mainProgram = "dovecot";
  };
})
