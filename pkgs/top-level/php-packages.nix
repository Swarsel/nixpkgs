{
  lib,
  stdenv,
  autoconf,
  bison,
  bzip2,
  callPackages,
  config,
  curl,
  cyrus_sasl,
  enchant,
  freetds,
  gd,
  gettext,
  gmp,
  html-tidy,
  icu73,
  libffi,
  libiconv,
  libkrb5,
  libpq,
  libsodium,
  libxml2,
  libxslt,
  libzip,
  net-snmp,
  nix-update-script,
  oniguruma,
  openldap,
  openssl,
  pam,
  pcre2,
  phpPackage,
  pkg-config,
  pkgs,
  re2c,
  readline,
  rsync,
  sqlite,
  unixodbc,
  uwimap,
  valgrind,
  zlib,
}:

lib.makeScope pkgs.newScope (
  self:
  let
    inherit (self)
      buildPecl
      callPackage
      mkExtension
      php
      ;

    builders = import ../build-support/php/builders {
      inherit callPackages callPackage buildPecl;
    };
  in
  {
    inherit (builders.v1)
      buildComposerProject
      buildComposerWithPlugin
      composerHooks
      mkComposerRepository
      ;

    # Next version of the builder
    buildComposerProject2 = builders.v2.buildComposerProject;

    buildPecl = callPackage ../build-support/php/build-pecl.nix {
      php = php.unwrapped;
    };

    composerHooks2 = builders.v2.composerHooks;

    # This is a set of PHP extensions meant to be used in php.buildEnv
    # or php.withExtensions to extend the functionality of the PHP
    # interpreter.
    # The extensions attributes is composed of three sections:
    # 1. The contrib conditional extensions, which are only available on specific PHP versions
    # 2. The contrib extensions available
    # 3. The core extensions
    extensions =
      # Contrib extensions
      {
        amqp = callPackage ../development/php-packages/amqp { };
        apcu = callPackage ../development/php-packages/apcu { };
        ast = callPackage ../development/php-packages/ast { };
        blackfire = callPackage ../by-name/bl/blackfire/php-probe.nix { };
        couchbase = callPackage ../development/php-packages/couchbase { };
        datadog_trace = callPackage ../development/php-packages/datadog_trace { };
        decimal = callPackage ../development/php-packages/decimal { };
        ds = callPackage ../development/php-packages/ds { };
        event = callPackage ../development/php-packages/event { };
        excimer = callPackage ../development/php-packages/excimer { };
        gnupg = callPackage ../development/php-packages/gnupg { };
        grpc = callPackage ../development/php-packages/grpc { };
        igbinary = callPackage ../development/php-packages/igbinary { };
        imagick = callPackage ../development/php-packages/imagick { };
        # Shadowed by built-in version on PHP < 8.3.
        imap = callPackage ../development/php-packages/imap { };
        inotify = callPackage ../development/php-packages/inotify { };
        ioncube-loader = callPackage ../development/php-packages/ioncube-loader { };
        luasandbox = callPackage ../development/php-packages/luasandbox { };
        mailparse = callPackage ../development/php-packages/mailparse { };
        maxminddb = callPackage ../development/php-packages/maxminddb { };
        memcache = callPackage ../development/php-packages/memcache { };
        memcached = callPackage ../development/php-packages/memcached { };
        meminfo = callPackage ../development/php-packages/meminfo { };
        memprof = callPackage ../development/php-packages/memprof { };
        mongodb = callPackage ../development/php-packages/mongodb { };
        msgpack = callPackage ../development/php-packages/msgpack { };
        oci8 = callPackage ../development/php-packages/oci8 { };
        openswoole = callPackage ../development/php-packages/openswoole { };
        opentelemetry = callPackage ../development/php-packages/opentelemetry { };
        parallel = callPackage ../development/php-packages/parallel { };
        pcov = callPackage ../development/php-packages/pcov { };
        pdlib = callPackage ../development/php-packages/pdlib { };

        pdo_oci =
          if (lib.versionAtLeast php.version "8.4") then
            callPackage ../development/php-packages/pdo_oci { }
          else
            buildPecl rec {
              inherit (php.unwrapped) src version;
              pname = "pdo_oci";

              postPatch = ''
                sed -i -e 's|OCISDKMANINC=`.*$|OCISDKMANINC="${pkgs.oracle-instantclient.dev}/include"|' config.m4
              '';

              buildInputs = [ pkgs.oracle-instantclient ];
              configureFlags = [ "--with-pdo-oci=instantclient,${pkgs.oracle-instantclient.lib}/lib" ];
              internalDeps = [ php.extensions.pdo ];
              sourceRoot = "php-${version}/ext/pdo_oci";
              meta.teams = [ lib.teams.php ];
            };

        pdo_sqlsrv = callPackage ../development/php-packages/pdo_sqlsrv { };
        phalcon = callPackage ../development/php-packages/phalcon { };
        pinba = callPackage ../development/php-packages/pinba { };
        protobuf = callPackage ../development/php-packages/protobuf { };
        pspell = callPackage ../development/php-packages/pspell { };
        rdkafka = callPackage ../development/php-packages/rdkafka { };
        redis = callPackage ../development/php-packages/redis { };
        relay = callPackage ../development/php-packages/relay { };
        rrd = callPackage ../development/php-packages/rrd { };
        smbclient = callPackage ../development/php-packages/smbclient { };
        snuffleupagus = callPackage ../development/php-packages/snuffleupagus { };
        spx = callPackage ../development/php-packages/spx { };
        sqlsrv = callPackage ../development/php-packages/sqlsrv { };
        ssh2 = callPackage ../development/php-packages/ssh2 { };
        swoole = callPackage ../development/php-packages/swoole { };
        systemd = callPackage ../development/php-packages/systemd { };
        tideways = callPackage ../development/php-packages/tideways { };
        uuid = callPackage ../development/php-packages/uuid { };
        uv = callPackage ../development/php-packages/uv { };
        vld = callPackage ../development/php-packages/vld { };
        wikidiff2 = callPackage ../development/php-packages/wikidiff2 { };
        xdebug = callPackage ../development/php-packages/xdebug { };
        yaml = callPackage ../development/php-packages/yaml { };
        zstd = callPackage ../development/php-packages/zstd { };
      }
      // lib.optionalAttrs config.allowAliases {
        openssl-legacy = throw "openssl-legacy has been removed";
        php-spx = throw "php-spx is deprecated, use spx instead";
      }
      // (
        # Core extensions
        let
          # This list contains build instructions for different modules that one may
          # want to build.
          #
          # These will be passed as arguments to mkExtension above.
          extensionData = [
            {
              env.NIX_CFLAGS_COMPILE = "-std=gnu17";
              name = "bcmath";
            }
            {
              buildInputs = [ bzip2 ];
              configureFlags = [ "--with-bz2=${bzip2.dev}" ];
              name = "bz2";
            }
            { name = "calendar"; }
            {
              postPatch =
                lib.optionalString (stdenv.hostPlatform.isDarwin && lib.versionAtLeast php.version "8.2")
                  # Broken test on aarch64-darwin
                  ''
                    rm ext/ctype/tests/lc_ctype_inheritance.phpt
                  '';

              name = "ctype";
            }
            {
              buildInputs = [ curl ];
              configureFlags = [ "--with-curl=${curl.dev}" ];
              doCheck = false;
              name = "curl";
            }
            { name = "dba"; }
            {
              buildInputs = [ libxml2 ];

              configureFlags = [
                "--enable-dom"
              ];

              # PHP 8.5+ has lexbor built into core; dom needs its headers.
              env = lib.optionalAttrs (lib.versionAtLeast php.version "8.5") {
                NIX_CFLAGS_COMPILE = "-I${php.unwrapped.dev}/include/php/ext/lexbor";
              };

              name = "dom";
            }
            {
              buildInputs = [ enchant ];
              configureFlags = [ "--with-enchant" ];
              doCheck = false;
              name = "enchant";
            }
            {
              doCheck = false;
              name = "exif";
            }
            {
              buildInputs = [ libffi ];
              name = "ffi";
            }
            {
              buildInputs = [ pcre2 ];
              name = "fileinfo";
            }
            {
              buildInputs = [ pcre2 ];
              name = "filter";
            }
            {
              buildInputs = [ openssl ];
              name = "ftp";
            }
            {
              buildInputs = [
                zlib
                gd
              ];

              configureFlags = [
                "--enable-gd"
                "--with-external-gd=${gd.dev}"
                "--enable-gd-jis-conv"
              ];

              doCheck = false;
              name = "gd";
            }
            {
              buildInputs = [ gettext ];
              configureFlags = [ "--with-gettext=${gettext}" ];
              name = "gettext";
              postPhpize = ''substituteInPlace configure --replace-fail 'as_fn_error $? "Cannot locate header file libintl.h" "$LINENO" 5' ':' '';
            }
            {
              buildInputs = [ gmp ];
              configureFlags = [ "--with-gmp=${gmp.dev}" ];
              name = "gmp";
            }
            {
              buildInputs = [ libiconv ];
              configureFlags = [ "--with-iconv" ];
              # Some other extensions support separate libdirs, but iconv does not. This causes problems with detecting
              # Darwin’s libiconv because it has separate outputs. Adding `-liconv` works around the issue.
              env = lib.optionalAttrs stdenv.hostPlatform.isDarwin { NIX_LDFLAGS = "-liconv"; };
              doCheck = stdenv.hostPlatform.isLinux;
              name = "iconv";
            }
            {
              buildInputs = [ icu73 ];
              name = "intl";
            }
            {
              buildInputs = [
                openldap
                cyrus_sasl
              ];

              configureFlags = [
                "--with-ldap"
                "LDAP_DIR=${openldap.dev}"
                "LDAP_INCDIR=${openldap.dev}/include"
                "LDAP_LIBDIR=${openldap.out}/lib"
              ]
              ++ lib.optionals stdenv.hostPlatform.isLinux [
                "--with-ldap-sasl=${cyrus_sasl.dev}"
              ];

              doCheck = false;
              name = "ldap";
            }
            {
              buildInputs = [
                oniguruma
                pcre2
              ];

              doCheck = false;
              name = "mbstring";
            }
            {
              configureFlags = [
                "--with-mysqli=mysqlnd"
                "--with-mysql-sock=/run/mysqld/mysqld.sock"
              ];

              doCheck = false;
              internalDeps = [ php.extensions.mysqlnd ];
              name = "mysqli";
            }
            {
              # The configure script builds a config.h which is never
              # included. Let's include it in the main header file
              # included by all .c-files.
              patches = [
                (pkgs.writeText "mysqlnd_config.patch" ''
                  --- a/ext/mysqlnd/mysqlnd.h
                  +++ b/ext/mysqlnd/mysqlnd.h
                  @@ -1,3 +1,6 @@
                  +#ifdef HAVE_CONFIG_H
                  +#include "config.h"
                  +#endif
                   /*
                     +----------------------------------------------------------------------+
                     | Copyright (c) The PHP Group                                          |
                '')
              ];

              buildInputs = [
                zlib
                openssl
              ];

              configureFlags = [ "--with-mysqlnd-ssl" ];
              # The configure script doesn't correctly add library link
              # flags, so we add them to the variable used by the Makefile
              # when linking.
              env.MYSQLND_SHARED_LIBADD = "-lz -lssl -lcrypto";
              name = "mysqlnd";
            }
            {
              buildInputs = [ openssl ];
              configureFlags = [ "--with-openssl" ];
              doCheck = false;
              name = "openssl";
            }
            { name = "pcntl"; }
            {
              doCheck = false;
              name = "pdo";
            }
            {
              configureFlags = [ "--with-pdo-dblib=${freetds}" ];
              doCheck = false;
              internalDeps = [ php.extensions.pdo ];
              name = "pdo_dblib";
              meta.broken = stdenv.hostPlatform.isDarwin;
            }
            {
              configureFlags = [
                "--with-pdo-mysql=mysqlnd"
                "PHP_MYSQL_SOCK=/run/mysqld/mysqld.sock"
              ];

              doCheck = false;

              internalDeps = with php.extensions; [
                pdo
                mysqlnd
              ];

              name = "pdo_mysql";
            }
            {
              buildInputs = [ unixodbc ];
              configureFlags = [ "--with-pdo-odbc=unixODBC,${unixodbc}" ];
              doCheck = false;
              internalDeps = [ php.extensions.pdo ];
              name = "pdo_odbc";
            }
            {
              configureFlags = [ "--with-pdo-pgsql=${libpq.pg_config}" ];
              doCheck = false;
              internalDeps = [ php.extensions.pdo ];
              name = "pdo_pgsql";
            }
            {
              buildInputs = [ sqlite ];
              configureFlags = [ "--with-pdo-sqlite=${sqlite.dev}" ];
              doCheck = false;
              internalDeps = [ php.extensions.pdo ];
              name = "pdo_sqlite";
            }
            {
              buildInputs = [
                pcre2
              ];

              configureFlags = [ "--with-pgsql=${libpq.pg_config}" ];
              doCheck = false;
              name = "pgsql";
            }
            {
              doCheck = false;
              name = "posix";
            }
            {
              postPatch = ''
                # Fix `--with-readline` option not being available.
                # `PHP_ALWAYS_SHARED` generated by phpize enables all options
                # without the possibility to override them. But when `--with-libedit`
                # is enabled, `--with-readline` is not registered.
                echo '
                AC_DEFUN([PHP_ALWAYS_SHARED],[
                  test "[$]$1" != "no" && ext_shared=yes
                ])dnl
                ' | cat - ext/readline/config.m4 > ext/readline/config.m4.tmp
                mv ext/readline/config.m4{.tmp,}
              '';

              buildInputs = [
                readline
              ];

              configureFlags = [
                "--with-readline=${readline.dev}"
              ];

              doCheck = false;
              name = "readline";
            }
            {
              doCheck = false;
              name = "session";
            }
            { name = "shmop"; }
            {
              buildInputs = [
                libxml2
                pcre2
              ];

              configureFlags = [
                "--enable-simplexml"
              ];

              name = "simplexml";
            }
            {
              buildInputs = [
                net-snmp
                openssl
              ];

              configureFlags = [ "--with-snmp" ];
              doCheck = false;
              name = "snmp";
            }
            {
              buildInputs = [ libxml2 ];

              configureFlags = [
                "--enable-soap"
              ];

              # Some tests are causing issues in the Darwin sandbox with issues
              # such as
              #   Unknown: php_network_getaddresses: getaddrinfo for localhost failed: nodename nor servname provided
              doCheck = !stdenv.hostPlatform.isDarwin && lib.versionOlder php.version "8.4";
              internalDeps = [ php.extensions.session ];
              name = "soap";
            }
            {
              doCheck = false;
              name = "sockets";
            }
            {
              buildInputs = [ libsodium ];
              name = "sodium";
            }
            {
              # The `sqlite3_bind_bug68849.phpt` test is currently broken for i686 Linux systems since sqlite 3.43, cf.:
              # - https://github.com/php/php-src/issues/12076
              # - https://www.sqlite.org/forum/forumpost/abbb95376ec6cd5f
              patches = lib.optionals (stdenv.hostPlatform.isi686 && stdenv.hostPlatform.isLinux) [
                ../development/interpreters/php/skip-sqlite3_bind_bug68849.phpt.patch
              ];

              buildInputs = [ sqlite ];
              name = "sqlite3";
            }
            { name = "sysvmsg"; }
            { name = "sysvsem"; }
            {
              configureFlags = [ "CFLAGS=-std=gnu17" ];
              name = "sysvshm";
            }
            {
              configureFlags = [ "--with-tidy=${html-tidy}" ];
              doCheck = false;
              name = "tidy";
            }
            {
              patches = [ ../development/interpreters/php/fix-tokenizer-php81.patch ];
              name = "tokenizer";
            }
            {
              buildInputs = [ libxml2 ];

              configureFlags = [
                "--enable-xml"
              ];

              doCheck = false;
              name = "xml";
            }
            {
              buildInputs = [ libxml2 ];

              configureFlags = [
                "--enable-xmlreader"
              ];

              env.NIX_CFLAGS_COMPILE = toString [
                "-I../.."
                "-DHAVE_DOM"
              ];

              doCheck = false;
              internalDeps = [ php.extensions.dom ];
              name = "xmlreader";
            }
            {
              buildInputs = [ libxml2 ];

              configureFlags = [
                "--enable-xmlwriter"
              ];

              name = "xmlwriter";
            }
            {
              buildInputs = [
                libxslt
                libxml2
              ];

              configureFlags = [ "--with-xsl=${libxslt.dev}" ];

              env.NIX_CFLAGS_COMPILE = toString [
                "-I../.."
                "-DHAVE_DOM"
              ];

              doCheck = false;
              internalDeps = [ php.extensions.dom ];
              name = "xsl";
            }
            {
              env.NIX_CFLAGS_COMPILE = "-I${libxml2.dev}/include/libxml2";
              internalDeps = [ php.extensions.dom ];
              name = "zend_test";
            }
            {
              buildInputs = [
                libzip
                pcre2
              ];

              configureFlags = [
                "--with-zip"
              ];

              doCheck = false;
              name = "zip";
            }
            {
              buildInputs = [ zlib ];

              configureFlags = [
                "--with-zlib"
              ];

              name = "zlib";
            }
          ]
          ++ lib.optionals (lib.versionOlder php.version "8.3") [
            # Using version from PECL on new PHP versions.
            {
              buildInputs = [
                uwimap
                openssl
                pam
                pcre2
                libkrb5
              ];

              configureFlags = [
                "--with-imap=${uwimap}"
                "--with-imap-ssl"
                "--with-kerberos"
              ];

              name = "imap";
            }
          ]
          ++ lib.optionals (lib.versionOlder php.version "8.5") [
            {
              postPatch = lib.optionalString stdenv.hostPlatform.isDarwin ''
                # Tests are flaky on darwin
                rm ext/opcache/tests/blacklist.phpt
                rm ext/opcache/tests/bug66338.phpt
                rm ext/opcache/tests/bug78106.phpt
                rm ext/opcache/tests/issue0115.phpt
                rm ext/opcache/tests/issue0149.phpt
                rm ext/opcache/tests/revalidate_path_01.phpt
              '';

              buildInputs = [
                pcre2
              ]
              ++ lib.optional (
                !stdenv.hostPlatform.isDarwin && lib.meta.availableOn stdenv.hostPlatform valgrind
              ) valgrind.dev;

              configureFlags = lib.optional php.ztsSupport "--disable-opcache-jit";
              # Tests launch the builtin webserver.
              __darwinAllowLocalNetworking = true;
              name = "opcache";
              zendExtension = true;
            }
          ];

          # Convert the list of attrs:
          # [ { name = <name>; ... } ... ]
          # to a list of
          # [ { name = <name>; value = <extension drv>; } ... ]
          #
          # which we later use listToAttrs to make all attrs available by name.
          namedExtensions = map (drv: {
            name = drv.name;
            value = mkExtension drv;
          }) extensionData;

        in
        # Produce the final attribute set of all extensions defined.
        builtins.listToAttrs namedExtensions
      );

    mkComposerVendor = builders.v2.mkComposerVendor;

    # Wrap mkDerivation to prepend pname with "php-" to make names consistent
    # with how buildPecl does it and make the file easier to overview.
    mkDerivation =
      origArgs:
      let
        args = lib.fix (
          lib.extends (_: previousAttrs: {
            pname = "php-${previousAttrs.pname}";

            passthru = (previousAttrs.passthru or { }) // {
              updateScript = nix-update-script { };
            };

            meta = (previousAttrs.meta or { }) // {
              mainProgram = previousAttrs.meta.mainProgram or previousAttrs.pname;
            };
          }) (if lib.isFunction origArgs then origArgs else (_: origArgs))
        );
      in
      pkgs.stdenv.mkDerivation args;

    # Function to build an extension which is shipped as part of the php
    # source, based on the php version.
    #
    # Name passed is the name of the extension and is automatically used
    # to add the configureFlag "--enable-${name}", which can be overridden.
    #
    # Build inputs is used for extra deps that may be needed. And zendExtension
    # will mark the extension as a zend extension or not.
    mkExtension = lib.makeOverridable (
      {
        name,
        buildInputs ? [ ],
        configureFlags ? [ "--enable-${extName}" ],
        doCheck ? true,
        extName ? name,
        internalDeps ? [ ],
        postPhpize ? "",
        zendExtension ? false,
        ...
      }@args:
      stdenv.mkDerivation (
        (removeAttrs args [ "name" ])
        // {
          inherit (php.unwrapped) version src;

          inherit
            configureFlags
            internalDeps
            buildInputs
            zendExtension
            doCheck
            ;

          pname = "php-${name}";

          outputs = [
            "out"
            "dev"
          ];

          nativeBuildInputs = [
            php.unwrapped
            autoconf
            pkg-config
            re2c
            bison
          ];

          preConfigure = ''
            nullglobRestore=$(shopt -p nullglob)
            shopt -u nullglob   # To make ?-globbing work

            # Some extensions have a config0.m4 or config9.m4
            if [ -f config?.m4 ]; then
              mv config?.m4 config.m4
            fi

            $nullglobRestore

            phpize
            ${postPhpize}

            ${lib.concatMapStringsSep "\n" (
              dep: "mkdir -p ext; ln -s ${dep.dev}/include ext/${dep.extensionName}"
            ) internalDeps}
          '';

          checkPhase = ''
            runHook preCheck

            NO_INTERACTION=yes SKIP_PERF_SENSITIVE=yes SKIP_ONLINE_TESTS=yes make test
            runHook postCheck
          '';

          installPhase = ''
            runHook preInstall

            mkdir -p $out/lib/php/extensions
            cp modules/${extName}.so $out/lib/php/extensions/${extName}.so
            mkdir -p $dev/include
            ${rsync}/bin/rsync -r --filter="+ */" \
                                  --filter="+ *.h" \
                                  --filter="- *" \
                                  --prune-empty-dirs \
                                  . $dev/include/

            runHook postInstall
          '';

          cdToExtensionRootPhase = ''
            # Go to extension source root.
            cd "ext/${extName}"
          '';

          enableParallelBuilding = true;
          extensionName = extName;

          genfiles = ''
            if [ -f "scripts/dev/genfiles" ]; then
              ./scripts/dev/genfiles
            fi
          '';

          preConfigurePhases = [
            "genfiles"
            "cdToExtensionRootPhase"
          ];

          meta = {
            inherit (php.meta)
              teams
              homepage
              license
              platforms
              ;

            description = "PHP upstream extension: ${name}";
          }
          // args.meta or { };
        }
      )
    );

    php = phpPackage;

    # This is a set of interactive tools based on PHP.
    tools = {
      box = callPackage ../development/php-packages/box { };
      castor = callPackage ../development/php-packages/castor { };
      composer = callPackage ../development/php-packages/composer { };
      composer-local-repo-plugin = callPackage ../development/php-packages/composer-local-repo-plugin { };
      cyclonedx-php-composer = callPackage ../development/php-packages/cyclonedx-php-composer { };
      grumphp = callPackage ../development/php-packages/grumphp { };
      phan = callPackage ../development/php-packages/phan { };
      phing = callPackage ../development/php-packages/phing { };
      phive = callPackage ../development/php-packages/phive { };
      php-codesniffer = callPackage ../development/php-packages/php-codesniffer { };
      php-cs-fixer = callPackage ../development/php-packages/php-cs-fixer { };
      php-parallel-lint = callPackage ../development/php-packages/php-parallel-lint { };
      phpinsights = callPackage ../development/php-packages/phpinsights { };
      phpmd = callPackage ../development/php-packages/phpmd { };
      phpspy = callPackage ../development/php-packages/phpspy { };
      psalm = callPackage ../development/php-packages/psalm { };
    }
    // lib.optionalAttrs config.allowAliases {
      deployer = throw "`php8${lib.versions.minor php.version}Packages.deployer` has been removed, use `deployer`";
      phpcbf = throw "`php8${lib.versions.minor php.version}Packages.phpcbf` has been removed, use `php-codesniffer` instead which contains both `phpcs` and `phpcbf`.";
      phpcs = throw "`php8${lib.versions.minor php.version}Packages.phpcs` has been removed, use `php-codesniffer` instead which contains both `phpcs` and `phpcbf`.";
      phpstan = throw "`php8${lib.versions.minor php.version}Packages.phpstan` has been removed, use `phpstan` instead.";
      psysh = throw "`php8${lib.versions.minor php.version}Packages.psysh` has been removed, use `psysh`";
    };
  }
)
