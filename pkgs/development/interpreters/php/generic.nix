# We have tests for PCRE and PHP-FPM in nixos/tests/php/ or
# both in the same attribute named nixosTests.php

let
  generic =
    {
      lib,
      stdenv,
      fetchurl,
      acl,
      apacheHttpd,
      autoconf,
      automake,
      bison,
      callPackage,
      common-updater-scripts,
      coreutils,
      curl,
      flex,
      formats,
      jq,
      libargon2,
      libtool,
      libxml2,
      makeBinaryWrapper,
      nixosTests,
      pcre2,
      pkg-config,
      re2c,
      symlinkJoin,
      system-sendmail,
      systemdLibs,
      tests,
      valgrind,
      version,
      writeShellScript,
      writeText,
      # Misc flags
      apxs2Support ? false,
      argon2Support ? true,
      # Sapi flags
      cgiSupport ? true,
      cgotoSupport ? false,
      cliSupport ? true,
      embedSupport ? false,
      extraPatches ? [ ],
      fpmSupport ? true,
      hash ? null,
      ipv6Support ? true,
      packageOverrides ? (final: prev: { }),
      pearInstallPhar ? (callPackage ./install-pear-nozlib-phar.nix { }),
      pearSupport ? true,
      pharSupport ? true,
      phpAttrsOverrides ? (final: prev: { }),
      phpSrc ? null,
      phpdbgSupport ? true,
      staticSupport ? false,
      systemdSupport ? lib.meta.availableOn stdenv.hostPlatform systemdLibs,
      valgrindSupport ?
        !stdenv.hostPlatform.isDarwin && lib.meta.availableOn stdenv.hostPlatform valgrind,
      zendMaxExecutionTimersSupport ? false,
      zendSignalsSupport ? true,
      ztsSupport ? apxs2Support,
    }@args:

    let
      # buildEnv wraps php to provide additional extensions and
      # configuration. Its usage is documented in
      # doc/languages-frameworks/php.section.md.
      #
      # Create a buildEnv with earlier overridden values and
      # extensions functions in its closure. This is necessary for
      # consecutive calls to buildEnv and overrides to work as
      # expected.
      mkBuildEnv =
        prevArgs: prevExtensionFunctions:
        lib.makeOverridable (
          {
            extensions ? ({ enabled, ... }: enabled),
            extraConfig ? "",
            ...
          }@innerArgs:
          let
            allArgs = args // prevArgs // innerArgs;
            filteredArgs = removeAttrs allArgs [
              "extensions"
              "extraConfig"
            ];
            php = generic filteredArgs;

            php-packages =
              (callPackage ../../../top-level/php-packages.nix {
                phpPackage = phpWithExtensions;
              }).overrideScope
                packageOverrides;

            allExtensionFunctions = prevExtensionFunctions ++ [ extensions ];
            enabledExtensions = builtins.foldl' (
              enabled: f:
              f {
                inherit enabled;
                all = php-packages.extensions;
              }
            ) [ ] allExtensionFunctions;

            getExtName = ext: ext.extensionName;

            # Recursively get a list of all internal dependencies
            # for a list of extensions.
            getDepsRecursively =
              extensions:
              let
                deps = lib.concatMap (ext: (ext.internalDeps or [ ]) ++ (ext.peclDeps or [ ])) extensions;
              in
              if !(deps == [ ]) then deps ++ (getDepsRecursively deps) else deps;

            # Generate extension load configuration snippets from the
            # extension parameter. This is an attrset suitable for use
            # with textClosureList, which is used to put the strings in
            # the right order - if a plugin which is dependent on
            # another plugin is placed before its dependency, it will
            # fail to load.
            extensionTexts = lib.listToAttrs (
              map (
                ext:
                let
                  extName = getExtName ext;
                  phpDeps = (ext.internalDeps or [ ]) ++ (ext.peclDeps or [ ]);
                  type = "${lib.optionalString (ext.zendExtension or false) "zend_"}extension";
                in
                lib.nameValuePair extName {
                  deps = map getExtName phpDeps;
                  text = "${type}=${ext}/lib/php/extensions/${extName}.so";
                }
              ) (enabledExtensions ++ (getDepsRecursively enabledExtensions))
            );

            extNames = map getExtName enabledExtensions;
            extraInit = writeText "php-extra-init-${version}.ini" ''
              ${lib.concatStringsSep "\n" (lib.textClosureList extensionTexts extNames)}
              ${extraConfig}
            '';

            phpWithExtensions = symlinkJoin {
              inherit (php) version;
              pname = "php-with-extensions";
              nativeBuildInputs = [ makeBinaryWrapper ];

              postBuild = ''
                ln -s ${extraInit} $out/lib/php.ini

                if test -e $out/bin/php; then
                  wrapProgram $out/bin/php --set-default PHP_INI_SCAN_DIR $out/lib
                fi

                if test -e $out/bin/php-fpm; then
                  wrapProgram $out/bin/php-fpm --set-default PHP_INI_SCAN_DIR $out/lib
                fi

                if test -e $out/bin/phpdbg; then
                  wrapProgram $out/bin/phpdbg --set-default PHP_INI_SCAN_DIR $out/lib
                fi

                if test -e $out/bin/php-cgi; then
                  wrapProgram $out/bin/php-cgi --set-default PHP_INI_SCAN_DIR $out/lib
                fi
              '';

              paths = [ php ];

              passthru = php.passthru // {
                inherit (php-packages)
                  extensions
                  buildPecl
                  mkComposerRepository
                  mkComposerVendor
                  buildComposerProject
                  buildComposerProject2
                  buildComposerWithPlugin
                  composerHooks
                  composerHooks2
                  mkExtension
                  ;

                buildEnv = mkBuildEnv allArgs allExtensionFunctions;

                overrideAttrs =
                  f:
                  let
                    phpAttrsOverrides = filteredArgs.phpAttrsOverrides or (final: prev: { });
                    newPhpAttrsOverrides = lib.composeExtensions (lib.toExtension phpAttrsOverrides) (
                      lib.toExtension f
                    );
                    php = generic (filteredArgs // { phpAttrsOverrides = newPhpAttrsOverrides; });
                  in
                  php.buildEnv { inherit extensions extraConfig; };

                packages = php-packages.tools;
                phpIni = "${phpWithExtensions}/lib/php.ini";

                # Select the right php tests for the php version
                tests = {
                  nixos =
                    lib.recurseIntoAttrs
                      nixosTests."php${lib.strings.replaceStrings [ "." ] [ "" ] (lib.versions.majorMinor php.version)}";

                  package = tests.php;
                };

                unwrapped = php;
                withExtensions = mkWithExtensions allArgs allExtensionFunctions;

                meta = php.meta // {
                  outputsToInstall = [ "out" ];
                };
              };
            };
          in
          phpWithExtensions
        );

      mkWithExtensions =
        prevArgs: prevExtensionFunctions: extensions:
        mkBuildEnv prevArgs prevExtensionFunctions { inherit extensions; };

      defaultPhpSrc = fetchurl {
        inherit hash;
        url = "https://www.php.net/distributions/php-${version}.tar.bz2";
      };
    in
    stdenv.mkDerivation (
      finalAttrs:
      let
        attrs = {
          inherit version;
          pname = "php";
          src = if phpSrc == null then defaultPhpSrc else phpSrc;

          outputs = [
            "out"
            "dev"
          ];

          patches =
            lib.optionals (lib.versionOlder version "8.4") [
              ./fix-paths-php7.patch
            ]
            ++ lib.optionals (lib.versionAtLeast version "8.4") [
              ./fix-paths-php84.patch
            ]
            ++ extraPatches;

          nativeBuildInputs = [
            autoconf
            automake
            bison
            flex
            libtool
            pkg-config
            re2c
          ];

          buildInputs =
            # PCRE extension
            [ pcre2 ]

            # Enable sapis
            ++ lib.optionals pearSupport [ libxml2.dev ]
            ++ lib.optionals (fpmSupport && stdenv.hostPlatform.isLinux) [ acl ]

            # Misc deps
            ++ lib.optional apxs2Support apacheHttpd
            ++ lib.optional argon2Support libargon2
            ++ lib.optional systemdSupport systemdLibs
            ++ lib.optional valgrindSupport valgrind;

          configureFlags =
            # Disable all extensions
            [ "--disable-all" ]

            # PCRE
            ++ [ "--with-external-pcre=${pcre2.dev}" ]

            # Enable sapis
            ++ lib.optional (!cgiSupport) "--disable-cgi"
            ++ lib.optional (!cliSupport) "--disable-cli"
            ++ lib.optionals fpmSupport [
              "--enable-fpm"
              (lib.withFeature stdenv.hostPlatform.isLinux "fpm-acl")
            ]
            ++ lib.optionals pearSupport [
              "--with-pear"
              "--enable-xml"
              "--with-libxml"
            ]
            ++ lib.optional pharSupport "--enable-phar"
            ++ lib.optional (!phpdbgSupport) "--disable-phpdbg"

            # Misc flags
            ++ lib.optional apxs2Support "--with-apxs2=${apacheHttpd.dev}/bin/apxs"
            ++ lib.optional argon2Support "--with-password-argon2=${libargon2}"
            ++ lib.optional cgotoSupport "--enable-re2c-cgoto"
            ++ lib.optional embedSupport "--enable-embed${lib.optionalString staticSupport "=static"}"
            ++ lib.optional (!ipv6Support) "--disable-ipv6"
            ++ lib.optional systemdSupport "--with-fpm-systemd"
            ++ lib.optional valgrindSupport "--with-valgrind=${valgrind.dev}"
            ++ lib.optional ztsSupport "--enable-zts"
            ++ lib.optional staticSupport "--enable-static"
            ++ lib.optional (!zendSignalsSupport) [ "--disable-zend-signals" ]
            ++ lib.optional zendMaxExecutionTimersSupport "--enable-zend-max-execution-timers"

            # Sendmail
            ++ [ "PROG_SENDMAIL=${system-sendmail}/bin/sendmail" ];

          env = {
            CXXFLAGS = lib.optionalString stdenv.cc.isClang "-std=c++11";
            SKIP_PERF_SENSITIVE = 1;
          };

          preConfigure =
            # Don't record the configure flags since this causes unnecessary
            # runtime dependencies
            ''
              substituteInPlace main/build-defs.h.in \
                --replace-fail '@CONFIGURE_COMMAND@' '(omitted)'
              substituteInPlace scripts/php-config.in \
                --replace-fail '@CONFIGURE_OPTIONS@' "" \
                --replace-fail '@PHP_LDFLAGS@' ""

              export EXTENSION_DIR=$out/lib/php/extensions

              ./buildconf --copy --force

              if [ -f "scripts/dev/genfiles" ]; then
                ./scripts/dev/genfiles
              fi
            ''
            + lib.optionalString stdenv.hostPlatform.isDarwin ''
              substituteInPlace configure --replace-fail "-lstdc++" "-lc++"
            '';

          # When compiling PHP sources from Github, this file is missing and we
          # need to install it ourselves.
          # On the other hand, a distribution includes this file by default.
          preInstall = ''
            if [[ ! -f ./pear/install-pear-nozlib.phar ]]; then
              cp ${pearInstallPhar} ./pear/install-pear-nozlib.phar
            fi
          '';

          postInstall = ''
            test -d $out/etc || mkdir $out/etc
            cp php.ini-production $out/etc/php.ini
          '';

          postFixup = ''
            mkdir -p $dev/bin $dev/lib $dev/share/man/man1
            mv $out/bin/phpize $out/bin/php-config $dev/bin/
            mv $out/lib/build $dev/lib/
            mv $out/share/man/man1/phpize.1.gz \
               $out/share/man/man1/php-config.1.gz \
               $dev/share/man/man1/

            substituteInPlace $dev/bin/phpize \
              --replace-fail "$out/lib" "$dev/lib"
          ''
          + lib.optionalString (lib.versionAtLeast version "8.5") ''
            # PHP 8.5+ has lexbor built into core; dom needs its headers.
            cp -r ext/lexbor/lexbor $dev/include/php/ext/lexbor/
          '';

          enableParallelBuilding = true;
          hardeningDisable = [ "bindnow" ];
          separateDebugInfo = true;

          passthru = {
            inherit ztsSupport;
            buildEnv = mkBuildEnv { } [ ];

            overrideAttrs =
              f:
              let
                newPhpAttrsOverrides = lib.composeExtensions (lib.toExtension phpAttrsOverrides) (
                  lib.toExtension f
                );
                phpOverridden = finalAttrs.overrideAttrs f;
              in
              phpOverridden
              // {
                passthru = phpOverridden.passthru // {
                  buildEnv = mkBuildEnv { phpAttrsOverrides = newPhpAttrsOverrides; } [ ];
                  withExtensions = mkWithExtensions { phpAttrsOverrides = newPhpAttrsOverrides; } [ ];
                };
              };

            services.default = {
              imports = [
                (lib.modules.importApply ./service.nix {
                  inherit formats coreutils;
                })
              ];

              php-fpm.package = lib.mkDefault finalAttrs.finalPackage;
            };

            updateScript =
              let
                script = writeShellScript "php${lib.versions.major version}${lib.versions.minor version}-update-script" ''
                  set -o errexit
                  PATH=${
                    lib.makeBinPath [
                      common-updater-scripts
                      curl
                      jq
                    ]
                  }
                  new_version=$(curl --silent "https://www.php.net/releases/active.php" | jq --raw-output '."${lib.versions.major version}"."${lib.versions.majorMinor version}".version')
                  update-source-version "$UPDATE_NIX_ATTR_PATH.unwrapped" "$new_version" "--file=$1"
                '';
              in
              [
                script
                # Passed as an argument so that update.nix can ensure it does not become a store path.
                ./default.nix
              ];

            withExtensions = mkWithExtensions { } [ ];
          };

          meta = {
            description = "HTML-embedded scripting language";
            homepage = "https://www.php.net/";
            license = lib.licenses.php301;
            platforms = lib.platforms.all;
            mainProgram = "php";

            outputsToInstall = [
              "out"
              "dev"
            ];

            teams = [ lib.teams.php ];
          };
        };
        final = attrs // (lib.toExtension phpAttrsOverrides) final attrs;
      in
      final
    );
in
generic
