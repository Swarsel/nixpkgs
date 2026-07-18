{
  lib,
  stdenv,
  # known consumers
  aaxtomp3,
  arch-install-scripts,
  bash,
  bashup-events32,
  bats,
  bc,
  binlore,
  callPackage,
  coreutils,
  dgoss,
  # override testing
  esh,
  file,
  findutils,
  gawk,
  getconf,
  gettext,
  git-ftp,
  gnugrep,
  gnused,
  gnutar,
  jq,
  lesspipe,
  libarchive,
  libressl,
  locale,
  locate-dominating-file,
  mons,
  mount,
  msmtp,
  ncurses,
  nix-direnv,
  nixos-install-tools,
  openssl,
  pdf2odt,
  pdfmm,
  procps,
  ps,
  rSrc,
  resholve,
  rlwrap,
  s0ix-selftest-tool,
  shunit2,
  sqlite,
  systemd,
  unix-privesc-check,
  unixtools,
  wgnord,
  wsl-vpnkit,
  xdg-utils,
  yadm,
  zxfer,
  runDemo ? false,
}:

let
  default_packages = [
    bash
    file
    findutils
    gettext
  ];
  parsed_packages = [
    coreutils
    sqlite
    unixtools.script
    gnused
    gawk
    findutils
    rlwrap
    gnutar
    bc
    msmtp
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    systemd
  ];
in
rec {
  # ensure known consumers in nixpkgs keep working
  inherit aaxtomp3;
  inherit bashup-events32;
  inherit bats;
  inherit git-ftp;
  inherit lesspipe;
  inherit locate-dominating-file;
  inherit mons;
  inherit msmtp;
  inherit nix-direnv;
  inherit pdf2odt;
  # TODO: re-enable when safe; disabled may 9 2026 due
  # to build failure down in pdfmm > zenity > appstream
  # inherit pdfmm;
  inherit shunit2;
  inherit xdg-utils;
  inherit yadm;

  cli = stdenv.mkDerivation {
    src = rSrc;
    buildInputs = [ resholve ];
    doCheck = true;

    nativeCheckInputs = [
      coreutils
      bats
    ];

    checkPhase = ''
      echo removing parse tests matching no${stdenv.buildPlatform.uname.system}
      rm tests/parse_*no${stdenv.buildPlatform.uname.system}.sh || true # ok if none exist
      patchShebangs .
      mkdir empty_lore
      touch empty_lore/{execers,wrappers}
      export EMPTY_LORE=$PWD/empty_lore
      printf "\033[33m============================= resholve test suite ===================================\033[0m\n" > test.ansi
      if ./test.sh &>> test.ansi; then
        cat test.ansi
      else
        cat test.ansi && exit 1
      fi
    ''
    + lib.optionalString runDemo ''
      printf "\033[33m============================= resholve demo ===================================\033[0m\n" > demo.ansi
      if ./demo &>> demo.ansi; then
        cat demo.ansi
      else
        cat demo.ansi && exit 1
      fi
    '';

    installPhase = ''
      mkdir $out
      cp *.ansi $out/
    '';

    # explicit interpreter for demo suite; maybe some better way...
    INTERP = "${bash}/bin/bash";
    PKG_COREUTILS = "${lib.makeBinPath [ coreutils ]}";
    # but separate packages for combining as needed
    PKG_FILE = "${lib.makeBinPath [ file ]}";
    PKG_FINDUTILS = "${lib.makeBinPath [ findutils ]}";
    PKG_GETTEXT = "${lib.makeBinPath [ gettext ]}";
    PKG_PARSED = "${lib.makeBinPath parsed_packages}";

    RESHOLVE_LORE = "${binlore.collect {
      drvs = default_packages ++ [ coreutils ] ++ parsed_packages;
    }}";

    # LOGLEVEL="DEBUG";
    # default path
    RESHOLVE_PATH = "${lib.makeBinPath default_packages}";
    dontBuild = true;
    name = "resholve-test";
  };

  # spot-check lore overrides
  loreOverrides =
    resholve.writeScriptBin "verify-overrides"
      {
        execer = [
          "cannot:${esh}/bin/esh"
        ];

        fix = {
          mount = true;
        };

        inputs = [
          coreutils
          esh
          getconf
          libarchive
          locale
          mount
          ncurses
          procps
          ps
        ]
        ++ lib.optionals stdenv.hostPlatform.isLinux [
          nixos-install-tools
        ];

        interpreter = "none";
      }
      (
        ''
          env b2sum fake args
          b2sum fake args
          esh fake args
          getconf fake args
          bsdtar fake args
          locale fake args
          mount fake args
          reset fake args
          tput fake args
          tset fake args
          ps fake args
          top fake args
        ''
        + lib.optionalString stdenv.hostPlatform.isLinux ''
          nixos-generate-config fake args
        ''
      );

  module1 = resholve.mkDerivation (finalAttrs: {
    pname = "testmod1";
    version = "unreleased";
    src = rSrc;

    installPhase = ''
      mkdir -p $out/{bin,submodule}
      install libressl.sh $out/bin/libressl.sh
      install submodule/helper.sh $out/submodule/helper.sh
    '';

    setSourceRoot = "sourceRoot=$(echo */tests/nix/libressl)";

    solutions = {
      libressl = {
        inputs = [
          jq
          module2
          libressl.bin
        ];

        interpreter = "none";

        # submodule to demonstrate
        scripts = [
          "bin/libressl.sh"
          "submodule/helper.sh"
        ];
      };
    };

    # finalAttrs proof-of-life
    passthru.version = finalAttrs.version;
  });

  module2 = resholve.mkDerivation {
    pname = "testmod2";
    version = "unreleased";
    src = rSrc;

    installPhase = ''
      mkdir -p $out/bin $out/libexec
      install openssl.sh $out/bin/openssl.sh
      install libexec.sh $out/libexec/invokeme
      install profile $out/profile
    '';

    postResholve = ''
      echo "not a load-bearing test, just prove we exist"
    '';

    setSourceRoot = "sourceRoot=$(echo */tests/nix/openssl)";

    # LOGLEVEL="DEBUG";
    solutions = {
      openssl = {
        execer = [
          /*
            This is the same verdict binlore will
            come up with. It's a no-op just to demo
            how to fiddle lore via the Nix API.
          */
          "cannot:${openssl.bin}/bin/openssl"
          # different verdict, but not used
          "can:${openssl.bin}/bin/c_rehash"
        ];

        fix = {
          aliases = true;
        };

        inputs = [
          shunit2
          openssl.bin
          "libexec"
          "libexec/invokeme"
        ];

        interpreter = "none";

        scripts = [
          "bin/openssl.sh"
          "libexec/invokeme"
        ];
      };

      profile = {
        inputs = [ ];
        interpreter = "none";
        scripts = [ "profile" ];
      };
    };
  };

  # demonstrate that we could use resholve in larger build
  module3 = stdenv.mkDerivation {
    pname = "testmod3";
    version = "unreleased";
    src = rSrc;

    installPhase = ''
      mkdir -p $out/bin
      install conjure.sh $out/bin/conjure.sh
      ${resholve.phraseSolution "conjure" {
        fake = {
          external = [
            "jq"
            "openssl"
          ];
        };

        inputs = [ module1 ];
        interpreter = "${bash}/bin/bash";
        scripts = [ "bin/conjure.sh" ];
      }}
    '';

    setSourceRoot = "sourceRoot=$(echo */tests/nix/future_perfect_tense)";
  };

  # Caution: ci.nix asserts the equality of both of these w/ diff
  resholvedScript =
    resholve.writeScript "resholved-script"
      {
        inputs = [ file ];
        interpreter = "${bash}/bin/bash";
      }
      ''
        echo "Hello"
        file .
      '';

  resholvedScriptBin =
    resholve.writeScriptBin "resholved-script-bin"
      {
        inputs = [ file ];
        interpreter = "${bash}/bin/bash";
      }
      ''
        echo "Hello"
        file .
      '';

  resholvedScriptBinNone =
    resholve.writeScriptBin "resholved-script-bin"
      {
        inputs = [ file ];
        interpreter = "none";
      }
      ''
        echo "Hello"
        file .
      '';
}
// lib.optionalAttrs stdenv.hostPlatform.isLinux {
  inherit arch-install-scripts;
  inherit dgoss;
  inherit unix-privesc-check;
  inherit wgnord;
  inherit wsl-vpnkit;
  inherit zxfer;
}
//
  lib.optionalAttrs
    (stdenv.hostPlatform.isLinux && (stdenv.hostPlatform.isi686 || stdenv.hostPlatform.isx86_64))
    {
      inherit s0ix-selftest-tool;
    }
