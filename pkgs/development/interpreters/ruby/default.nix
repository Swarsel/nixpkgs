{
  lib,
  stdenv,
  fetchurl,
  autoconf,
  autoreconfHook,
  bison,
  buildEnv,
  buildPackages,
  buildRubyGem,
  bundix,
  bundler,
  defaultGemConfig,
  fetchpatch,
  gdbm,
  gitUpdater,
  groff,
  jemalloc,
  libffi,
  libiconv,
  libsystemtap,
  libunwind,
  libyaml,
  linuxPackages,
  makeBinaryWrapper,
  ncurses,
  openssl,
  readline,
  removeReferencesTo,
  rustPlatform,
  rustc,
  zlib,
}@args:

let
  op = lib.optional;
  ops = lib.optionals;
  opString = lib.optionalString;
  rubygems = import ./rubygems {
    inherit
      stdenv
      lib
      fetchurl
      gitUpdater
      ;
  };

  # Contains the ruby version heuristics
  rubyVersion = import ./ruby-version.nix { inherit lib; };

  generic =
    {
      hash,
      version,
      cargoHash ? null,
    }:
    let
      ver = version;
      # https://github.com/ruby/ruby/blob/v3_2_2/yjit.h#L21
      yjitSupported =
        stdenv.hostPlatform.isx86_64 || (!stdenv.hostPlatform.isWindows && stdenv.hostPlatform.isAarch64);
      rubyDrv = lib.makeOverridable (
        {
          lib,
          stdenv,
          fetchurl,
          autoconf,
          autoreconfHook,
          bison,
          buildEnv,
          buildPackages,
          buildRubyGem,
          bundix,
          bundler,
          defaultGemConfig,
          fetchpatch,
          gdbm,
          gitUpdater,
          groff,
          jemalloc,
          libffi,
          libiconv,
          libsystemtap,
          libunwind,
          libyaml,
          linuxPackages,
          makeBinaryWrapper,
          ncurses,
          openssl,
          readline,
          # By default, ruby has 3 observed references to stdenv.cc:
          #
          # - If you run:
          #     ruby -e "puts RbConfig::CONFIG['configure_args']"
          # - In:
          #     $out/${passthru.libPath}/${stdenv.hostPlatform.system}/rbconfig.rb
          #   Or (usually):
          #     $(nix-build -A ruby)/lib/ruby/2.6.0/x86_64-linux/rbconfig.rb
          # - In $out/lib/libruby.so and/or $out/lib/libruby.dylib
          removeReferencesTo,
          rustPlatform,
          rustc,
          zlib,
          baseRuby ? buildPackages.ruby.override {
            docSupport = false;
            rubygemsSupport = false;
          },
          cursesSupport ? true,
          docSupport ? true,
          dtraceSupport ? false,
          fiddleSupport ? true,
          gdbmSupport ? true,
          jemallocSupport ? false,
          jitSupport ? yjitSupport,
          opensslSupport ? true,
          rubygemsSupport ? true,
          systemtap ? linuxPackages.systemtap,
          useBaseRuby ? stdenv.hostPlatform != stdenv.buildPlatform,
          yamlSupport ? true,
          yjitSupport ? yjitSupported,
          zlibSupport ? true,
        }:
        stdenv.mkDerivation (finalAttrs: {
          inherit version;
          pname = "ruby";

          src = fetchurl {
            inherit hash;
            url = "https://cache.ruby-lang.org/pub/ruby/${ver.majMin}/ruby-${ver}.tar.gz";
          };

          outputs = [ "out" ] ++ lib.optional docSupport "devdoc";

          patches = op useBaseRuby ./do-not-update-gems-baseruby-3.2.patch ++ [
            # When using a baseruby, ruby always sets "libdir" to the build
            # directory, which nix rejects due to a reference in to /build/ in
            # the final product. Removing this reference doesn't seem to break
            # anything and fixes cross compilation.
            ./dont-refer-to-build-dir.patch
          ];

          # Ruby >= 2.1.0 tries to download config.{guess,sub}; copy it from autoconf instead.
          postPatch = ''
            sed -i configure.ac -e '/config.guess/d'
            cp --remove-destination ${autoconf}/share/autoconf/build-aux/config.{guess,sub} tool/
          '';

          strictDeps = true;

          nativeBuildInputs = [
            autoreconfHook
            bison
            removeReferencesTo
          ]
          ++ (op docSupport groff)
          ++ (ops (dtraceSupport && stdenv.hostPlatform.isLinux) [
            systemtap
            libsystemtap
          ])
          ++ ops yjitSupport [
            rustPlatform.cargoSetupHook
            rustc
          ]
          ++ op useBaseRuby baseRuby;

          buildInputs = [
            autoconf
          ]
          ++ (op fiddleSupport libffi)
          ++ (ops cursesSupport [
            ncurses
            readline
          ])
          ++ (op zlibSupport zlib)
          ++ (op opensslSupport openssl)
          ++ (op gdbmSupport gdbm)
          ++ (op yamlSupport libyaml)
          # Looks like ruby fails to build on darwin without readline even if curses
          # support is not enabled, so add readline to the build inputs if curses
          # support is disabled (if it's enabled, we already have it) and we're
          # running on darwin
          ++ op (!cursesSupport && stdenv.hostPlatform.isDarwin) readline
          ++ ops stdenv.hostPlatform.isDarwin [
            libiconv
            libunwind
          ];

          propagatedBuildInputs = op jemallocSupport jemalloc;

          configureFlags = [
            (lib.enableFeature (!stdenv.hostPlatform.isStatic) "shared")
            (lib.enableFeature true "pthread")
            (lib.withFeatureAs true "soname" "ruby-${version}")
            (lib.withFeatureAs useBaseRuby "baseruby" "${baseRuby}/bin/ruby")
            (lib.enableFeature dtraceSupport "dtrace")
            (lib.enableFeature jitSupport "jit-support")
            (lib.enableFeature yjitSupport "yjit")
            (lib.enableFeature docSupport "install-doc")
            (lib.withFeature jemallocSupport "jemalloc")
            (lib.withFeatureAs docSupport "ridir" "${placeholder "devdoc"}/share/ri")
            # ruby enables -O3 for gcc, however our compiler hardening wrapper
            # overrides that by enabling `-O2` which is the minimum optimization
            # needed for `_FORTIFY_SOURCE`.
          ]
          ++ lib.optional stdenv.cc.isGNU "CFLAGS=-O3"
          ++ [
          ]
          # on darwin, we have /usr/include/tk.h -- so the configure script detects
          # that tk is installed
          ++ lib.optional stdenv.hostPlatform.isDarwin "--with-out-ext=tk"
          ++ ops stdenv.hostPlatform.isFreeBSD [
            "rb_cv_gnu_qsort_r=no"
            "rb_cv_bsd_qsort_r=yes"
          ];

          env =
            lib.optionalAttrs (stdenv.hostPlatform != stdenv.buildPlatform && yjitSupport) {
              # The ruby build system will use a bare `rust` command by default for its rust.
              # We can use the Nixpkgs rust wrapper to work around the fact that our Rust builds
              # for cross-compilation output for the build target by default.
              NIX_RUSTFLAGS = "--target ${stdenv.hostPlatform.rust.rustcTargetSpec}";
            }
            // lib.optionalAttrs docSupport {
              # Have `configure' avoid `/usr/bin/nroff' in non-chroot builds.
              NROFF = "${groff}/bin/nroff";
            };

          preConfigure = opString docSupport ''
            # rdoc creates XDG_DATA_DIR (defaulting to $HOME/.local/share) even if
            # it's not going to be used.
            export HOME=$TMPDIR
          '';

          # fails with "16993 tests, 2229489 assertions, 105 failures, 14 errors, 89 skips"
          # mostly TZ- and patch-related tests
          # TZ- failures are caused by nix sandboxing, I didn't investigate others
          doCheck = false;

          preInstall = ''
            # Ruby installs gems here itself now.
            mkdir -pv "$out/${finalAttrs.passthru.gemPath}"
            export GEM_HOME="$out/${finalAttrs.passthru.gemPath}"
          '';

          # Bundler tries to create this directory
          postInstall = ''
            rbConfig=$(find $out/lib/ruby -name rbconfig.rb)
            # Remove references to the build environment from the closure
            sed -i '/^  CONFIG\["\(BASERUBY\|SHELL\|GREP\|EGREP\|MKDIR_P\|MAKEDIRS\|INSTALL\)"\]/d' $rbConfig
            # Remove unnecessary groff reference from runtime closure, since it's big
            sed -i '/NROFF/d' $rbConfig
            ${lib.optionalString (!jitSupport) ''
              # Get rid of the CC runtime dependency
              remove-references-to \
                -t ${stdenv.cc} \
                $out/lib/libruby*
              remove-references-to \
                -t ${stdenv.cc} \
                $rbConfig
              sed -i '/CC_VERSION_MESSAGE/d' $rbConfig
            ''}

            # Allow to override compiler. This is important for cross compiling as
            # we need to set a compiler that is different from the build one.
            sed -i "$rbConfig" \
              -e 's/CONFIG\["CC"\] = "\(.*\)"/CONFIG["CC"] = if ENV["CC"].nil? || ENV["CC"].empty? then "\1" else ENV["CC"] end/' \
              -e 's/CONFIG\["CXX"\] = "\(.*\)"/CONFIG["CXX"] = if ENV["CXX"].nil? || ENV["CXX"].empty? then "\1" else ENV["CXX"] end/'

            # Remove unnecessary external intermediate files created by gems
            extMakefiles=$(find $out/${finalAttrs.passthru.gemPath} -name Makefile)
            for makefile in $extMakefiles; do
              make -C "$(dirname "$makefile")" distclean
            done
            find "$out/${finalAttrs.passthru.gemPath}" \( -name gem_make.out -o -name mkmf.log -o -name exts.mk \) -delete
            # Bundler tries to create this directory
            mkdir -p $out/nix-support
            cat > $out/nix-support/setup-hook <<EOF
            addGemPath() {
              addToSearchPath GEM_PATH \$1/${finalAttrs.passthru.gemPath}
            }
            addRubyLibPath() {
              addToSearchPath RUBYLIB \$1/lib/ruby/site_ruby
              addToSearchPath RUBYLIB \$1/lib/ruby/site_ruby/${ver.libDir}
              addToSearchPath RUBYLIB \$1/lib/ruby/site_ruby/${ver.libDir}/${stdenv.hostPlatform.system}
            }

            addEnvHooks "$hostOffset" addGemPath
            addEnvHooks "$hostOffset" addRubyLibPath
            EOF
          ''
          + opString docSupport ''
            # Prevent the docs from being included in the closure
            sed -i "s|\$(DESTDIR)$devdoc|\$(datarootdir)/\$(RI_BASE_NAME)|" $rbConfig
            sed -i "s|'--with-ridir=$devdoc/share/ri'||" $rbConfig

            # Add rbconfig shim so ri can find docs
            mkdir -p $devdoc/lib/ruby/site_ruby
            cp ${./rbconfig.rb} $devdoc/lib/ruby/site_ruby/rbconfig.rb
          ''
          + opString useBaseRuby ''
            # Prevent the baseruby from being included in the closure.
            remove-references-to \
              -t ${baseRuby} \
              $rbConfig $out/lib/libruby*
          '';

          doInstallCheck = true;

          # TODO: this check got relaxed on darwin;
          # see https://github.com/NixOS/nixpkgs/pull/499156#issuecomment-4221517043
          installCheckPhase = ''
            overriden_cc=$(CC=foo $out/bin/ruby -rrbconfig -e 'puts RbConfig::CONFIG["CC"]')
            if [[ "$overriden_cc" != "foo" ]]; then
               echo "CC cannot be overwritten: $overriden_cc != foo" >&2
               false
            fi

            fallback_cc=$(unset CC; $out/bin/ruby -rrbconfig -e 'puts RbConfig::CONFIG["CC"]')
            if [[ ${
              if stdenv.hostPlatform.isDarwin then ''! "$fallback_cc" =~ "$CC"'' else ''"$fallback_cc" != "$CC"''
            } ]]; then
               echo "CC='$fallback_cc' should be '$CC' by default" >&2
               false
            fi
          '';

          cargoDeps =
            if yjitSupport then
              rustPlatform.fetchCargoVendor {
                inherit (finalAttrs) src cargoRoot;

                hash =
                  assert cargoHash != null;
                  cargoHash;
              }
            else
              null;

          cargoRoot = opString yjitSupport "yjit";
          disallowedRequisites = op (!jitSupport) stdenv.cc ++ op useBaseRuby baseRuby;
          enableParallelBuilding = true;
          # /build/ruby-2.7.7/lib/fileutils.rb:882:in `chmod':
          #   No such file or directory @ apply2files - ...-ruby-2.7.7-devdoc/share/ri/2.7.0/system/ARGF/inspect-i.ri (Errno::ENOENT)
          # make: *** [uncommon.mk:373: do-install-all] Error 1
          enableParallelInstalling = false;
          installFlags = lib.optional docSupport "install-doc";

          postUnpack = opString rubygemsSupport ''
            rm -rf $sourceRoot/{lib,test}/rubygems*
            cp -r ${rubygems}/lib/rubygems* $sourceRoot/lib
          '';

          passthru = rec {
            inherit rubygems;

            inherit
              (import ../../ruby-modules/with-packages {
                inherit
                  lib
                  stdenv
                  makeBinaryWrapper
                  buildRubyGem
                  buildEnv
                  ;

                gemConfig = defaultGemConfig;
                ruby = finalAttrs.finalPackage;
              })
              withPackages
              buildGems
              gems
              ;

            version = ver;

            devEnv = import ./dev.nix {
              inherit buildEnv bundler bundix;
              ruby = finalAttrs.finalPackage;
            };

            gemPath = "lib/${rubyEngine}/gems/${ver.libDir}";
            libPath = "lib/${rubyEngine}/${ver.libDir}";
            rubyEngine = "ruby";
          }
          // lib.optionalAttrs useBaseRuby {
            inherit baseRuby;
          };

          meta = {
            description = "Object-oriented language for quick and easy programming";
            homepage = "https://www.ruby-lang.org/";
            license = lib.licenses.ruby;
            platforms = lib.platforms.all;
            mainProgram = "ruby";
            knownVulnerabilities = op (lib.versionOlder ver.majMin "3.0") "This Ruby release has reached its end of life. See https://www.ruby-lang.org/en/downloads/branches/.";
          };
        })
      ) args;
    in
    rubyDrv;

in
{
  mkRuby = generic;
  mkRubyVersion = rubyVersion;

  ruby_3_3 = generic {
    version = rubyVersion "3" "3" "10" "";
    cargoHash = "sha256-xE7Cv+NVmOHOlXa/Mg72CTSaZRb72lOja98JBvxPvSs=";
    hash = "sha256-tVW6pGejBs/I5sbtJNDSeyfpob7R2R2VUJhZ6saw6Sg=";
  };

  ruby_3_4 = generic {
    version = rubyVersion "3" "4" "9" "";
    cargoHash = "sha256-5Tp8Kth0yO89/LIcU8K01z6DdZRr8MAA0DPKqDEjIt0=";
    hash = "sha256-e7TU9egHzCclHRTZ1ghtGCxbJYdRkeRKsVtwnNen3Zw=";
  };

  ruby_4_0 = generic {
    version = rubyVersion "4" "0" "6" "";
    cargoHash = "sha256-z7NwWc4TaR042hNx0xgRkh/BQEpEJtE53cfrN0qNiE0=";
    hash = "sha256-g30pno993yvjGiKaen4BnTVJeYJRF5iayzsysam+Jio=";
  };

}
