{
  lib,
  fetchurl,
  buildPlatform,
  checkMeta,
  config,
  hostPlatform,
}:

lib.makeScope
  # Prevent using top-level attrs to protect against introducing dependency on
  # non-bootstrap packages by mistake. Any top-level inputs must be explicitly
  # declared here.
  (
    extra:
    lib.callPackageWith (
      {
        inherit
          lib
          config
          buildPlatform
          hostPlatform
          fetchurl
          checkMeta
          ;
      }
      // extra
    )
  )
  (
    self:
    with self;
    (
      {
        inherit (self.stage0-posix)
          kaem
          m2libc
          mescc-tools
          mescc-tools-extra
          ;

        inherit (callPackage ./utils.nix { inherit hostPlatform; })
          derivationWithMeta
          writeTextFile
          writeText
          ;

        bash = callPackage ./bash {
          bootBash = bash_2_05;
          coreutils = coreutils-musl;
          gnumake = gnumake-musl;
          gnutar = gnutar-musl;
          tinycc = tinycc-musl;
        };

        bash-static = callPackage ./bash/static.nix {
          gcc = gcc-latest;
          gnumake = gnumake-musl;
          gnutar = gnutar-latest;
        };

        bash_2_05 = callPackage ./bash/2.nix { tinycc = tinycc-mes; };

        binutils = callPackage ./binutils {
          gnumake = gnumake-musl;
          gnutar = gnutar-musl;
          tinycc = tinycc-musl;
        };

        binutils-static = callPackage ./binutils/static.nix {
          gcc = gcc-latest;
          gnumake = gnumake-musl;
          gnutar = gnutar-latest;
        };

        bison = callPackage ./bison {
          gcc = gcc-latest;
          gnumake = gnumake-musl;
          gnutar = gnutar-latest;
        };

        bzip2 = callPackage ./bzip2 {
          gnumake = gnumake-musl;
          gnutar = gnutar-musl;
          tinycc = tinycc-musl;
        };

        bzip2-static = callPackage ./bzip2/static.nix {
          gcc = gcc-latest;
          gnumake = gnumake-musl;
          gnutar = gnutar-latest;
        };

        coreutils = callPackage ./coreutils { tinycc = tinycc-mes; };

        coreutils-musl = callPackage ./coreutils/musl.nix {
          bash = bash_2_05;
          gnumake = gnumake-musl;
          gnutar = gnutar-musl;
          tinycc = tinycc-musl;
        };

        coreutils-static = callPackage ./coreutils/static.nix {
          gcc = gcc-latest;
          gnumake = gnumake-musl;
          gnutar = gnutar-latest;
        };

        diffutils = callPackage ./diffutils {
          bash = bash_2_05;
          gnumake = gnumake-musl;
          gnutar = gnutar-musl;
          tinycc = tinycc-musl;
        };

        diffutils-static = callPackage ./diffutils/static.nix {
          gcc = gcc-latest;
          gnumake = gnumake-musl;
          gnutar = gnutar-latest;
        };

        findutils = callPackage ./findutils {
          gnumake = gnumake-musl;
          gnutar = gnutar-musl;
          tinycc = tinycc-musl;
        };

        findutils-static = callPackage ./findutils/static.nix {
          gcc = gcc-latest;
          gnumake = gnumake-musl;
          gnutar = gnutar-latest;
        };

        gawk = callPackage ./gawk {
          bash = bash_2_05;
          bootGawk = gawk-mes;
          gnumake = gnumake-musl;
          gnutar = gnutar-musl;
          tinycc = tinycc-musl;
        };

        gawk-mes = callPackage ./gawk/mes.nix {
          bash = bash_2_05;
          gnused = gnused-mes;
          tinycc = tinycc-mes;
        };

        gawk-static = callPackage ./gawk/static.nix {
          gcc = gcc-latest;
          gnumake = gnumake-musl;
          gnutar = gnutar-latest;
        };

        gcc-latest = callPackage ./gcc/latest.nix {
          gcc = gcc10;
          gnumake = gnumake-musl;
          gnutar = gnutar-latest;
        };

        gcc10 = callPackage ./gcc/10.nix {
          gcc = gcc46-cxx;
          gnumake = gnumake-musl;
          gnutar = gnutar-latest;
        };

        gcc46 = callPackage ./gcc/4.6.nix {
          gnumake = gnumake-musl;
          gnutar = gnutar-musl;
          tinycc = tinycc-musl;
        };

        gcc46-cxx = callPackage ./gcc/4.6.cxx.nix {
          gcc = gcc46;
          gnumake = gnumake-musl;
          gnutar = gnutar-musl;
        };

        gnugrep = callPackage ./gnugrep {
          bash = bash_2_05;
          tinycc = tinycc-mes;
        };

        gnugrep-static = callPackage ./gnugrep/static.nix {
          gcc = gcc-latest;
          gnumake = gnumake-musl;
          gnutar = gnutar-latest;
        };

        gnum4 = callPackage ./gnum4 {
          gcc = gcc-latest;
          gnumake = gnumake-musl;
          gnutar = gnutar-latest;
        };

        gnumake = callPackage ./gnumake { tinycc = tinycc-bootstrappable; };

        gnumake-musl = callPackage ./gnumake/musl.nix {
          bash = bash_2_05;
          gawk = gawk-mes;
          gnumakeBoot = gnumake;
          # GNU Make's release tarball relies on preserved mtimes for
          # pregenerated Autotools files.
          gnutar = gnutar-musl;
          tinycc = tinycc-musl;
        };

        gnumake-static = callPackage ./gnumake/static.nix {
          gcc = gcc-latest;
          gnumake = gnumake-musl;
          gnutar = gnutar-latest;
        };

        gnupatch = callPackage ./gnupatch { tinycc = tinycc-mes; };

        gnupatch-static = callPackage ./gnupatch/static.nix {
          gcc = gcc-latest;
          gnumake = gnumake-musl;
          gnutar = gnutar-latest;
        };

        gnused = callPackage ./gnused {
          bash = bash_2_05;
          gnused = gnused-mes;
          tinycc = tinycc-musl;
        };

        gnused-mes = callPackage ./gnused/mes.nix {
          bash = bash_2_05;
          tinycc = tinycc-bootstrappable;
        };

        gnused-static = callPackage ./gnused/static.nix {
          gcc = gcc-latest;
          gnumake = gnumake-musl;
          gnutar = gnutar-latest;
        };

        gnutar = callPackage ./gnutar/mes.nix {
          bash = bash_2_05;
          gnused = gnused-mes;
          tinycc = tinycc-mes;
        };

        # FIXME: better package naming scheme
        gnutar-latest = callPackage ./gnutar/latest.nix {
          gcc = gcc46;
          gnumake = gnumake-musl;
          gnutarBoot = gnutar-musl;
        };

        gnutar-musl = callPackage ./gnutar/musl.nix {
          bash = bash_2_05;
          gnused = gnused-mes;
          tinycc = tinycc-musl;
        };

        gnutar-static = callPackage ./gnutar/static.nix {
          gcc = gcc-latest;
          gnumake = gnumake-musl;
          gnutarBoot = gnutar-latest;
        };

        gzip = callPackage ./gzip {
          bash = bash_2_05;
          gnused = gnused-mes;
          tinycc = tinycc-bootstrappable;
        };

        gzip-static = callPackage ./gzip/static.nix {
          gcc = gcc-latest;
          gnumake = gnumake-musl;
          gnutar = gnutar-latest;
        };

        heirloom = callPackage ./heirloom {
          bash = bash_2_05;
          tinycc = tinycc-mes;
        };

        heirloom-devtools = callPackage ./heirloom-devtools { tinycc = tinycc-mes; };

        linux-headers = callPackage ./linux-headers {
          gcc = gcc-latest;
          gnumake = gnumake-musl;
          gnutar = gnutar-latest;
        };

        ln-boot = callPackage ./ln-boot { };
        mes = callPackage ./mes { };
        mes-libc = callPackage ./mes/libc.nix { };

        musl = callPackage ./musl {
          gcc = gcc46;
          gnumake = gnumake-musl;
        };

        musl-static = callPackage ./musl/static.nix {
          gcc = gcc-latest;
          gnumake = gnumake-musl;
        };

        musl-tcc = callPackage ./musl/tcc.nix {
          bash = bash_2_05;
          gnused = gnused-mes;
          tinycc = tinycc-musl-intermediate;
        };

        musl-tcc-intermediate = callPackage ./musl/tcc.nix {
          bash = bash_2_05;
          gnused = gnused-mes;
          tinycc = tinycc-mes;
        };

        patchelf-static = callPackage ./patchelf/static.nix {
          gcc = gcc-latest;
          gnumake = gnumake-musl;
          gnutar = gnutar-latest;
        };

        python = callPackage ./python {
          gcc = gcc-latest;
          gnumake = gnumake-musl;
          gnutar = gnutar-latest;
        };

        stage0-posix = callPackage ./stage0-posix { };

        supportedSystems = [
          "i686-linux"
          "x86_64-linux"
        ];

        test = tests.full;

        tests = {
          bootstrap-chain = kaem.runCommand "minimal-bootstrap-bootstrap-chain-test" { } ''
            echo ${bash.tests.get-version}
            echo ${bash_2_05.tests.get-version}
            echo ${binutils.tests.get-version}
            echo ${bison.tests.get-version}
            echo ${bzip2.tests.get-version}
            echo ${coreutils-musl.tests.get-version}
            echo ${diffutils.tests.get-version}
            echo ${findutils.tests.get-version}
            echo ${gawk.tests.get-version}
            echo ${gawk-mes.tests.get-version}
            echo ${gnugrep.tests.get-version}
            echo ${gnum4.tests.get-version}
            echo ${gnumake-musl.tests.get-version}
            echo ${gnused.tests.get-version}
            echo ${gnused-mes.tests.get-version}
            echo ${gnutar.tests.get-version}
            echo ${gnutar-latest.tests.get-version}
            echo ${gnutar-musl.tests.get-version}
            echo ${gzip.tests.get-version}
            echo ${heirloom.tests.get-version}
            echo ${mes.compiler.tests.get-version}
            echo ${musl.tests.hello-world}
            echo ${python.tests.get-version}
            echo ${tinycc-mes.compiler.tests.chain}
            echo ${tinycc-musl.compiler.tests.hello-world}
            echo ${xz.tests.get-version}
            mkdir ''${out}
          '';

          compiler = kaem.runCommand "minimal-bootstrap-compiler-test" { } (
            ''
              echo ${gcc46.tests.get-version}
              echo ${gcc46-cxx.tests.hello-world}
              echo ${gcc10.tests.hello-world}
              echo ${gcc-latest.tests.hello-world}
            ''
            + (lib.strings.optionalString (hostPlatform.libc == "glibc") ''
              echo ${gcc-glibc.tests.hello-world}
              echo ${glibc.tests.hello-world}
            '')
            + ''
              mkdir ''${out}
            ''
          );

          full = kaem.runCommand "minimal-bootstrap-test" { } ''
            echo ${tests.bootstrap-chain}
            echo ${tests.static-tools}
            echo ${tests.compiler}
            mkdir ''${out}
          '';

          static-tools = kaem.runCommand "minimal-bootstrap-static-tools-test" { } ''
            echo ${bash-static.tests.get-version}
            echo ${binutils-static.tests.get-version}
            echo ${bzip2-static.tests.get-version}
            echo ${bzip2-static.tests.compress}
            echo ${coreutils-static.tests.get-version}
            echo ${diffutils-static.tests.get-version}
            echo ${findutils-static.tests.get-version}
            echo ${gawk-static.tests.get-version}
            echo ${gnugrep-static.tests.get-version}
            echo ${gnumake-static.tests.get-version}
            echo ${gnupatch-static.tests.get-version}
            echo ${gnused-static.tests.get-version}
            echo ${gnutar-static.tests.get-version}
            echo ${gzip-static.tests.get-version}
            echo ${patchelf-static.tests.get-version}
            echo ${xz-static.tests.get-version}
            mkdir ''${out}
          '';
        };

        tinycc-bootstrappable = lib.recurseIntoAttrs (callPackage ./tinycc/bootstrappable.nix { });
        tinycc-mes = lib.recurseIntoAttrs (callPackage ./tinycc/mes.nix { });

        tinycc-musl = lib.recurseIntoAttrs (
          callPackage ./tinycc/musl.nix {
            bash = bash_2_05;
            musl = musl-tcc;
            tinycc = tinycc-musl-intermediate;
          }
        );

        tinycc-musl-intermediate = lib.recurseIntoAttrs (
          callPackage ./tinycc/musl.nix {
            bash = bash_2_05;
            musl = musl-tcc-intermediate;
            tinycc = tinycc-mes;
          }
        );

        xz = callPackage ./xz {
          bash = bash_2_05;
          gnumake = gnumake-musl;
          gnutar = gnutar-musl;
          tinycc = tinycc-musl;
        };

        xz-static = callPackage ./xz/static.nix {
          gcc = gcc-latest;
          gnumake = gnumake-musl;
          gnutar = gnutar-latest;
        };

        zlib = callPackage ./zlib {
          gcc = gcc-latest;
          gnumake = gnumake-musl;
          gnutar = gnutar-latest;
        };
      }
      // (lib.optionalAttrs (hostPlatform.libc == "glibc")) {
        gcc-glibc = callPackage ./gcc/glibc.nix {
          gcc = gcc-latest;
          gnumake = gnumake-musl;
          gnutar = gnutar-latest;
        };

        glibc = callPackage ./glibc {
          gcc = gcc-latest;
          gnugrep = gnugrep-static;
          gnumake = gnumake-musl;
          gnutar = gnutar-latest;
        };
      }
    )
  )
