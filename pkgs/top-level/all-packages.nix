/*
  The top-level package collection of nixpkgs.
  It is sorted by categories corresponding to the folder names in the /pkgs
  folder. Inside the categories packages are roughly sorted by alphabet, but
  strict sorting has been long lost due to merges. Please use the full-text
  search of your editor. ;)
  Hint: ### starts category names.
*/
{
  lib,
  config,
  noSysDirs,
  overlays,
}:
let
  # Add inherited lib functions only here, so they are not exported from pkgs
  inherit (lib)
    lowPrio
    hiPrio
    recurseIntoAttrs
    dontRecurseIntoAttrs
    makeOverridable
    ;
in

res: pkgs: super:

with pkgs;

{
  ### Helper functions.
  inherit lib config overlays;
  inherit (nix-update) nix-update-script;
  inherit (gridlock) nyarr;

  inherit (dotnetCorePackages)
    buildDotnetModule
    buildDotnetGlobalTool
    mkNugetSource
    mkNugetDeps
    autoPatchcilHook
    ;

  inherit (callPackages ../build-support/node/fetch-yarn-deps { })
    fixup-yarn-lock
    prefetch-yarn-deps
    yarnConfigHook
    yarnBuildHook
    yarnInstallHook
    fetchYarnDeps
    ;

  inherit
    ({
      mysql-shell_8 = callPackage ../development/tools/mysql-shell/8.nix {
        antlr = antlr4_10;
        icu = icu77;

        protobuf = protobuf_25.override {
          abseil-cpp = abseil-cpp_202407;
        };
      };

      mysql-shell_9 = callPackage ../development/tools/mysql-shell/9.nix {
        antlr = antlr4_10;
        icu = icu77;

        protobuf = protobuf_25.override {
          abseil-cpp = abseil-cpp_202407;
        };
      };
    })
    mysql-shell_8
    mysql-shell_9
    ;

  inherit (callPackages ../build-support/setup-hooks/patch-rc-path-hooks { })
    patchRcPathBash
    patchRcPathCsh
    patchRcPathFish
    patchRcPathPosix
    ;

  inherit (lib.systems) platforms;

  # lib functions depending on pkgs
  inherit
    (import ../pkgs-lib {
      # The `lib` variable in this scope doesn't include any applied lib overlays,
      # `pkgs.lib` does.
      inherit (pkgs) lib;
      inherit pkgs;
    })
    formats
    ;

  inherit (recurseIntoAttrs (callPackage ../tools/package-management/akku { }))
    akku
    akkuPackages
    ;

  inherit (callPackages ../tools/networking/iroh/default.nix { })
    iroh-relay
    iroh-dns-server
    ;

  inherit (callPackage ../development/libraries/sdbus-cpp { }) sdbus-cpp sdbus-cpp_2;
  inherit (haskellPackages) git-annex;
  inherit (haskellPackages) git-brunch;

  inherit (callPackages ../development/tools/ammonite { })
    ammonite_2_12
    ammonite_2_13
    ammonite_3_3
    ;

  inherit (callPackages ../tools/security/bitwarden-directory-connector { })
    bitwarden-directory-connector-cli
    bitwarden-directory-connector
    ;

  inherit (buildbotPackages)
    buildbot
    buildbot-ui
    buildbot-full
    buildbot-plugins
    buildbot-worker
    ;

  inherit (cue) writeCueValidator;

  inherit (callPackages ../misc/logging/beats/7.x.nix { })
    auditbeat7
    filebeat7
    heartbeat7
    metricbeat7
    packetbeat7
    ;

  inherit (callPackages ../applications/networking/charles { })
    charles3
    charles4
    charles5
    ;

  inherit (callPackages ../tools/misc/coreboot-utils { })
    msrtool
    cbmem
    ifdtool
    intelmetool
    cbfstool
    nvramtool
    superiotool
    ectool
    inteltool
    amdfwtool
    acpidump-all
    intelp2m
    coreboot-utils
    ;

  inherit (ocamlPackages) dot-merlin-reader;
  inherit (ocamlPackages) dune-release;

  inherit (texlive.schemes)
    texliveBasic
    texliveBookPub
    texliveConTeXt
    texliveFull
    texliveGUST
    texliveInfraOnly
    texliveMedium
    texliveMinimal
    texliveSmall
    texliveTeTeX
    ;

  inherit (go-containerregistry) crane gcrane;
  inherit (ocamlPackages) patdiff;

  inherit (callPackages ../servers/rainloop { })
    rainloop-community
    rainloop-standard
    ;

  inherit (import ../development/libraries/libsbsms pkgs)
    libsbsms
    libsbsms_2_0_2
    libsbsms_2_3_0
    ;

  inherit
    (import ./cuda-packages.nix {
      inherit
        _cuda
        callPackage
        config
        lib
        ;
    })
    cudaPackages_12_6
    cudaPackages_12_8
    cudaPackages_12_9
    cudaPackages_13_0
    cudaPackages_13_1
    cudaPackages_13_2
    cudaPackages_13_3
    ;

  inherit (callPackages ../applications/networking/p2p/deluge { })
    deluge-gtk
    deluged
    deluge
    ;

  inherit (import ../build-support/dlang/dub-support.nix { inherit lib callPackage; })
    dub-to-nix
    importDubLock
    buildDubPackage
    dubSetupHook
    dubBuildHook
    dubCheckHook
    ;

  inherit (callPackages ../by-name/tr/tracy/package-versions.nix { })
    tracy_0_11
    tracy_0_12
    tracy_0_13
    ;

  inherit (callPackages ../tools/filesystems/garage { })
    garage
    garage_1
    garage_2
    ;

  inherit (callPackage ../development/tools/godot { })
    godot3
    godot3-export-templates
    godot3-headless
    godot3-debug-server
    godot3-server
    godot3-mono
    godot3-mono-export-templates
    godot3-mono-headless
    godot3-mono-debug-server
    godot3-mono-server
    godotPackages_4_3
    godotPackages_4_4
    godotPackages_4_5
    godotPackages_4_6
    godotPackages_4_7
    godotPackages_4
    godotPackages
    godot_4_3
    godot_4_3-mono
    godot_4_3-export-templates-bin
    godot_4_4
    godot_4_4-mono
    godot_4_4-export-templates-bin
    godot_4_5
    godot_4_5-mono
    godot_4_5-export-templates-bin
    godot_4_6
    godot_4_6-mono
    godot_4_6-export-templates-bin
    godot_4_7
    godot_4_7-mono
    godot_4_7-export-templates-bin
    godot_4
    godot_4-mono
    godot_4-export-templates-bin
    godot
    godot-mono
    godot-export-templates-bin
    ;

  inherit
    ({
      graylog-6_1 = callPackage ../tools/misc/graylog/6.1.nix { };
    })
    graylog-6_1
    ;

  inherit
    (rec {
      isl = isl_0_20;
      isl_0_20 = callPackage ../development/libraries/isl/0.20.0.nix { };
      isl_0_23 = callPackage ../development/libraries/isl/0.23.0.nix { };
      isl_0_27 = callPackage ../development/libraries/isl/0.27.0.nix { };
    })
    isl
    isl_0_20
    isl_0_23
    isl_0_27
    ;

  inherit (callPackages ../build-support/node/prefetch-npm-deps { })
    fetchNpmDeps
    prefetch-npm-deps
    ;

  inherit (callPackage ../development/tools/lerna { })
    lerna_6
    lerna_8
    ;

  inherit (callPackages ../servers/nextcloud { })
    nextcloud32
    nextcloud33
    nextcloud34
    ;

  inherit (callPackages ../applications/networking/cluster/nomad { })
    nomad
    nomad_1_9
    nomad_1_10
    nomad_1_11
    ;

  inherit (import ../servers/sql/percona-server pkgs)
    percona-server_8_4
    percona-server
    ;

  inherit (import ../tools/backup/percona-xtrabackup pkgs)
    percona-xtrabackup_8_4
    percona-xtrabackup
    ;

  inherit (callPackages ../tools/security/pinentry { })
    pinentry-curses
    pinentry-emacs
    pinentry-gtk2
    pinentry-gnome3
    pinentry-qt
    pinentry-tty
    pinentry-all
    ;

  inherit (callPackage ../development/tools/pnpm { })
    pnpm_9
    pnpm_10_29_2
    pnpm_10_34_0
    pnpm_10
    pnpm_11
    ;

  inherit (callPackages ../build-support/node/fetch-pnpm-deps { })
    fetchPnpmDeps
    pnpmConfigHook
    ;

  inherit (callPackage ../tools/security/rekor { })
    rekor-cli
    rekor-server
    ;

  inherit (callPackage ../development/misc/resholve { })
    resholve
    ;

  inherit (semgrep.passthru) semgrep-core;

  inherit (callPackages ../tools/misc/sshx { })
    sshx
    sshx-server
    ;

  inherit (callPackages ../servers/varnish { })
    varnish80
    ;

  inherit (callPackages ../servers/varnish/packages.nix { })
    varnish80Packages
    ;

  inherit (callPackages ../servers/vinyl-cache { })
    vinyl-cache_9
    ;

  inherit (chickenPackages_5)
    fetchegg
    eggDerivation
    chicken
    egg2nix
    ;

  inherit (coqPackages_9_0) compcert;

  inherit (callPackage ../development/compilers/crystal { })
    crystal_1_14
    crystal_1_15
    crystal_1_16
    crystal_1_17
    crystal_1_18
    crystal_1_19
    crystal
    ;

  inherit
    (rec {
      # NOTE: keep this with the "NG" label until we're ready to drop the monolithic GCC
      gccNGPackagesSet = recurseIntoAttrs (callPackages ../development/compilers/gcc/ng { });
      gccNGPackages_15 = gccNGPackagesSet."15";
      mkGCCNGPackages = gccNGPackagesSet.mkPackage;
    })
    gccNGPackages_15
    mkGCCNGPackages
    ;

  inherit (callPackage ../development/compilers/gcc/all.nix { inherit noSysDirs; })
    gcc13
    gcc14
    gcc15
    gcc16
    ;

  inherit (gnatPackages)
    gprbuild
    gnatprove
    ;

  inherit
    (callPackage ../development/compilers/haxe {
    })
    haxe_4_3
    ;

  inherit (haxePackages) hxcpp;

  inherit (callPackage ../development/tools/database/indradb { })
    indradb-server
    indradb-client
    ;

  inherit
    ({
      jre11_minimal = callPackage ../development/compilers/openjdk/jre.nix {
        jdk = jdk11;
        jdkOnBuild = buildPackages.jdk11;
      };

      jre17_minimal = callPackage ../development/compilers/openjdk/jre.nix {
        jdk = jdk17;
        jdkOnBuild = buildPackages.jdk17;
      };

      jre21_minimal = callPackage ../development/compilers/openjdk/jre.nix {
        jdk = jdk21;
        jdkOnBuild = buildPackages.jdk21;
      };

      jre25_minimal = callPackage ../development/compilers/openjdk/jre.nix {
        jdk = jdk25;
        jdkOnBuild = buildPackages.jdk25;
      };

      jre_minimal = callPackage ../development/compilers/openjdk/jre.nix {
        jdkOnBuild = buildPackages.jdk;
      };
    })
    jre11_minimal
    jre17_minimal
    jre21_minimal
    jre25_minimal
    jre_minimal
    ;

  inherit (callPackage ../development/compilers/julia { })
    julia_110-bin
    julia_111-bin
    julia_112-bin
    julia_110
    julia_111
    julia_112
    ;

  inherit
    (rec {
      llvmPackagesSet = recurseIntoAttrs (callPackages ../development/compilers/llvm { });
      llvmPackages_18 = llvmPackagesSet."18";
      llvmPackages_19 = llvmPackagesSet."19";
      llvmPackages_20 = llvmPackagesSet."20";
      llvmPackages_21 = llvmPackagesSet."21";
      llvmPackages_22 = llvmPackagesSet."22";
      mkLLVMPackages = llvmPackagesSet.mkPackage;
    })
    llvmPackages_18
    llvmPackages_19
    llvmPackages_20
    llvmPackages_21
    llvmPackages_22
    mkLLVMPackages
    ;

  inherit (callPackage ../development/compilers/mlton { })
    mlton20130715
    mlton20180207Binary
    mlton20180207
    mlton20210117Binary
    mlton20210117
    mlton20241230Binary
    mlton20241230
    mltonHEAD
    ;

  inherit (ocaml-ng.ocamlPackages_4_14)
    ocamlformat_0_19_0
    ocamlformat_0_20_0
    ocamlformat_0_20_1
    ocamlformat_0_21_0
    ocamlformat_0_22_4
    ocamlformat_0_23_0
    ocamlformat_0_24_1
    ocamlformat_0_25_1
    ocamlformat_0_26_0
    ocamlformat_0_26_1
    ;

  inherit (ocaml-ng.ocamlPackages_5_2)
    ocamlformat_0_26_2
    ;

  inherit (ocaml-ng.ocamlPackages_5_3)
    ocamlformat_0_27_0
    ;

  inherit (ocamlPackages)
    ocamlformat # latest version
    ocamlformat_0_28_1
    ocamlformat_0_29_0
    ;

  inherit (ocamlPackages) odig;

  inherit (rustPackages)
    cargo
    cargo-auditable-cargo-wrapper
    clippy
    rustc
    rustc-unwrapped
    rustPlatform
    ;

  inherit (callPackages ../development/tools/rust/cargo-pgrx { })
    cargo-pgrx_0_16_0
    cargo-pgrx_0_16_1
    cargo-pgrx_0_17_0
    cargo-pgrx_0_18_0
    cargo-pgrx
    ;

  inherit (swiftPackages)
    swift
    swiftpm
    sourcekit-lsp
    swift-format
    swiftpm2nix
    ;

  inherit (callPackage ../development/compilers/vala { })
    vala_0_56
    vala
    ;

  inherit
    ({
      zulu11 = callPackage ../development/compilers/zulu/11.nix { };
      zulu17 = callPackage ../development/compilers/zulu/17.nix { };
      zulu21 = callPackage ../development/compilers/zulu/21.nix { };
      zulu25 = callPackage ../development/compilers/zulu/25.nix { };
      zulu8 = callPackage ../development/compilers/zulu/8.nix { };
    })
    zulu8
    zulu11
    zulu17
    zulu21
    zulu25
    ;

  inherit (callPackage ../applications/editors/jupyter-kernels/xeus-cpp { })
    cpp11-kernel
    cpp14-kernel
    cpp17-kernel
    cpp20-kernel
    cpp23-kernel
    xeus-cpp
    ;

  inherit (beamPackages)
    elixir-ls
    erlfmt
    elvis-erlang
    rebar
    rebar3
    rebar3WithPlugins
    fetchHex
    ;

  inherit (callPackages ../applications/networking/cluster/hadoop { })
    hadoop_3_4
    hadoop_3_3
    hadoop2
    ;

  inherit (emiluaPlugins) emilua;

  inherit (luaInterpreters)
    lua5_1
    lua5_2
    lua5_2_compat
    lua5_3
    lua5_3_compat
    lua5_4
    lua5_4_compat
    lua5_5
    lua5_5_compat
    luajit_2_1
    luajit_2_0
    luajit_openresty
    ;

  # Import PHP interpreters
  inherit (callPackage ./../development/interpreters/php { })
    php82
    php83
    php84
    php85
    ;

  inherit (pythonInterpreters)
    python311
    python312
    python313
    python314
    python315
    python3Minimal
    pypy27
    pypy310
    pypy311
    ;

  inherit (ocamlPackages) reason rtop;

  inherit
    (callPackage ../development/interpreters/ruby {
      inherit (darwin) libunwind;
    })
    mkRubyVersion
    mkRuby
    ruby_3_3
    ruby_3_4
    ruby_4_0
    ;

  inherit (callPackages ../applications/networking/cluster/spark { })
    spark_4_0
    spark_3_5
    spark_3_4
    ;

  inherit
    ({
      spidermonkey_115 = callPackage ../development/interpreters/spidermonkey/115.nix { };
      spidermonkey_128 = callPackage ../development/interpreters/spidermonkey/128.nix { };
      spidermonkey_140 = callPackage ../development/interpreters/spidermonkey/140.nix { };
    })
    spidermonkey_115
    spidermonkey_128
    spidermonkey_140
    ;

  ### DEVELOPMENT / MISC
  inherit (callPackages ../development/misc/h3 { }) h3_3 h3_4;

  ### DEVELOPMENT / TOOLS
  inherit (callPackage ../development/tools/alloy { })
    alloy5
    alloy6
    alloy
    ;

  ### DEVELOPMENT / TOOLS / LANGUAGE-SERVERS
  inherit (callPackages ../development/tools/language-servers/nixd { }) nixf nixt nixd;

  inherit (callPackages ../development/tools/parsing/antlr/4.nix { })
    antlr4_9
    antlr4_10
    antlr4_11
    antlr4_12
    antlr4_13
    ;

  inherit (callPackages ../servers/apache-kafka { })
    apacheKafka_4_1
    apacheKafka_4_2
    apacheKafka_4_3
    ;

  inherit (callPackages ../development/tools/electron/binary { })
    electron_39-bin
    electron_40-bin
    electron_41-bin
    electron_42-bin
    ;

  inherit (callPackages ../development/tools/electron/chromedriver { })
    electron-chromedriver_39
    electron-chromedriver_40
    electron-chromedriver_41
    electron-chromedriver_42
    ;

  inherit
    (
      let
        # On Linux, we use source electron package. On Darwin, we use binary. Hydra
        # and other infra uses Linux package .meta.platforms to determine supported
        # platforms. It means that Hydra won't cache podman-desktop and other
        # electron-based apps on Darwin. This helper will force Linux package .meta
        # to list darwin.
        getElectronPkg =
          { bin, src }:
          (if lib.meta.availableOn stdenv.hostPlatform src then src else bin).overrideAttrs (old: {
            meta = old.meta // {
              platforms = lib.lists.unique (src.meta.platforms ++ bin.meta.platforms);
            };
          });
      in
      {
        electron_39 = electron_39-bin;
        electron_40 = electron_40-bin;

        electron_41 = getElectronPkg {
          src = electron-source.electron_41;
          bin = electron_41-bin;
        };

        electron_42 = getElectronPkg {
          src = electron-source.electron_42;
          bin = electron_42-bin;
        };
      }
    )
    electron_39
    electron_40
    electron_41
    electron_42
    ;

  inherit (callPackage ../applications/misc/inochi2d { })
    inochi-creator
    inochi-session
    ;

  inherit (maven) buildMaven;

  inherit (callPackage ../misc/optee-os { })
    buildOptee
    opteeQemuArm
    opteeQemuAarch64
    ;

  inherit (callPackages ../development/tools/parsing/ragel { }) ragelStable ragelDev;
  inherit (regclient) regbot regctl regsync;

  inherit (callPackage ../development/tools/replay-io { })
    replay-io
    replay-node-cli
    ;

  inherit (texinfoPackages)
    texinfo7
    ;

  inherit (callPackages ../development/libraries/bashup-events { }) bashup-events32 bashup-events44;

  inherit (callPackage ../development/libraries/boost { inherit (buildPackages) boost-build; })
    boost178
    boost179
    boost180
    boost181
    boost182
    boost183
    boost186
    boost187
    boost188
    boost189
    boost190
    boost191
    ;

  inherit (cosmopolitan) cosmocc;

  inherit (callPackage ../development/libraries/ffmpeg { })
    ffmpeg_4
    ffmpeg_4-headless
    ffmpeg_4-full
    ffmpeg_6
    ffmpeg_6-headless
    ffmpeg_6-full
    ffmpeg_7
    ffmpeg_7-headless
    ffmpeg_7-full
    ffmpeg_8
    ffmpeg_8-headless
    ffmpeg_8-full
    ffmpeg
    ffmpeg-headless
    ffmpeg-full
    ;

  inherit (callPackages ../development/libraries/fmt { })
    fmt_9
    fmt_10
    fmt_11
    fmt_12
    ;

  inherit (icu-versions)
    icu60
    icu63
    icu64
    icu66
    icu67
    icu70
    icu71
    icu72
    icu73
    icu74
    icu75
    icu76
    icu77
    icu78
    ;

  inherit (callPackage ../development/libraries/libliftoff { }) libliftoff_0_4 libliftoff_0_5;

  inherit
    ({
      libmicrohttpd_0_9_77 = callPackage ../development/libraries/libmicrohttpd/0.9.77.nix { };
      libmicrohttpd_1_0 = callPackage ../development/libraries/libmicrohttpd/1.0.nix { };
    })
    libmicrohttpd_0_9_77
    libmicrohttpd_1_0
    ;

  inherit
    (callPackages ../development/libraries/prometheus-client-c {
      stdenv = gccStdenv; # Required for darwin
    })
    libprom
    ;

  inherit (callPackage ../development/libraries/libxml2 { })
    libxml2_13
    libxml2
    ;

  inherit
    ({
      mbedtls_4 = callPackage ../by-name/mb/mbedtls/4.nix { };
    })
    mbedtls_4
    ;

  inherit (nvidiaCtkPackages)
    nvidia-docker
    ;

  inherit (callPackages ../development/libraries/ogre { })
    ogre_13
    ogre_14
    ;

  inherit (callPackages ../by-name/li/libressl { })
    libressl_4_2
    libressl_4_3
    ;

  inherit (callPackages ../development/libraries/openssl { })
    openssl_1_1
    openssl_3
    openssl_3_5
    openssl_3_6
    openssl_4_0
    ;

  inherit
    (callPackage ../development/libraries/physfs {
    })
    physfs_2
    physfs
    ;

  inherit
    ({
      protobuf_21 = callPackage ../development/libraries/protobuf/21.nix {
        abseil-cpp = abseil-cpp_202103;
      };

      protobuf_25 = callPackage ../development/libraries/protobuf/25.nix { };

      protobuf_27 = callPackage ../development/libraries/protobuf/27.nix {
        # More recent versions of abseil seem to be missing absl::if_constexpr
        abseil-cpp = abseil-cpp_202407;
      };

      protobuf_29 = callPackage ../development/libraries/protobuf/29.nix {
        # More recent versions of abseil seem to be missing absl::if_constexpr
        abseil-cpp = abseil-cpp_202407;
      };

      protobuf_30 = callPackage ../development/libraries/protobuf/30.nix { };
      protobuf_31 = callPackage ../development/libraries/protobuf/31.nix { };
      protobuf_32 = callPackage ../development/libraries/protobuf/32.nix { };
      protobuf_33 = callPackage ../development/libraries/protobuf/33.nix { };
      protobuf_34 = callPackage ../development/libraries/protobuf/34.nix { };
      protobuf_35 = callPackage ../development/libraries/protobuf/35.nix { };
    })
    protobuf_35
    protobuf_34
    protobuf_33
    protobuf_32
    protobuf_31
    protobuf_30
    protobuf_29
    protobuf_27
    protobuf_25
    protobuf_21
    ;

  inherit (skawarePackages)
    execline
    execline-man-pages
    mdevd
    nsss
    s6
    s6-dns
    s6-linux-init
    s6-linux-utils
    s6-man-pages
    s6-networking
    s6-networking-man-pages
    s6-portable-utils
    s6-portable-utils-man-pages
    s6-rc
    s6-rc-man-pages
    sdnotify-wrapper
    skalibs
    skalibs_2_10
    tipidee
    utmps
    ;

  inherit (python3Packages) sphinxHook;

  inherit
    (callPackage ../development/libraries/sqlite/tools.nix {
    })
    sqlite-analyzer
    sqldiff
    sqlite-rsync
    ;

  inherit (callPackage ../development/libraries/vtk { }) vtk_9_5 vtk_9_6;

  inherit (libsForQt5.callPackage ../development/libraries/wt { })
    wt4
    ;

  inherit (callPackages ../development/libraries/xapian { })
    xapian_1_4
    ;

  inherit
    (rec {
      zigPackages = recurseIntoAttrs (callPackage ../development/compilers/zig { });
      zig_0_13 = zigPackages."0.13";
      zig_0_14 = zigPackages."0.14";
      zig_0_15 = zigPackages."0.15";
      zig_0_16 = zigPackages."0.16";
    })
    zigPackages
    zig_0_13
    zig_0_14
    zig_0_15
    zig_0_16
    ;

  inherit (callPackages ../development/tools/zls { })
    zls_0_14
    zls_0_15
    zls_0_16
    ;

  inherit
    (callPackages ../development/libraries/java/saxon {
      jre = jre_headless;
      jre8 = jre8_headless;
    })
    saxon
    saxonb_8_8
    saxonb_9_1
    saxon_9-he
    saxon_11-he
    saxon_12-he
    ;

  inherit ({ go_1_27 = callPackage ../development/compilers/go/1.27.nix { }; }) go_1_27;
  inherit (perlInterpreters) perl5;

  inherit (callPackages ../servers/asterisk { })
    asterisk
    asterisk-stable
    asterisk-lts
    asterisk_20
    asterisk_22
    asterisk_23
    ;

  inherit (callPackages ../servers/firebird { })
    firebird_5
    firebird_4
    firebird_3
    firebird
    ;

  inherit (callPackage ../servers/hbase { })
    hbase_2_4
    hbase_2_5
    hbase_2_6
    hbase_3_0
    ;

  inherit (callPackages ../servers/http/jetty { })
    jetty_11
    jetty_12
    ;

  inherit
    ({
      kanidmWithSecretProvisioning_1_10 = kanidm_1_10.override { enableSecretProvisioning = true; };
      kanidmWithSecretProvisioning_1_8 = kanidm_1_8.override { enableSecretProvisioning = true; };
      kanidmWithSecretProvisioning_1_9 = kanidm_1_9.override { enableSecretProvisioning = true; };

      kanidm_1_10 = callPackage ../servers/kanidm/1_10.nix {
        kanidmWithSecretProvisioning = kanidmWithSecretProvisioning_1_10;
      };

      kanidm_1_8 = callPackage ../servers/kanidm/1_8.nix {
        kanidmWithSecretProvisioning = kanidmWithSecretProvisioning_1_8;
      };

      kanidm_1_9 = callPackage ../servers/kanidm/1_9.nix {
        kanidmWithSecretProvisioning = kanidmWithSecretProvisioning_1_9;
      };
    })
    kanidm_1_8
    kanidm_1_9
    kanidm_1_10
    kanidmWithSecretProvisioning_1_8
    kanidmWithSecretProvisioning_1_9
    kanidmWithSecretProvisioning_1_10
    ;

  inherit (mailmanPackages) mailman mailman-hyperkitty;

  inherit (callPackage ../applications/networking/mullvad { })
    mullvad
    ;

  inherit (import ../servers/sql/mariadb pkgs)
    mariadb_106
    mariadb_1011
    mariadb_114
    mariadb_118
    ;

  inherit (callPackage ../servers/mir { })
    mir
    mir_2_15
    ;

  inherit (import ../servers/sql/postgresql pkgs)
    postgresqlVersions
    postgresqlJitVersions
    libpq
    ;

  inherit (postgresqlVersions)
    postgresql_14
    postgresql_15
    postgresql_16
    postgresql_17
    postgresql_18
    postgresql_19
    ;

  inherit (postgresqlJitVersions)
    postgresql_14_jit
    postgresql_15_jit
    postgresql_16_jit
    postgresql_17_jit
    postgresql_18_jit
    postgresql_19_jit
    ;

  inherit (callPackages ../servers/monitoring/sensu-go { })
    sensu-go-agent
    sensu-go-backend
    sensu-go-cli
    ;

  inherit (callPackages ../servers/http/tomcat { })
    tomcat9
    tomcat10
    tomcat11
    ;

  inherit (arm-trusted-firmware)
    buildArmTrustedFirmware
    armTrustedFirmwareTools
    armTrustedFirmwareAllwinner
    armTrustedFirmwareAllwinnerH616
    armTrustedFirmwareAllwinnerH6
    armTrustedFirmwareQemu
    armTrustedFirmwareRK3328
    armTrustedFirmwareRK3399
    armTrustedFirmwareRK3568
    armTrustedFirmwareRK3588
    armTrustedFirmwareS905
    ;

  inherit (libapparmor.passthru) apparmorRulesFromClosure;

  inherit (callPackages ../os-specific/linux/kernel-headers { inherit (pkgsBuildBuild) elf-header; })
    linuxHeaders
    makeLinuxHeaders
    ;

  inherit (linuxKernel) buildLinux linuxConfig kernelPatches;

  # Upstream U-Boots:
  inherit (callPackage ../misc/uboot { })
    buildUBoot
    ubootTools
    ubootPythonTools
    ubootA20OlinuxinoLime
    ubootA20OlinuxinoLime2EMMC
    ubootBananaPi
    ubootBananaPim2Zero
    ubootBananaPim3
    ubootBananaPim64
    ubootAmx335xEVM
    ubootClearfog
    ubootCM3588NAS
    ubootCubieboard2
    ubootGuruplug
    ubootJetsonTK1
    ubootLibreTechCC
    ubootNanoPCT4
    ubootNanoPCT6
    ubootNanoPiR5S
    ubootNovena
    ubootOdroidC2
    ubootOdroidXU3
    ubootOlimexA64Olinuxino
    ubootOlimexA64Teres1
    ubootOrangePi3
    ubootOrangePi3B
    ubootOrangePi5
    ubootOrangePi5Max
    ubootOrangePi5Plus
    ubootOrangePiPc
    ubootOrangePiZeroPlus2H5
    ubootOrangePiZero
    ubootOrangePiZero2
    ubootOrangePiZero3
    ubootPcduino3Nano
    ubootPine64
    ubootPine64LTS
    ubootPinebook
    ubootPinebookPro
    ubootQemuAarch64
    ubootQemuArm
    ubootQemuRiscv64Smode
    ubootQemuX86
    ubootQemuX86_64
    ubootQuartz64B
    ubootRadxaZero3W
    ubootRaspberryPi
    ubootRaspberryPiAarch64
    ubootRaspberryPi2
    ubootRaspberryPi3_32bit
    ubootRaspberryPi3_64bit
    ubootRaspberryPi4_32bit
    ubootRaspberryPi4_64bit
    ubootRaspberryPiZero
    ubootRock3C
    ubootRock4CPlus
    ubootRock5ModelB
    ubootRock5ModelC
    ubootRock64
    ubootRock64v2
    ubootRockPiE
    ubootRockPi4
    ubootRockPro64
    ubootROCPCRK3399
    ubootSheevaplug
    ubootSopine
    ubootTuringRK1
    ubootUtilite
    ubootVisionFive2
    ubootWandboard
    ;

  inherit
    ({
      zfs_2_3 = callPackage ../os-specific/linux/zfs/2_3.nix {
        configFile = "user";
      };

      zfs_2_4 = callPackage ../os-specific/linux/zfs/2_4.nix {
        configFile = "user";
      };

      zfs_unstable = callPackage ../os-specific/linux/zfs/unstable.nix {
        configFile = "user";
      };
    })
    zfs_2_3
    zfs_2_4
    zfs_unstable
    ;

  inherit (callPackage ../data/sgml+xml/schemas/sgml-dtd/docbook { })
    docbook_sgml_dtd_31
    docbook_sgml_dtd_45
    ;

  inherit (callPackages ../data/sgml+xml/stylesheets/xslt/docbook-xsl { })
    docbook-xsl-nons
    docbook-xsl-ns
    ;

  /**
    A JSON Schema Catalog is a mapping from URIs to JSON Schema documents.

    It enables offline use, e.g. in build processes, and it improves performance, robustness and safety.
  */
  inherit (callPackage ../data/json-schema/default.nix { }) jsonSchemaCatalogs;

  inherit (callPackages ../data/fonts/liberation-fonts { })
    liberation_ttf_v1
    liberation_ttf_v2
    ;

  inherit (callPackages ../data/fonts/gdouros { })
    aegan
    aegyptus
    akkadian
    assyrian
    eemusic
    maya
    symbola
    textfonts
    unidings
    ;

  inherit (callPackages ../data/fonts/pretendard { })
    pretendard
    pretendard-gov
    pretendard-jp
    pretendard-std
    ;

  inherit (callPackage ../data/fonts/source-han { })
    source-han-sans
    source-han-serif
    source-han-mono
    source-han-sans-vf-otf
    source-han-sans-vf-ttf
    source-han-serif-vf-otf
    source-han-serif-vf-ttf
    ;

  inherit (qt6Packages.callPackage ../applications/office/activitywatch { })
    aw-qt
    aw-notify
    aw-server-rust
    aw-watcher-afk
    aw-watcher-window
    ;

  inherit
    ({
      pdfstudio2021 = callPackage ../applications/misc/pdfstudio { year = "2021"; };
      pdfstudio2022 = callPackage ../applications/misc/pdfstudio { year = "2022"; };
      pdfstudio2023 = callPackage ../applications/misc/pdfstudio { year = "2023"; };
      pdfstudio2024 = callPackage ../applications/misc/pdfstudio { year = "2024"; };
      pdfstudioviewer = callPackage ../applications/misc/pdfstudio { program = "pdfstudioviewer"; };
    })
    pdfstudio2021
    pdfstudio2022
    pdfstudio2023
    pdfstudio2024
    pdfstudioviewer
    ;

  # calico-felix and calico-node have not been packaged due to libbpf, linking issues
  inherit (callPackage ../applications/networking/cluster/calico { })
    calico-apiserver
    calico-app-policy
    calico-cni-plugin
    calico-kube-controllers
    calico-pod2daemon
    calico-typha
    calicoctl
    confd-calico
    ;

  inherit (callPackage ../development/tools/devpod { }) devpod devpod-desktop;

  inherit (callPackage ../applications/virtualization/docker { })
    docker_25
    docker_29
    ;

  inherit (recurseIntoAttrs (callPackage ../applications/editors/emacs { }))
    emacs31
    emacs31-gtk3
    emacs31-nox
    emacs31-pgtk

    emacs30
    emacs30-gtk3
    emacs30-nox
    emacs30-pgtk

    emacs30-macport
    ;

  inherit (ocamlPackages) google-drive-ocamlfuse;

  inherit
    ({
      freeoffice = callPackage ../applications/office/softmaker/freeoffice.nix { };
    })
    freeoffice
    ;

  inherit (callPackage ../applications/virtualization/singularity/packages.nix { })
    apptainer
    singularity
    apptainer-overriden-nixos
    singularity-overriden-nixos
    ;

  inherit (callPackages ../development/libraries/wlroots { })
    wlroots_0_19
    wlroots_0_20
    ;

  inherit (callPackage ../applications/networking/cluster/k3s { })
    k3s_1_33
    k3s_1_34
    k3s_1_35
    k3s_1_36
    ;

  inherit (mopidyPackages)
    mopidy
    mopidy-listenbrainz
    mopidy-bandcamp
    mopidy-iris
    mopidy-jellyfin
    mopidy-local
    mopidy-moped
    mopidy-mopify
    mopidy-mpd
    mopidy-mpris
    mopidy-muse
    mopidy-musicbox-webclient
    mopidy-notify
    mopidy-podcast
    mopidy-scrobbler
    mopidy-somafm
    mopidy-soundcloud
    mopidy-spotify
    mopidy-subidy
    mopidy-tidal
    mopidy-tunein
    mopidy-youtube
    mopidy-ytmusic
    ;

  inherit
    ({
      softmaker-office = callPackage ../applications/office/softmaker/softmaker-office.nix { };
      softmaker-office-nx = callPackage ../applications/office/softmaker/softmaker-office-nx.nix { };
    })
    softmaker-office
    softmaker-office-nx
    ;

  inherit (callPackages ../data/fonts/open-relay { })
    constructium
    fairfax
    fairfax-hd
    kreative-square
    ;

  inherit (pidginPackages) pidgin;

  inherit (callPackage ../applications/networking/cluster/rke2 { })
    rke2_1_33
    rke2_1_34
    rke2_1_35
    rke2_1_36
    rke2_stable
    rke2_latest
    ;

  inherit (callPackages ../applications/radio/rtl-sdr { })
    rtl-sdr-librtlsdr
    rtl-sdr-osmocom
    rtl-sdr-blog
    ;

  inherit (ocaml-ng.ocamlPackages) stog;

  inherit (recurseIntoAttrs (callPackage ../applications/editors/sublime/4/packages.nix { }))
    sublime4
    sublime4-dev
    ;

  inherit (callPackage ../applications/version-management/sublime-merge { })
    sublime-merge
    sublime-merge-dev
    ;

  inherit
    (callPackages ../applications/version-management/subversion {
      sasl = cyrus_sasl;
    })
    subversion
    ;

  inherit
    (callPackage ../applications/graphics/tesseract {
    })
    tesseract3
    tesseract4
    tesseract5
    ;

  inherit
    ({
      timeshift = callPackage ../applications/backup/timeshift { grubPackage = grub2; };
      timeshift-minimal = callPackage ../applications/backup/timeshift/minimal.nix { };
      timeshift-unwrapped = callPackage ../applications/backup/timeshift/unwrapped.nix { };
    })
    timeshift-unwrapped
    timeshift
    timeshift-minimal
    ;

  inherit (callPackage ../applications/misc/xppen { })
    xppen_3
    xppen_4
    ;

  ### GAMES
  inherit (callPackages ../games/fteqw { })
    fteqw
    fteqw-dedicated
    fteqcc
    ;

  inherit (dwarf-fortress-packages) dwarf-fortress dwarf-fortress-full dwarf-therapist;

  inherit (callPackages ../by-name/dx/dxx-rebirth/assets.nix { })
    descent1-assets
    descent2-assets
    ;

  inherit (callPackages ../by-name/dx/dxx-rebirth/full.nix { })
    d1x-rebirth-full
    d2x-rebirth-full
    ;

  inherit (import ../games/quake3 pkgs.callPackage)
    quake3wrapper
    quake3arenadata
    quake3demodata
    quake3pointrelease
    quake3arena
    quake3arena-hires
    quake3demo
    quake3demo-hires
    quake3hires
    ;

  inherit (callPackage ../by-name/sc/scummvm/games.nix { })
    beneath-a-steel-sky
    broken-sword-25
    drascula-the-vampire-strikes-back
    dreamweb
    flight-of-the-amazon-queen
    lure-of-the-temptress
    ;

  inherit (callPackage ../games/xonotic { })
    xonotic-data
    xonotic
    ;

  inherit
    (callPackage ../games/quake2/yquake2 {
    })
    yquake2
    yquake2-ctf
    yquake2-ground-zero
    yquake2-the-reckoning
    yquake2-all-games
    ;

  inherit (callPackage ../desktops/gnome/extensions { })
    gnomeExtensions
    gnome38Extensions
    gnome40Extensions
    gnome41Extensions
    gnome42Extensions
    gnome43Extensions
    gnome44Extensions
    gnome45Extensions
    gnome46Extensions
    gnome47Extensions
    gnome48Extensions
    gnome49Extensions
    gnome50Extensions
    ;

  inherit
    (callPackages ../applications/misc/redshift {
      inherit (python3Packages)
        python
        pygobject3
        pyxdg
        wrapPython
        ;

      geoclue = geoclue2;
    })
    redshift
    gammastep
    ;

  ### SCIENCE/PHYSICS
  ### SCIENCE/LOGIC
  inherit
    (callPackage ./rocq-packages.nix {
      inherit (ocaml-ng)
        ocamlPackages_4_14
        ocamlPackages_5_4
        ;
    })
    mkRocqPackages
    rocqPackages_9_0
    rocq-core_9_0
    rocqPackages_9_1
    rocq-core_9_1
    rocqPackages_9_2
    rocq-core_9_2
    rocqPackages
    rocq-core
    ;

  inherit
    (callPackage ./coq-packages.nix {
      inherit (ocaml-ng)
        ocamlPackages_4_09
        ocamlPackages_4_10
        ocamlPackages_4_12
        ocamlPackages_4_14
        ocamlPackages_5_4
        ;

      inherit
        rocqPackages_9_0
        rocqPackages_9_1
        rocqPackages_9_2
        rocqPackages
        ;
    })
    mkCoqPackages
    coqPackages_8_7
    coq_8_7
    coqPackages_8_8
    coq_8_8
    coqPackages_8_9
    coq_8_9
    coqPackages_8_10
    coq_8_10
    coqPackages_8_11
    coq_8_11
    coqPackages_8_12
    coq_8_12
    coqPackages_8_13
    coq_8_13
    coqPackages_8_14
    coq_8_14
    coqPackages_8_15
    coq_8_15
    coqPackages_8_16
    coq_8_16
    coqPackages_8_17
    coq_8_17
    coqPackages_8_18
    coq_8_18
    coqPackages_8_19
    coq_8_19
    coqPackages_8_20
    coq_8_20
    coqPackages_9_0
    coq_9_0
    coqPackages_9_1
    coq_9_1
    coqPackages_9_2
    coq_9_2
    coqPackages
    coq
    ;

  # In general we only want keep the last three minor versions around that
  # correspond to the last three supported kubernetes versions:
  # https://kubernetes.io/docs/setup/release/version-skew-policy/#supported-versions
  # Exceptions are versions that we need to keep to allow upgrades from older NixOS releases
  inherit (callPackage ../applications/networking/cluster/kops { })
    mkKops
    kops_1_31
    kops_1_32
    kops_1_33
    ;

  inherit (callPackages ../applications/networking/cluster/nixops { })
    nixops_unstable_minimal

    # Not recommended; too fragile
    nixops_unstable_full
    ;

  inherit (callPackages ../tools/package-management/nix-prefetch-scripts { })
    nix-prefetch-bzr
    nix-prefetch-cvs
    nix-prefetch-darcs
    nix-prefetch-fossil
    nix-prefetch-git
    nix-prefetch-hg
    nix-prefetch-pijul
    nix-prefetch-svn
    nix-prefetch-scripts
    ;

  inherit (callPackage ../applications/networking/cluster/terraform { })
    mkTerraform
    terraform_1
    terraform_plugins_test
    ;

  inherit (callPackage ../servers/web-apps/wordpress { })
    wordpress
    wordpress_6_8
    wordpress_6_9
    wordpress_7_0
    ;

  inherit
    ({
      dart-bin = callPackage ../development/compilers/dart { };
    })
    dart-bin
    ;

  inherit
    ({
      dart-source = callPackage ../development/compilers/dart/source { };
    })
    dart-source
    ;

  inherit (callPackage ../applications/networking/instant-messengers/discord { })
    discord
    discord-ptb
    discord-canary
    discord-development
    ;

  inherit (unixtools)
    hexdump
    ps
    logger
    eject
    umount
    mount
    wall
    hostname
    more
    sysctl
    getconf
    getent
    locale
    killall
    xxd
    watch
    ;

  ### Evaluating the entire Nixpkgs naively will likely fail, make failure fast
  AAAAAASomeThingsFailToEvaluate = throw ''
    This pseudo-package is likely not the only part of Nixpkgs that fails to evaluate.
    You should not evaluate entire Nixpkgs without measures to handle failing packages.
  '';

  ### END OF LUA
  ### CuboCore
  CuboCore = recurseIntoAttrs (
    import ./cubocore-packages.nix {
      inherit
        newScope
        lxqt
        lib
        ;
    }
  );

  Fabric = with python3Packages; toPythonApplication fabric;

  OVMF = callPackage ../applications/virtualization/OVMF {
    inherit (python3Packages) pexpect;
  };

  OVMFFull = callPackage ../applications/virtualization/OVMF {
    inherit (python3Packages) pexpect;
    httpSupport = true;
    msVarsTemplate = stdenv.hostPlatform.isx86_64 || stdenv.hostPlatform.isAarch64;
    secureBoot = true;
    tlsSupport = true;
    tpmSupport = true;
  };

  ### DEVELOPMENT / R MODULES
  R = callPackage ../applications/science/math/R {
    # TODO: split docs into a separate output
    withRecommendedPackages = false;
  };

  SDL = sdl12-compat;
  SDL2 = sdl2-compat;

  ### APPLICATIONS
  _2bwm = callPackage ../applications/window-managers/2bwm {
    patches = config."2bwm".patches or [ ];
  };

  ### TOOLS
  _7zz-rar = _7zz.override { enableUnfree = true; };

  ### APPLICATIONS/EMULATORS
  _86box-with-roms = _86box.override {
    unfreeEnableDiscord = true;
    unfreeEnableRoms = true;
  };

  ### BUILD SUPPORT
  __flattenIncludeHackHook = callPackage ../build-support/setup-hooks/flatten-include-hack { };
  # Top-level fix-point used in `cudaPackages`' internals
  _cuda = import ../development/cuda-modules/_cuda;
  _experimental-update-script-combinators = callPackage ../common-updater/combinators.nix { };
  _surrealdbPackage = ../by-name/su/surrealdb/package.nix;
  # A module system style type tag
  #
  # Allows the nixpkgs fixpoint, usually known as `pkgs` to be distinguished
  # nominally.
  #
  #     pkgs._type == "pkgs"
  #     pkgs.pkgsStatic._type == "pkgs"
  #
  # Design note:
  # While earlier stages of nixpkgs fixpoint construction are supertypes of this
  # stage, they're generally not usable in places where a `pkgs` is expected.
  # (earlier stages being the various `super` variables that precede
  # all-packages.nix)
  _type = "pkgs";

  # Armed Bear Common Lisp
  abcl = wrapLisp {
    faslExt = "abcl";
    pkg = callPackage ../development/compilers/abcl { };
  };

  ### DEVELOPMENT / LIBRARIES
  abseil-cpp_202103 = callPackage ../development/libraries/abseil-cpp/202103.nix { };
  abseil-cpp_202401 = callPackage ../development/libraries/abseil-cpp/202401.nix { };
  abseil-cpp_202407 = callPackage ../development/libraries/abseil-cpp/202407.nix { };
  ack = perlPackages.ack;
  acl = callPackage ../development/libraries/acl { };
  ### DEVELOPMENT / INTERPRETERS
  acl2-minimal = acl2.override { certifyBooks = false; };
  acquire = with python3Packages; toPythonApplication acquire;
  actdiag = with python3.pkgs; toPythonApplication actdiag;
  activitywatch = callPackage ../applications/office/activitywatch/wrapper.nix { };
  adaptivecppWithCuda = adaptivecpp.override { cudaSupport = true; };
  adaptivecppWithRocm = adaptivecpp.override { rocmSupport = true; };

  ### TOOLS/TYPESETTING/TEX
  advi = callPackage ../tools/typesetting/tex/advi {
    ocamlPackages = ocaml-ng.ocamlPackages_4_14;
  };

  ### DATA
  adwaita-qt6 = adwaita-qt.override { useQt6 = true; };
  aflplusplus = callPackage ../tools/security/aflplusplus { wine = null; };
  agda = agdaPackages.agda;

  ### DEVELOPMENT / TESTING TOOLS
  ### DEVELOPMENT / LIBRARIES / AGDA
  agdaPackages = recurseIntoAttrs (
    callPackage ./agda-packages.nix {
      inherit (haskellPackages) Agda;
    }
  );

  aggregateModules =
    modules:
    callPackage ../os-specific/linux/kmod/aggregator.nix {
      inherit (buildPackages) kmod;
      inherit modules;
    };

  aider-chat-full = aider-chat.withOptional { withAll = true; };
  aider-chat-with-bedrock = aider-chat.withOptional { withBedrock = true; };
  aider-chat-with-browser = aider-chat.withOptional { withBrowser = true; };
  aider-chat-with-help = aider-chat.withOptional { withHelp = true; };
  aider-chat-with-playwright = aider-chat.withOptional { withPlaywright = true; };
  aioblescan = with python3Packages; toPythonApplication aioblescan;
  aiovban-pyaudio = python3Packages.toPythonApplication python3Packages.aiovban-pyaudio;
  alacritty-graphics = callPackage ../by-name/al/alacritty/package.nix { withGraphics = true; };
  alex = haskell.lib.compose.justStaticExecutables haskellPackages.alex;

  ### BLOCKCHAINS / CRYPTOCURRENCIES / WALLETS
  alfis-nogui = alfis.override {
    withGui = false;
  };

  ### OS-SPECIFIC
  alfred = callPackage ../os-specific/linux/batman-adv/alfred.nix { };
  alice-tools-qt5 = alice-tools.override { withQt5 = true; };
  alice-tools-qt6 = alice-tools.override { withQt6 = true; };
  all-cabal-hashes = callPackage ../data/misc/hackage { };
  allegro = allegro4;
  allegro4 = callPackage ../development/libraries/allegro { };
  allegro5 = callPackage ../development/libraries/allegro/5.nix { };
  amarena-theme = callPackage ../data/themes/gtk-theme-framework { theme = "amarena"; };
  ammonite = ammonite_3_3;
  android-studio = androidStudioPackages.stable;
  android-studio-for-platform = androidStudioForPlatformPackages.stable;
  android-studio-full = android-studio.full;
  android-tools = lowPrio (callPackage ../tools/misc/android-tools { });

  androidStudioForPlatformPackages = recurseIntoAttrs (
    callPackage ../applications/editors/android-studio-for-platform { }
  );

  androidStudioPackages = recurseIntoAttrs (callPackage ../applications/editors/android-studio { });
  androidenv = callPackage ../development/mobile/androidenv { };
  androidndkPkgs = androidndkPkgs_27;
  androidndkPkgs_27 = (callPackage ../development/androidndk-pkgs { })."27";
  androidndkPkgs_28 = (callPackage ../development/androidndk-pkgs { })."28";
  androidndkPkgs_29 = (callPackage ../development/androidndk-pkgs { })."29";
  androidsdk = androidenv.androidPkgs.androidsdk;

  angie = callPackage ../servers/http/angie {
    # We don't use `with` statement here on purpose!
    # See https://github.com/NixOS/nixpkgs/pull/10474#discussion_r42369334
    modules = [
      nginxModules.rtmp
      nginxModules.dav
      nginxModules.moreheaders
    ];

    withPerl = false;
    zlib-ng = zlib-ng.override { withZlibCompat = true; };
  };

  angie-console-light = callPackage ../servers/http/angie/console-light.nix { };
  # ipscan is commonly known under the name angryipscanner
  angryipscanner = ipscan;
  anki-utils = callPackage ../by-name/an/anki/addons/anki-utils.nix { };
  ankiAddons = recurseIntoAttrs (callPackage ../by-name/an/anki/addons { });
  ansi2html = with python3.pkgs; toPythonApplication ansi2html;
  ansible = python3Packages.toPythonApplication python3Packages.ansible-core;
  ansible-builder = with python3Packages; toPythonApplication ansible-builder;

  ansible-language-server =
    callPackage ../development/tools/language-servers/ansible-language-server
      { };

  antigravity-fhs = antigravity.fhs;
  antigravity-fhsWithPackages = antigravity.fhsWithPackages;
  antlr = antlr4;
  antlr2 = callPackage ../development/tools/parsing/antlr/2.7.7.nix { };
  antlr3 = antlr3_5;
  antlr3_4 = callPackage ../development/tools/parsing/antlr/3.4.nix { };
  antlr3_5 = callPackage ../development/tools/parsing/antlr/3.5.nix { };
  antlr4 = antlr4_13;
  anybadge = with python3Packages; toPythonApplication anybadge;
  # addDriverRunpath is the preferred package name, as this enables
  # many more scenarios than just opengl now.
  aocd = with python3Packages; toPythonApplication aocd;
  apacheHttpd = apacheHttpd_2_4;
  apacheHttpdPackages = apacheHttpdPackages_2_4;

  apacheHttpdPackagesFor =
    apacheHttpd: self:
    let
      callPackage = newScope self;
    in
    {
      inherit apacheHttpd;
      mod_auth_mellon = callPackage ../servers/http/apache-modules/mod_auth_mellon { };
      mod_ca = callPackage ../servers/http/apache-modules/mod_ca { };
      mod_crl = callPackage ../servers/http/apache-modules/mod_crl { };
      mod_cspnonce = callPackage ../servers/http/apache-modules/mod_cspnonce { };
      mod_csr = callPackage ../servers/http/apache-modules/mod_csr { };
      mod_dnssd = callPackage ../servers/http/apache-modules/mod_dnssd { };
      mod_fastcgi = callPackage ../servers/http/apache-modules/mod_fastcgi { };
      mod_itk = callPackage ../servers/http/apache-modules/mod_itk { };
      mod_jk = callPackage ../servers/http/apache-modules/mod_jk { };
      mod_mbtiles = callPackage ../servers/http/apache-modules/mod_mbtiles { };
      mod_ocsp = callPackage ../servers/http/apache-modules/mod_ocsp { };
      mod_perl = callPackage ../servers/http/apache-modules/mod_perl { };
      mod_pkcs12 = callPackage ../servers/http/apache-modules/mod_pkcs12 { };
      mod_python = callPackage ../servers/http/apache-modules/mod_python { };
      mod_scep = callPackage ../servers/http/apache-modules/mod_scep { };
      mod_spkac = callPackage ../servers/http/apache-modules/mod_spkac { };
      mod_tile = callPackage ../servers/http/apache-modules/mod_tile { };
      mod_timestamp = callPackage ../servers/http/apache-modules/mod_timestamp { };
      mod_wsgi3 = callPackage ../servers/http/apache-modules/mod_wsgi { };
      php = pkgs.php.override { inherit apacheHttpd; };

      subversion = pkgs.subversion.override {
        inherit apacheHttpd;
        httpServer = true;
      };
    }
    // lib.optionalAttrs config.allowAliases {
      mod_evasive = throw "mod_evasive is not supported on Apache httpd 2.4";
      mod_wsgi = self.mod_wsgi2;
      mod_wsgi2 = throw "mod_wsgi2 has been removed since Python 2 is EOL. Use mod_wsgi3 instead";
    };

  apacheHttpdPackages_2_4 = recurseIntoAttrs (
    apacheHttpdPackagesFor apacheHttpd_2_4 apacheHttpdPackages_2_4
  );

  ### SERVERS
  apacheHttpd_2_4 = callPackage ../servers/http/apache-httpd/2.4.nix { };
  apacheKafka = apacheKafka_4_3;
  ape = callPackage ../applications/misc/ape { };
  apeClex = callPackage ../applications/misc/ape/apeclex.nix { };
  appdaemon = callPackage ../servers/home-assistant/appdaemon.nix { };
  appimage-run = callPackage ../tools/package-management/appimage-run { };

  appimage-run-tests = callPackage ../tools/package-management/appimage-run/test.nix {
    appimage-run = appimage-run.override {
      appimage-run-tests = null; # break boostrap cycle for passthru.tests
    };
  };

  appimageTools = callPackage ../build-support/appimage { };
  appimageupdate-qt = appimageupdate.override { withQtUI = true; };
  ### DEVELOPMENT / LIBRARIES / DARWIN SDKS
  apple-sdk_14 = callPackage ../by-name/ap/apple-sdk/package.nix { darwinSdkMajorVersion = "14"; };
  apple-sdk_15 = callPackage ../by-name/ap/apple-sdk/package.nix { darwinSdkMajorVersion = "15"; };
  apple-sdk_26 = callPackage ../by-name/ap/apple-sdk/package.nix { darwinSdkMajorVersion = "26"; };
  apprise = with python3Packages; toPythonApplication apprise;
  appstream = callPackage ../development/libraries/appstream { };
  aqbanking = callPackage ../development/libraries/aqbanking { };

  arcan-all-wrapped = arcan.wrapper.override {
    appls = [
      cat9
      durden
      pipeworld
    ];

    name = "arcan-all-wrapped";

  };

  ### DESKTOP ENVIRONMENTS
  arcan-wrapped = arcan.wrapper.override { };
  arduino = arduino-core.override { withGui = true; };
  arelle = with python3Packages; toPythonApplication arelle;
  argparse-manpage = with python3Packages; toPythonApplication argparse-manpage;
  arm-trusted-firmware = callPackage ../misc/arm-trusted-firmware { };
  arocc = aroccPackages.latest;
  aroccPackages = recurseIntoAttrs (callPackage ../development/compilers/arocc { });
  aroccStdenv = if stdenv.cc.isArocc then stdenv else lowPrio arocc.cc.passthru.stdenv;
  arpack-mpi = arpack.override { useMpi = true; };

  arrayUtilities =
    let
      arrayUtilitiesPackages = makeScopeWithSplicing' {
        f =
          finalArrayUtilities:
          {
            callPackages = lib.callPackagesWith (pkgs // finalArrayUtilities);
          }
          // lib.packagesFromDirectoryRecursive {
            inherit (finalArrayUtilities) callPackage;
            directory = ../build-support/setup-hooks/arrayUtilities;
          };

        otherSplices = generateSplicesForMkScope "arrayUtilities";
      };
    in
    recurseIntoAttrs arrayUtilitiesPackages;

  asciidoc-full = asciidoc.override {
    enableStandardFeatures = true;
  };

  asciidoc-full-with-plugins = asciidoc.override {
    enableExtraPlugins = true;
    enableStandardFeatures = true;
  };

  ### DEVELOPMENT / LISP MODULES
  asdf = callPackage ../development/lisp-modules/asdf {
    texLive = null;
  };

  # QuickLisp minimal version
  asdf_2_26 = callPackage ../development/lisp-modules/asdf/2.26.nix {
    texLive = null;
  };

  # Currently most popular
  asdf_3_1 = callPackage ../development/lisp-modules/asdf/3.1.nix {
    texLive = null;
  };

  # Latest
  asdf_3_3 = callPackage ../development/lisp-modules/asdf/3.3.nix {
    texLive = null;
  };

  asio_1_32_0 = callPackage ../by-name/as/asio/package.nix { asioVersion = "1.32.0"; };
  asio_1_36_0 = callPackage ../by-name/as/asio/package.nix { asioVersion = "1.36.0"; };
  aspell = callPackage ../development/libraries/aspell { };
  aspellDicts = recurseIntoAttrs (callPackages ../development/libraries/aspell/dictionaries.nix { });

  aspellWithDicts = callPackage ../development/libraries/aspell/aspell-with-dicts.nix {
    aspell = aspell.override { searchNixProfiles = false; };
  };

  astal = recurseIntoAttrs (lib.makeScope newScope (callPackage ../development/libraries/astal { }));
  asterisk-ldap = lowPrio (asterisk.override { ldapSupport = true; });

  astroid = callPackage ../applications/networking/mailreaders/astroid {
    protobuf = protobuf_21;
    vim = vim-full.override { features = "normal"; };
  };

  # Not moved to aliases while we decide if we should split the package again.
  at-spi2-atk = at-spi2-core;
  ath9k-htc-blobless-firmware = callPackage ../os-specific/linux/firmware/ath9k { };

  ath9k-htc-blobless-firmware-unstable = callPackage ../os-specific/linux/firmware/ath9k {
    enableUnstable = true;
  };

  # Not moved to aliases while we decide if we should split the package again.
  atk = at-spi2-core;
  attr = callPackage ../development/libraries/attr { };
  audacious = audacious-bare.override { withPlugins = true; };
  auditbeat = auditbeat7;
  auditwheel = with python3Packages; toPythonApplication auditwheel;
  authentik-outposts = recurseIntoAttrs (callPackages ../by-name/au/authentik/outposts.nix { });
  autoconf = callPackage ../development/tools/misc/autoconf { };
  autoconf269 = callPackage ../development/tools/misc/autoconf/2.69.nix { };
  autoflake = with python3.pkgs; toPythonApplication autoflake;
  automake = automake118x;
  automake116x = callPackage ../development/tools/misc/automake/automake-1.16.x.nix { };
  automake118x = callPackage ../development/tools/misc/automake/automake-1.18.x.nix { };

  autoreconfHook269 = autoreconfHook.override {
    autoconf = autoconf269;
  };

  avalonia-ilspy = callPackage ../applications/misc/avalonia-ilspy {
    inherit (darwin) autoSignDarwinBinariesHook;
  };

  awesome = callPackage ../applications/window-managers/awesome {
    inherit (texFunctions) fontsConf;
    cairo = cairo.override { xcbSupport = true; };
  };

  aws-adfs = with python3Packages; toPythonApplication aws-adfs;
  aws-spend-summary = haskellPackages.aws-spend-summary.bin;
  azure-cli-extensions = recurseIntoAttrs azure-cli.extensions;
  azure-sdk-for-cpp = recurseIntoAttrs (callPackage ../development/libraries/azure-sdk-for-cpp { });

  b2sum = callPackage ../tools/security/b2sum {
    inherit (llvmPackages) openmp;
  };

  b43Firmware_5_1_138 = callPackage ../os-specific/linux/firmware/b43-firmware/5.1.138.nix { };

  b43Firmware_6_30_163_46 =
    callPackage ../os-specific/linux/firmware/b43-firmware/6.30.163.46.nix
      { };

  babelfish = callPackage ../shells/fish/babelfish.nix { };
  backintime = backintime-qt;
  bambootracker-qt6 = bambootracker.override { withQt6 = true; };
  bandit = with python3Packages; toPythonApplication bandit;
  barbicanclient = with python313Packages; toPythonApplication python-barbicanclient;
  bash = callPackage ../shells/bash/5.nix { };

  bashFHS = callPackage ../shells/bash/5.nix {
    forFHSEnv = true;
  };

  # WARNING: this attribute is used by nix-shell so it shouldn't be removed/renamed
  bashInteractive = bash;
  bashInteractiveFHS = bashFHS;

  bashNonInteractive = lowPrio (
    callPackage ../shells/bash/5.nix {
      interactive = false;
    }
  );

  bat-extras = recurseIntoAttrs (lib.makeScope newScope (import ../tools/misc/bat-extras));
  batctl = callPackage ../os-specific/linux/batman-adv/batctl.nix { };
  bazel = bazel_7;
  beam = callPackage ./beam-packages.nix { };
  beam27Packages = recurseIntoAttrs beam.packages.erlang_27.beamPackages;
  beam28Packages = recurseIntoAttrs beam.packages.erlang_28.beamPackages;
  beam29Packages = recurseIntoAttrs beam.packages.erlang_29.beamPackages;
  beamMinimal27Packages = recurseIntoAttrs beam_minimal.packages.erlang_27.beamPackages;
  beamMinimal28Packages = recurseIntoAttrs beam_minimal.packages.erlang_28.beamPackages;
  beamMinimal29Packages = recurseIntoAttrs beam_minimal.packages.erlang_29.beamPackages;
  beamMinimalPackages = dontRecurseIntoAttrs beam_minimal.packages.erlang.beamPackages;
  beamPackages = dontRecurseIntoAttrs beam.packages.erlang.beamPackages;

  beam_minimal = callPackage ./beam-packages.nix {
    beam = beam_minimal;
    systemdSupport = false;
    wxSupport = false;
  };

  beamerpresenter-mupdf = beamerpresenter;

  beamerpresenter-poppler = beamerpresenter.override {
    useMupdf = false;
    usePoppler = true;
  };

  bean-add = callPackage ../applications/office/beancount/bean-add.nix { };
  beancount = with python3.pkgs; toPythonApplication beancount;
  beancount-black = with python3.pkgs; toPythonApplication beancount-black;

  beancount-ing-diba = callPackage ../applications/office/beancount/beancount-ing-diba.nix {
    inherit (python3Packages) beancount beangulp;
  };

  beancount-share = callPackage ../applications/office/beancount/beancount_share.nix {
    inherit (python3Packages) beancount beancount-plugin-utils;
  };

  beancount_2 = with python3.pkgs; toPythonApplication beancount_2;
  beanhub-cli = with python3.pkgs; toPythonApplication beanhub-cli;
  beanquery = with python3.pkgs; toPythonApplication beanquery;
  beautysh = with python3.pkgs; toPythonApplication beautysh;
  behave = with python3Packages; toPythonApplication behave;

  bench =
    # TODO: Erroneous references to GHC on aarch64-darwin: https://github.com/NixOS/nixpkgs/issues/318013
    (
      if stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64 then
        lib.id
      else
        haskell.lib.compose.justStaticExecutables
    )
      haskellPackages.bench;

  ber_metaocaml = callPackage ../development/compilers/ocaml/ber-metaocaml.nix { };

  bespokesynth-with-vst2 = bespokesynth.override {
    enableVST2 = true;
  };

  biliass = with python3.pkgs; toPythonApplication biliass;

  binaryen = callPackage ../development/compilers/binaryen {
    inherit (python3Packages) filecheck;
    nodejs = nodejs-slim;
  };

  binlore = callPackage ../development/tools/analysis/binlore { };

  bintools = wrapBintoolsWith {
    bintools = bintools-unwrapped;
  };

  # Here we select the default bintools implementations to be used.  Note when
  # cross compiling these are used not for this stage but the *next* stage.
  # That is why we choose using this stage's target platform / next stage's
  # host platform.
  #
  # Because this is the *next* stages choice, it's a bit non-modular to put
  # here. In theory, bootstrapping is supposed to not be a chain but at tree,
  # where each stage supports many "successor" stages, like multiple possible
  # futures. We don't have a better alternative, but with this downside in
  # mind, please be judicious when using this attribute. E.g. for building
  # things in *this* stage you should use probably `stdenv.cc.bintools` (from a
  # default or alternate `stdenv`), at build time, and try not to "force" a
  # specific bintools at runtime at all.
  #
  # In other words, try to only use this in wrappers, and only use those
  # wrappers from the next stage.
  bintools-unwrapped =
    let
      inherit (stdenv.targetPlatform) linker;
    in
    if linker == "lld" then
      llvmPackages.bintools-unwrapped
    else if linker == "cctools" then
      darwin.binutils-unwrapped
    else if linker == "bfd" then
      binutils-unwrapped
    else if linker == "gold" then
      binutils-unwrapped.override { enableGoldDefault = true; }
    else
      null;

  bintoolsNoLibc = wrapBintoolsWith {
    bintools = bintools-unwrapped;
    libc = targetPackages.preLibcHeaders or preLibcHeaders;
  };

  binutils = wrapBintoolsWith {
    bintools = binutils-unwrapped;
  };

  binutils-unwrapped = callPackage ../development/tools/misc/binutils {
    # FHS sys dirs presumably only have stuff for the build platform
    noSysDirs = (stdenv.targetPlatform != stdenv.hostPlatform) || noSysDirs;
  };

  binutils-unwrapped-all-targets = callPackage ../development/tools/misc/binutils {
    # FHS sys dirs presumably only have stuff for the build platform
    noSysDirs = (stdenv.targetPlatform != stdenv.hostPlatform) || noSysDirs;
    withAllTargets = true;
  };

  # Held back 2.38 release. Remove once all dependencies are ported to 2.39.
  binutils-unwrapped_2_38 = callPackage ../development/tools/misc/binutils/2.38 {
    autoreconfHook = autoreconfHook269;
    # FHS sys dirs presumably only have stuff for the build platform
    noSysDirs = (stdenv.targetPlatform != stdenv.hostPlatform) || noSysDirs;
  };

  binutilsNoLibc = wrapBintoolsWith {
    bintools = binutils-unwrapped;
    libc = targetPackages.preLibcHeaders or preLibcHeaders;
  };

  binutils_nogold = lowPrio (wrapBintoolsWith {
    bintools = binutils-unwrapped.override {
      enableGold = false;
    };
  });

  # TODO(@Ericson2314): Build bionic libc from source
  bionic =
    if stdenv.hostPlatform.useAndroidPrebuilt then
      pkgs."androidndkPkgs_${stdenv.hostPlatform.androidNdkVersion}".libraries
    else
      callPackage ../os-specific/linux/bionic-prebuilt { };

  bitcoind = bitcoin.override {
    withGui = false;
  };

  bitcoind-knots = bitcoin-knots.override {
    withGui = false;
  };

  bitlbee = callPackage ../applications/networking/instant-messengers/bitlbee { };
  bitlbee-plugins = callPackage ../applications/networking/instant-messengers/bitlbee/plugins.nix { };

  bitscope = recurseIntoAttrs (
    callPackage ../applications/science/electronics/bitscope/packages.nix { }
  );

  bitwig-studio = bitwig-studio6;

  bitwig-studio4 = callPackage ../applications/audio/bitwig-studio/bitwig-studio4.nix {
    libjpeg = libjpeg8;
  };

  bitwig-studio5 = callPackage ../applications/audio/bitwig-studio/bitwig-wrapper.nix {
    bitwig-studio-unwrapped = bitwig-studio5-unwrapped;
  };

  bitwig-studio5-unwrapped = callPackage ../applications/audio/bitwig-studio/bitwig-studio5.nix {
    libjpeg = libjpeg8;
  };

  black = with python3Packages; toPythonApplication black;
  black-macchiato = with python3Packages; toPythonApplication black-macchiato;
  blacken-docs = with python3Packages; toPythonApplication blacken-docs;
  ### SCIENCE/MATH
  blas-ilp64 = blas.override { isILP64 = true; };
  blightmud-tts = callPackage ../by-name/bl/blightmud/package.nix { withTTS = true; };
  blockdiag = with python3Packages; toPythonApplication blockdiag;
  blocksat-cli = with python3Packages; toPythonApplication blocksat-cli;
  bloodhound-py = with python3Packages; toPythonApplication bloodhound-py;

  bluez-experimental = bluez.override {
    enableExperimental = true;
  };

  bluez5 = bluez;
  bluez5-experimental = bluez-experimental;
  bmrsa = callPackage ../tools/security/bmrsa/11.nix { };
  bogofilter-db = bogofilter.override { database = db; };
  bogofilter-sqlite = bogofilter.override { database = sqlite; };
  ### SCIENCE / MISC
  boinc-headless = boinc.override { headless = true; };
  bolt_19 = llvmPackages_19.bolt;
  bolt_20 = llvmPackages_20.bolt;
  bolt_21 = llvmPackages_21.bolt;
  bolt_22 = llvmPackages_22.bolt;
  boost = boost189;
  botanEsdm = botan3.override { withEsdm = true; };

  box64 = callPackage ../applications/emulators/box64 {
    hello-x86_64 = if stdenv.hostPlatform.isx86_64 then hello else pkgsCross.gnu64.hello;
  };

  box86 =
    let
      args = {
        hello-x86_32 = if stdenv.hostPlatform.isx86_32 then hello else pkgsCross.gnu32.hello;
      };
    in
    if stdenv.hostPlatform.is32bit then
      callPackage ../applications/emulators/box86 args
    else if stdenv.hostPlatform.isx86_64 then
      pkgsCross.gnu32.callPackage ../applications/emulators/box86 args
    else if stdenv.hostPlatform.isAarch64 then
      pkgsCross.armv7l-hf-multiplatform.callPackage ../applications/emulators/box86 args
    else if stdenv.hostPlatform.isRiscV64 then
      pkgsCross.riscv32.callPackage ../applications/emulators/box86 args
    else
      throw "Don't know 32-bit platform for cross from: ${stdenv.hostPlatform.stdenv}";

  bozohttpd-minimal = bozohttpd.override { minimal = true; };
  breezy = with python3Packages; toPythonApplication breezy;
  ### MISC
  brgenml1lpr = pkgsi686Linux.callPackage ../misc/cups/drivers/brgenml1lpr { };

  bsd-fingerd = bsd-finger.override {
    buildProduct = "daemon";
  };

  bsdSetupHook = makeSetupHook {
    name = "bsd-setup-hook";
    meta.license = lib.licenses.mit;
  } ../os-specific/bsd/setup-hook.sh;

  btcli = with python3Packages; toPythonApplication bittensor-cli;
  btop-cuda = btop.override { cudaSupport = true; };
  btop-rocm = btop.override { rocmSupport = true; };
  btrsync = with python3Packages; toPythonApplication btrsync;
  bucklespring = bucklespring-x11;
  bucklespring-x11 = callPackage ../by-name/bu/bucklespring-libinput/package.nix { legacy = true; };
  buildBazelPackage = callPackage ../build-support/build-bazel-package { };
  buildDartApplication = callPackage ../build-support/dart/build-dart-application { };
  buildDotnetPackage = callPackage ../build-support/dotnet/build-dotnet-package { };
  ### DEVELOPMENT / EMSCRIPTEN
  buildEmscriptenPackage = callPackage ../development/em-modules/generic { };
  buildEnv = callPackage ../build-support/buildenv { }; # not actually a package
  buildFHSEnv = buildFHSEnvBubblewrap;
  buildFHSEnvBubblewrap = callPackage ../build-support/build-fhsenv-bubblewrap { };

  buildGo125Module = callPackage ../build-support/go/module.nix {
    go = buildPackages.go_1_25;
  };

  buildGo126Module = callPackage ../build-support/go/module.nix {
    go = buildPackages.go_1_26;
  };

  buildGo127Module = callPackage ../build-support/go/module.nix {
    go = buildPackages.go_1_27;
  };

  buildGoLatestModule = buildGo126Module;
  buildGoModule = buildGo126Module;
  buildGraalvmNativeImage = callPackage ../build-support/build-graalvm-native-image { };
  buildHomeAssistantComponent = callPackage ../servers/home-assistant/build-custom-component { };
  buildLakePackage = callPackage ../build-support/lake { };

  buildMozillaMach =
    opts: callPackage (import ../build-support/build-mozilla-mach/default.nix opts) { };

  buildNavidromePlugin = callPackage ../by-name/na/navidrome/plugins/build-plugin.nix { };
  buildNimPackage = callPackage ../build-support/build-nim-package.nix { };
  buildNimSbom = callPackage ../build-support/build-nim-sbom.nix { };
  buildNpmPackage = callPackage ../build-support/node/build-npm-package { };
  buildPgrxExtension = callPackage ../development/tools/rust/cargo-pgrx/buildPgrxExtension.nix { };
  buildRubyGem = callPackage ../development/ruby-modules/gem { };

  buildRustCrate =
    let
      # Returns a true if the builder's rustc was built with support for the target.
      targetAlreadyIncluded = lib.elem stdenv.hostPlatform.rust.rustcTarget (
        lib.splitString "," (
          lib.removePrefix "--target=" (
            lib.elemAt (lib.filter (
              f: lib.hasPrefix "--target=" f
            ) pkgsBuildBuild.rustc.unwrapped.configureFlags) 0
          )
        )
      );
    in
    callPackage ../build-support/rust/build-rust-crate (
      lib.optionalAttrs (stdenv.hostPlatform.libc == null) {
        stdenv = stdenvNoCC; # Some build targets without libc will fail to evaluate with a normal stdenv.
      }
      // (
        if targetAlreadyIncluded then
          # Optimization
          {
            inherit (pkgsBuildBuild) rustc cargo;
          }
        else
          {
            inherit (pkgsBuildHost) rustc cargo;
          }
      )
    );

  buildRustCrateHelpers = callPackage ../build-support/rust/build-rust-crate/helpers.nix { };
  buildTeleport = callPackage ../build-support/teleport { };
  buildTypstPackage = callPackage ../build-support/build-typst-package.nix { };
  buildVscode = callPackage ../applications/editors/vscode/generic.nix { };
  buildWasmBindgenCli = callPackage ../build-support/wasm-bindgen-cli { };

  buildbotPackages = recurseIntoAttrs (
    callPackage ../development/tools/continuous-integration/buildbot { }
  );

  buildcatrust = with python3.pkgs; toPythonApplication buildcatrust;
  buildifier = bazel-buildtools;

  buildkite-test-collector-rust =
    callPackage ../development/tools/continuous-integration/buildkite-test-collector-rust
      {
      };

  buildozer = bazel-buildtools;
  bump2version = with python3Packages; toPythonApplication bump2version;
  bundler-audit = callPackage ../tools/security/bundler-audit { };
  bundlerApp = callPackage ../development/ruby-modules/bundler-app { };
  bundlerEnv = callPackage ../development/ruby-modules/bundler-env { };
  bundlerUpdateScript = callPackage ../development/ruby-modules/bundler-update-script { };
  bundlewrap = with python3.pkgs; toPythonApplication bundlewrap;

  busybox = callPackage ../os-specific/linux/busybox {
    # Fixes libunwind from being dynamically linked to a static binary.
    stdenv =
      if (stdenv.targetPlatform.useLLVM or false) then
        overrideCC stdenv buildPackages.llvmPackages.clangNoLibcxx
      else
        stdenv;
  };

  busybox-sandbox-shell = callPackage ../os-specific/linux/busybox/sandbox-shell.nix { };
  bzip2 = callPackage ../tools/compression/bzip2 { };
  c-aresMinimal = callPackage ../by-name/c-/c-ares/package.nix { withCMake = false; };
  cabal-install = haskell.lib.compose.justStaticExecutables haskellPackages.cabal-install;

  cabal2nix-unwrapped = haskell.lib.compose.justStaticExecutables (
    haskellPackages.generateOptparseApplicativeCompletions [ "cabal2nix" ] haskellPackages.cabal2nix
  );

  ### SCIENCE / MATH
  caffe = callPackage ../applications/science/math/caffe (
    {
      blas = openblas;
      opencv4 = opencv4WithoutCuda; # Used only for image loading.
    }
    // (config.caffe or { })
  );

  cameractrls-gtk3 = cameractrls.override { withGtk = 3; };
  cameractrls-gtk4 = cameractrls.override { withGtk = 4; };
  cassandra = cassandra_4;

  cassandra_4 = callPackage ../servers/nosql/cassandra/4.nix {
    # Effective Cassandra 4.0.2 there is full Java 11 support
    #  -- https://cassandra.apache.org/doc/latest/cassandra/new/java11.html
    jre = pkgs.jdk11_headless;
  };

  cat9-wrapped = arcan.wrapper.override {
    appls = [ cat9 ];
    name = "cat9-wrapped";
  };

  cataclysm-dda = cataclysmDDA.stable.tiles;
  cataclysm-dda-git = cataclysmDDA.git.tiles;
  cataclysmDDA = callPackage ../games/cataclysm-dda { };
  cbconvert-gui = cbconvert.gui;
  cbqn = cbqn-bootstrap.phase2;

  # Below, the classic self-bootstrapping process
  cbqn-bootstrap = dontRecurseIntoAttrs {
    mbqn-source = buildPackages.mbqn.src;

    phase0 = callPackage ../development/interpreters/bqn/cbqn {
      inherit (cbqn-bootstrap) mbqn-source stdenv;
      # Not really used, but since null can be dangerous...
      bqn-interpreter = "${lib.getExe' buildPackages.mbqn "bqn"}";
      generateBytecode = false;
    };

    phase0-replxx = callPackage ../development/interpreters/bqn/cbqn {
      inherit (cbqn-bootstrap) mbqn-source stdenv;
      # Not really used, but since null can be dangerous...
      bqn-interpreter = "${lib.getExe' buildPackages.mbqn "bqn"}";
      enableReplxx = true;
      generateBytecode = false;
    };

    phase1 = callPackage ../development/interpreters/bqn/cbqn {
      inherit (cbqn-bootstrap) mbqn-source stdenv;
      bqn-interpreter = "${lib.getExe' buildPackages.cbqn-bootstrap.phase0 "cbqn"}";
      generateBytecode = true;
    };

    phase2 = callPackage ../development/interpreters/bqn/cbqn {
      inherit (cbqn-bootstrap) mbqn-source stdenv;
      bqn-interpreter = "${lib.getExe' buildPackages.cbqn-bootstrap.phase0 "cbqn"}";
      generateBytecode = true;
    };

    phase2-replxx = callPackage ../development/interpreters/bqn/cbqn {
      inherit (cbqn-bootstrap) mbqn-source stdenv;
      bqn-interpreter = "${lib.getExe' buildPackages.cbqn-bootstrap.phase0 "cbqn"}";
      enableReplxx = true;
      generateBytecode = true;
    };

    # Use clang to compile CBQN if we aren't already.
    # CBQN's upstream primarily targets and tests clang which means using gcc
    # will result in slower binaries and on some platforms failing/broken builds.
    # See https://github.com/dzaima/CBQN/issues/12.
    #
    # Known issues:
    #
    # * CBQN using gcc is broken at runtime on i686 due to
    #   https://gcc.gnu.org/bugzilla/show_bug.cgi?id=58416,
    # * CBQN uses some CPP macros gcc doesn't like for aarch64.
    stdenv = if !stdenv.cc.isClang then clangStdenv else stdenv;
  };

  cbqn-replxx = cbqn-bootstrap.phase2-replxx;
  cbqn-standalone = cbqn-bootstrap.phase0;
  cbqn-standalone-replxx = cbqn-bootstrap.phase0-replxx;

  ccacheStdenv = lowPrio (
    makeOverridable
      (
        { stdenv, ... }@extraArgs:
        overrideCC stdenv (
          buildPackages.ccacheWrapper.override (
            {
              inherit (stdenv) cc;
            }
            // lib.optionalAttrs (builtins.hasAttr "extraConfig" extraArgs) {
              extraConfig = extraArgs.extraConfig;
            }
          )
        )
      )
      {
        inherit stdenv;
      }
  );

  # Wrapper that works as gcc or g++
  # It can be used by setting in nixpkgs config like this, for example:
  #    replaceStdenv = { pkgs }: pkgs.ccacheStdenv;
  # But if you build in chroot, you should have that path in chroot
  # If instantiated directly, it will use $HOME/.ccache as the cache directory,
  # i.e. /homeless-shelter/.ccache using the Nix daemon.
  # You should specify a different directory using an override in
  # packageOverrides to set extraConfig.
  #
  # Example using Nix daemon (i.e. multiuser Nix install or on NixOS):
  #    packageOverrides = pkgs: {
  #     ccacheWrapper = pkgs.ccacheWrapper.override {
  #       extraConfig = ''
  #         export CCACHE_COMPRESS=1
  #         export CCACHE_SLOPPINESS=random_seed
  #         export CCACHE_DIR=/var/cache/ccache
  #         export CCACHE_UMASK=007
  #       '';
  #     };
  # You can use a different directory, but whichever directory you choose
  # should be owned by user root, group nixbld with permissions 0770.
  ccacheWrapper =
    makeOverridable
      (
        { cc, extraConfig }:
        cc.override {
          cc = ccache.links {
            inherit extraConfig;
            unwrappedCC = cc.cc;
          };
        }
      )
      {
        inherit (stdenv) cc;
        extraConfig = "";
      };

  # Clozure Common Lisp
  ccl = wrapLisp {
    faslExt = "lx64fsl";

    pkg = callPackage ../development/compilers/ccl {
      inherit (buildPackages.darwin) bootstrap_cmds;
    };
  };

  cdparanoia = cdparanoia-iii;
  cdxj-indexer = with python3Packages; toPythonApplication cdxj-indexer;
  ceedling = callPackage ../development/tools/ceedling { };

  celeste-classic-pm = pkgs.celeste-classic.override {
    practiceMod = true;
  };

  celestia = callPackage ../applications/science/astronomy/celestia {
    inherit (gnome2) gtkglext;
  };

  celt = callPackage ../development/libraries/celt { };
  celt_0_5_1 = callPackage ../development/libraries/celt/0.5.1.nix { };
  celt_0_7 = callPackage ../development/libraries/celt/0.7.nix { };
  ceph-client = ceph.client;
  ceph-dev = ceph;

  certbot-full = certbot.withPlugins (
    cp: with cp; [
      # FIXME unbreak certbot-dns-cloudflare
      certbot-dns-google
      certbot-dns-inwx
      certbot-dns-ovh
      certbot-dns-rfc2136
      certbot-dns-route53
      certbot-dns-wedos
      certbot-nginx
    ]
  );

  certipy = with python3Packages; toPythonApplication certipy-ad;
  cffconvert = python3Packages.toPythonApplication python3Packages.cffconvert;
  cgal_5 = callPackage ../by-name/cg/cgal/5.nix { };
  charles = charles5;
  checkpointBuildTools = callPackage ../build-support/checkpoint-build.nix { };
  chickenPackages = dontRecurseIntoAttrs chickenPackages_5;
  chickenPackages_4 = recurseIntoAttrs (callPackage ../development/compilers/chicken/4 { });
  chickenPackages_5 = recurseIntoAttrs (callPackage ../development/compilers/chicken/5 { });
  chromedriver = callPackage ../development/tools/selenium/chromedriver { };
  chromium = callPackage ../applications/networking/browsers/chromium (config.chromium or { });
  chruby = callPackage ../development/tools/misc/chruby { rubies = null; };
  clang = llvmPackages.clang;
  clang-manpages = llvmPackages.clang-manpages;
  clang-tools = llvmPackages.clang-tools;
  clangMultiStdenv = overrideCC stdenv buildPackages.clang_multi;
  #Use this instead of stdenv to build with clang
  clangStdenv = if stdenv.cc.isClang then stdenv else lowPrio llvmPackages.stdenv;
  clangStdenvNoLibs = mkStdenvNoLibs clangStdenv;
  clang_18 = llvmPackages_18.clang;
  clang_19 = llvmPackages_19.clang;
  clang_20 = llvmPackages_20.clang;
  clang_21 = llvmPackages_21.clang;
  clang_22 = llvmPackages_22.clang;
  clang_multi = wrapClangMulti clang;

  # Clasp Common Lisp
  clasp-common-lisp = wrapLisp {
    faslExt = "fasl";
    pkg = callPackage ../development/compilers/clasp { };
  };

  cleanit = with python3Packages; toPythonApplication cleanit;
  clevercsv = with python3Packages; toPythonApplication clevercsv;
  clickgen = with python3Packages; toPythonApplication clickgen;
  clickhouse-cli = with python3Packages; toPythonApplication clickhouse-cli;
  clickhouse-lts = callPackage ../by-name/cl/clickhouse/lts.nix { };

  clipse-x11 = callPackage ../by-name/cl/clipse/package.nix {
    enableWayland = false;
    enableX11 = true;
  };

  # CLISP
  clisp = wrapLisp {
    faslExt = "fas";

    flags = [
      "-E"
      "UTF-8"
    ];

    pkg = callPackage ../development/interpreters/clisp { };
  };

  clojupyter = callPackage ../applications/editors/jupyter-kernels/clojupyter {
    jre = jre8;
  };

  closureInfo = callPackage ../build-support/closure-info.nix { };
  clucene-core = clucene-core_2;

  cmakeCurses = cmake.override {
    uiToolkits = [ "ncurses" ];
  };

  # can't use override - it triggers infinite recursion
  cmakeMinimal = callPackage ../by-name/cm/cmake/package.nix {
    isMinimalBuild = true;
  };

  cmakeWithGui = cmake.override {
    uiToolkits = [
      "ncurses"
      "qt5"
    ];
  };

  cmdpack = callPackages ../tools/misc/cmdpack { };

  # CMU Common Lisp
  cmucl_binary = wrapLispi686Linux {
    faslExt = "sse2f";
    pkg = pkgsi686Linux.callPackage ../development/compilers/cmucl/binary.nix { };
    program = "lisp";
  };

  cni = callPackage ../applications/networking/cluster/cni { };
  cni-plugins = callPackage ../applications/networking/cluster/cni/plugins.nix { };
  # this driver ships with pre-compiled 32-bit binary libraries
  cnijfilter_2_80 = pkgsi686Linux.callPackage ../misc/cups/drivers/cnijfilter_2_80 { };

  coccinelle = callPackage ../development/tools/misc/coccinelle {
    ocamlPackages = ocaml-ng.ocamlPackages_4_14;
  };

  coconut = with python312Packages; toPythonApplication coconut;
  code-cursor-fhs = code-cursor.fhs;
  code-cursor-fhsWithPackages = code-cursor.fhsWithPackages;
  codeblocksFull = codeblocks.override { contribPlugins = true; };

  codon = callPackage ../development/compilers/codon {
    inherit (llvmPackages) lld stdenv;
  };

  colmapWithCuda = colmap.override { cudaSupport = true; };
  colord-gtk4 = colord-gtk.override { withGtk4 = true; };
  coloredlogs = with python3Packages; toPythonApplication coloredlogs;

  comby = callPackage ../development/tools/comby {
    ocamlPackages = ocaml-ng.ocamlPackages_4_14;
  };

  comet-gog_heroic = callPackage ../by-name/co/comet-gog/package.nix { comet-gog_kind = "heroic"; };
  common-updater-scripts = callPackage ../common-updater/scripts.nix { };
  compressDrv = callPackage ../build-support/compress-drv { };
  compressDrvWeb = callPackage ../build-support/compress-drv/web.nix { };
  compressFirmwareXz = callPackage ../build-support/kernel/compress-firmware.nix { type = "xz"; };
  compressFirmwareZstd = callPackage ../build-support/kernel/compress-firmware.nix { type = "zstd"; };

  conky = callPackage ../os-specific/linux/conky (
    {
      inherit (linuxPackages.nvidia_x11.settings) libXNVCtrl;
      lua = lua5_4;
    }
    // config.conky or { }
  );

  connmanFull = connman.override {
    enableHh2serialGps = true;
    enableIospm = true;
    enableL2tp = true;
    # TODO: Why is this in `connmanFull` and not the default build? See TODO in
    # nixos/modules/services/networking/connman.nix (near the assertions)
    enableNetworkManagerCompatibility = true;
    enableTist = true;
  };

  connmanMinimal = connman.override {
    # enableDatafiles = false; # If disabled, configuration and data files are not installed
    # enableEthernet = false; # If disabled no ethernet connection can be performed
    # enableWifi = false; # If disabled no WiFi connection can be performed
    enableBluetooth = false;
    enableClient = false;
    enableDundee = false;
    enableGadget = false;
    enableLoopback = false;
    enableNeard = false;
    enableOfono = false;
    enableOpenconnect = false;
    enableOpenvpn = false;
    enablePacrunner = false;
    enablePolkit = false;
    enablePptp = false;
    enableStats = false;
    enableTools = false;
    enableVpnc = false;
    enableWireguard = false;
    enableWispr = false;
  };

  construoBase = construo.override {
    withLibGL = false;
    withLibGLU = false;
    withLibglut = false;
  };

  cookiecutter = with python3Packages; toPythonApplication cookiecutter;
  coolercontrol = recurseIntoAttrs (callPackage ../applications/system/coolercontrol { });

  copyDesktopItems = makeSetupHook {
    name = "copy-desktop-items-hook";
    meta.license = lib.licenses.mit;
  } ../build-support/setup-hooks/copy-desktop-items.sh;

  copyPkgconfigItems = makeSetupHook {
    name = "copy-pkg-config-items-hook";
    meta.license = lib.licenses.mit;
  } ../build-support/setup-hooks/copy-pkgconfig-items.sh;

  coreboot-toolchain = recurseIntoAttrs (
    callPackage ../development/tools/misc/coreboot-toolchain { }
  );

  corepack_20 = callPackage ../development/web/nodejs/corepack.nix { nodejs = nodejs-slim_20; };
  corepack_22 = callPackage ../development/web/nodejs/corepack.nix { nodejs = nodejs-slim_22; };
  corepack_24 = callPackage ../development/web/nodejs/corepack.nix { nodejs = nodejs-slim_24; };
  coreutils = callPackage ../tools/misc/coreutils { };
  # The coreutils above are built with dependencies from
  # bootstrapping. We cannot override it here, because that pulls in
  # openssl from the previous stage as well.
  coreutils-full = callPackage ../tools/misc/coreutils { minimal = false; };

  coreutils-prefixed = coreutils.override {
    singleBinary = false;
    withPrefix = true;
  };

  corretto11 = javaPackages.compiler.corretto11;
  corretto17 = javaPackages.compiler.corretto17;
  corretto21 = javaPackages.compiler.corretto21;
  corretto25 = javaPackages.compiler.corretto25;
  corsair = with python3Packages; toPythonApplication corsair-scan;
  cot = with python3Packages; toPythonApplication cot;
  couchdb3 = callPackage ../servers/http/couchdb/3.nix { };
  cplex = callPackage ../applications/science/math/cplex (config.cplex or { });

  crawlTiles = callPackage ../by-name/cr/crawl/package.nix {
    tileMode = true;
  };

  credstash = with python3Packages; toPythonApplication credstash;
  cron = isc-cron;
  crossplane = with python3Packages; toPythonApplication crossplane;
  cryptodev = linuxPackages.cryptodev;

  crystalline = callPackage ../development/tools/language-servers/crystalline {
    llvmPackages = crystal.llvmPackages;
  };

  crystfel-headless = crystfel.override { withGui = false; };
  css-html-js-minify = with python3Packages; toPythonApplication css-html-js-minify;
  csv2md = with python3Packages; toPythonApplication csv2md;
  ctags = callPackage ../development/tools/misc/ctags { };
  ctagsWrapped = callPackage ../development/tools/misc/ctags/wrapped.nix { };
  cudaPackages = recurseIntoAttrs cudaPackages_12;
  cudaPackages_12 = cudaPackages_12_9;
  cudaPackages_13 = cudaPackages_13_2;
  # TODO: move to alias
  cudatoolkit = cudaPackages.cudatoolkit;
  cups-brother-hl1110 = pkgsi686Linux.callPackage ../misc/cups/drivers/hl1110 { };
  cups-brother-hl1210w = pkgsi686Linux.callPackage ../misc/cups/drivers/hl1210w { };
  cups-brother-hl2260d = pkgsi686Linux.callPackage ../misc/cups/drivers/hl2260d { };
  cups-brother-hl3140cw = pkgsi686Linux.callPackage ../misc/cups/drivers/hl3140cw { };
  cups-brother-hll2340dw = pkgsi686Linux.callPackage ../misc/cups/drivers/hll2340dw { };
  cups-brother-hll3230cdw = pkgsi686Linux.callPackage ../misc/cups/drivers/hll3230cdw { };

  curl = curlMinimal.override {
    brotliSupport = true;
    http3Support = true;
    idnSupport = true;
    pslSupport = true;
    zstdSupport = true;
  };

  curlFull = curl.override {
    gsaslSupport = true;
    ldapSupport = true;
    pslSupport = true;
    rtmpSupport = true;
    websocketSupport = true;
  };

  curlWithGnuTls = curl.override {
    gnutlsSupport = true;
    ngtcp2 = ngtcp2-gnutls;
    opensslSupport = false;
  };

  curseofwar-sdl = curseofwar.override {
    ncurses = null;
    withSDL = true;
  };

  cutterPlugins = recurseIntoAttrs cutter.plugins;
  cve = with python3Packages; toPythonApplication cvelib;

  cvise = callPackage ../development/tools/misc/cvise {
    # cvise needs a port to latest llvm-21:
    #   https://github.com/marxin/cvise/issues/340
    inherit (llvmPackages_20) llvm libclang;
  };

  cygwin = recurseIntoAttrs (callPackages ../os-specific/cygwin { });

  czkawka-full = czkawka.wrapper.override {
    extraPackages = [ ffmpeg ];
  };

  daggerfall-unity-unfree = daggerfall-unity.override {
    pname = "daggerfall-unity-unfree";
    includeUnfree = true;
  };

  dapl = callPackage ../development/interpreters/dzaima-apl {
    buildNativeImage = false;
    jdk = jre;
    stdenv = stdenvNoCC;
  };

  dapl-native = callPackage ../development/interpreters/dzaima-apl {
    buildNativeImage = true;
    jdk = graalvmPackages.graalvm-ce;
  };

  darcs = haskell.lib.compose.disableCabalFlag "library" (
    haskell.lib.compose.justStaticExecutables haskellPackages.darcs
  );

  dart = if stdenv.hostPlatform.isLinux then dart-source else dart-bin;
  dartHooks = recurseIntoAttrs (callPackage ../build-support/dart/build-dart-application/hooks { });
  # Darwin package set
  #
  # Even though this is a set of packages not single package, use `callPackage`
  # not `callPackages` so the per-package callPackages don't have their
  # `.override` clobbered. C.F. `llvmPackages` which does the same.
  darwin = callPackage ./darwin-packages.nix { };

  darwinMinVersionHook =
    deploymentTarget:
    makeSetupHook {
      name = "darwin-deployment-target-hook-${deploymentTarget}";

      substitutions = {
        darwinMinVersionVariable = lib.escapeShellArg stdenv.hostPlatform.darwinMinVersionVariable;
        deploymentTarget = lib.escapeShellArg deploymentTarget;
      };

      meta.license = lib.licenses.mit;
    } ../os-specific/darwin/darwin-min-version-hook/setup-hook.sh;

  dataclass-wizard = with python3Packages; toPythonApplication dataclass-wizard;

  datadog-agent = callPackage ../tools/networking/dd-agent/datadog-agent.nix {
    pythonPackages = datadog-integrations-core { };
  };

  datadog-integrations-core =
    extras:
    callPackage ../tools/networking/dd-agent/integrations-core.nix {
      extraIntegrations = extras;
    };

  datadog-process-agent = callPackage ../tools/networking/dd-agent/datadog-process-agent.nix { };
  datalad = with python3Packages; toPythonApplication datalad;
  datalad-gooey = with python3Packages; toPythonApplication datalad-gooey;
  datasette = with python3Packages; toPythonApplication datasette;

  davinci-resolve-studio = callPackage ../by-name/da/davinci-resolve/package.nix {
    studioVariant = true;
  };

  davix-copy = davix.override { enableThirdPartyCopy = true; };
  # Make bdb5 the default as it is the last release under the custom
  # bsd-like license
  db = db5;
  db4 = db48;
  db48 = callPackage ../development/libraries/db/db-4.8.nix { };
  db5 = db53;
  db53 = callPackage ../development/libraries/db/db-5.3.nix { };
  db6 = db60;
  db60 = callPackage ../development/libraries/db/db-6.0.nix { };
  db62 = callPackage ../development/libraries/db/db-6.2.nix { };
  dblatexFull = dblatex.override { enableAllFeatures = true; };

  dbqn-native = dbqn.override {
    buildNativeImage = true;
    jre = graalvmPackages.graalvm-ce;
  };

  dbt = with python3Packages; toPythonApplication dbt-core;
  dconf2nix = callPackage ../development/tools/haskell/dconf2nix { };
  dcp375cw-cupswrapper = (callPackage ../misc/cups/drivers/brother/dcp375cw { }).cupswrapper;
  dcp375cwlpr = (pkgsi686Linux.callPackage ../misc/cups/drivers/brother/dcp375cw { }).driver;
  dcp9020cdw-cupswrapper = (callPackage ../misc/cups/drivers/brother/dcp9020cdw { }).cupswrapper;
  dcp9020cdwlpr = (pkgsi686Linux.callPackage ../misc/cups/drivers/brother/dcp9020cdw { }).driver;
  dcpj785dw = (pkgsi686Linux.callPackage ../misc/cups/drivers/brother/dcpj785dw { }).driver;
  dcpj785dw-cupswrapper = (callPackage ../misc/cups/drivers/brother/dcpj785dw { }).cupswrapper;
  ddnet-server = ddnet.override { buildClient = false; };

  deadbeefPlugins = recurseIntoAttrs {
    headerbar-gtk3 = callPackage ../applications/audio/deadbeef/plugins/headerbar-gtk3.nix { };
    lyricbar = callPackage ../applications/audio/deadbeef/plugins/lyricbar.nix { };
    mpris2 = callPackage ../applications/audio/deadbeef/plugins/mpris2.nix { };
    musical-spectrum = callPackage ../applications/audio/deadbeef/plugins/musical-spectrum.nix { };
    playlist-manager = callPackage ../applications/audio/deadbeef/plugins/playlist-manager.nix { };
    statusnotifier = callPackage ../applications/audio/deadbeef/plugins/statusnotifier.nix { };
    vgmstream = callPackage ../applications/audio/deadbeef/plugins/vgmstream.nix { };
    waveform-seekbar = callPackage ../applications/audio/deadbeef/plugins/waveform-seekbar.nix { };
  };

  deadd-notification-center = haskell.lib.compose.justStaticExecutables (
    haskellPackages.callPackage ../applications/misc/deadd-notification-center { }
  );

  deep-translator = with python3Packages; toPythonApplication deep-translator;
  ### SCIENCE/BIOLOGY
  deepdiff = with python3Packages; toPythonApplication deepdiff;
  default-gcc-version = 15;
  defaultCrateOverrides = callPackage ../build-support/rust/default-crate-overrides.nix { };

  defaultGemConfig = callPackage ../development/ruby-modules/gem-config {
    inherit (darwin) DarwinTools autoSignDarwinBinariesHook;
  };

  defaultPkgConfigPackages =
    # We don't want nix-env -q to enter this, because all of these are aliases.
    dontRecurseIntoAttrs (import ./pkg-config/defaultPkgConfigPackages.nix pkgs);

  dehinter = with python3Packages; toPythonApplication dehinter;
  dejavu_fonts = lowPrio (callPackage ../data/fonts/dejavu-fonts { });
  deluge-2_x = deluge;

  desktopToDarwinBundle = makeSetupHook {
    propagatedBuildInputs = [
      writeDarwinBundle
      librsvg
      imagemagick
      (onlyBin python3Packages.icnsutil)
    ];

    name = "desktop-to-darwin-bundle-hook";
    meta.license = lib.licenses.mit;
  } ../build-support/setup-hooks/desktop-to-darwin-bundle.sh;

  detect-secrets = with python3Packages; toPythonApplication detect-secrets;

  deterministic-host-uname = deterministic-uname.override {
    forPlatform = stdenv.targetPlatform; # offset by 1 so it works in nativeBuildInputs
  };

  devShellTools = callPackage ../build-support/dev-shell-tools { };
  deviceTree = callPackage ../os-specific/linux/device-tree { };
  dfhack = dwarf-fortress-packages.dwarf-fortress-full;
  dhall = haskell.lib.compose.justStaticExecutables haskellPackages.dhall;
  dhall-bash = haskell.lib.compose.justStaticExecutables haskellPackages.dhall-bash;
  dhall-docs = haskell.lib.compose.justStaticExecutables haskellPackages.dhall-docs;
  dhall-json = haskell.lib.compose.justStaticExecutables haskellPackages.dhall-json;
  dhall-lsp-server = haskell.lib.compose.justStaticExecutables haskellPackages.dhall-lsp-server;
  dhall-nix = haskell.lib.compose.justStaticExecutables haskellPackages.dhall-nix;
  dhall-nixpkgs = haskell.lib.compose.justStaticExecutables haskellPackages.dhall-nixpkgs;
  dhall-yaml = haskell.lib.compose.justStaticExecutables haskellPackages.dhall-yaml;
  dhallDirectoryToNix = callPackage ../build-support/dhall/directory-to-nix.nix { };
  dhallPackageToNix = callPackage ../build-support/dhall/package-to-nix.nix { };
  dhallPackages = recurseIntoAttrs (callPackage ./dhall-packages.nix { });
  dhallToNix = callPackage ../build-support/dhall/to-nix.nix { };

  diagrams-builder = callPackage ../tools/graphics/diagrams-builder {
    inherit (haskellPackages) ghcWithPackages diagrams-builder;
  };

  diceware = with python3Packages; toPythonApplication diceware;

  dict = callPackage ../servers/dict {
    flex = flex_2_5_35;
    libmaa = callPackage ../servers/dict/libmaa.nix { };
  };

  dictDBCollector = callPackage ../servers/dict/dictd-db-collector.nix { };
  dictdDBs = recurseIntoAttrs (callPackages ../servers/dict/dictd-db.nix { });
  diffPlugins = (callPackage ../build-support/plugins.nix { }).diffPlugins;

  diffoscopeMinimal = diffoscope.override {
    enableBloat = false;
  };

  dig = lib.addMetaAttrs { mainProgram = "dig"; } bind.dnsutils;
  dinghy = with python3Packages; toPythonApplication dinghy;
  directoryListingUpdater = callPackage ../common-updater/directory-listing-updater.nix { };
  discourse = callPackage ../servers/web-apps/discourse { };

  discourseAllPlugins = discourse.override {
    plugins = lib.filter (p: p ? pluginName) (builtins.attrValues discourse.plugins);
  };

  disnix = callPackage ../tools/package-management/disnix { };

  displaylink = callPackage ../os-specific/linux/displaylink {
    inherit (linuxPackages) evdi;
  };

  distcc = callPackage ../development/tools/misc/distcc {
    libiberty_static = libiberty.override { staticBuild = true; };
  };

  distccMasquerade =
    if stdenv.hostPlatform.isDarwin then
      null
    else
      callPackage ../development/tools/misc/distcc/masq.nix {
        binutils = binutils;
        gccRaw = gcc.cc;
      };

  distccStdenv = lowPrio (overrideCC stdenv buildPackages.distccWrapper);

  # distccWrapper: wrapper that works as gcc or g++
  # It can be used by setting in nixpkgs config like this, for example:
  #    replaceStdenv = { pkgs }: pkgs.distccStdenv;
  # But if you build in chroot, a default 'nix' will create
  # a new net namespace, and won't have network access.
  # You can use an override in packageOverrides to set extraConfig:
  #    packageOverrides = pkgs: {
  #     distccWrapper = pkgs.distccWrapper.override {
  #       extraConfig = ''
  #         DISTCC_HOSTS="myhost1 myhost2"
  #       '';
  #     };
  #
  distccWrapper = makeOverridable (
    {
      extraConfig ? "",
    }:
    wrapCC (distcc.links extraConfig)
  ) { };

  djgpp = djgpp_i586;

  djgpp_i586 = callPackage ../development/compilers/djgpp {
    stdenv = gccStdenv;
    targetArchitecture = "i586";
  };

  djgpp_i686 = lowPrio (
    callPackage ../development/compilers/djgpp {
      stdenv = gccStdenv;
      targetArchitecture = "i686";
    }
  );

  djview4 = djview;
  dkimpy = with python3Packages; toPythonApplication dkimpy;
  dmenu-rs-enable-plugins = dmenu-rs.override { enablePlugins = true; };
  dmraid = callPackage ../os-specific/linux/dmraid { lvm2 = lvm2_dmeventd; };
  dnf-plugins-core = with python3Packages; toPythonApplication dnf-plugins-core;
  dnf4 = python3Packages.callPackage ../development/python-modules/dnf4/wrapper.nix { };
  dnsutils = bind.dnsutils;
  docbook_sgml_dtd_41 = callPackage ../data/sgml+xml/schemas/sgml-dtd/docbook/4.1.nix { };
  docbook_xml_dtd_412 = callPackage ../data/sgml+xml/schemas/xml-dtd/docbook/4.1.2.nix { };
  docbook_xml_dtd_42 = callPackage ../data/sgml+xml/schemas/xml-dtd/docbook/4.2.nix { };
  docbook_xml_dtd_43 = callPackage ../data/sgml+xml/schemas/xml-dtd/docbook/4.3.nix { };
  docbook_xml_dtd_44 = callPackage ../data/sgml+xml/schemas/xml-dtd/docbook/4.4.nix { };
  docbook_xml_dtd_45 = callPackage ../data/sgml+xml/schemas/xml-dtd/docbook/4.5.nix { };
  # TODO: move this to aliases
  docbook_xsl = docbook-xsl-nons;
  docbook_xsl_ns = docbook-xsl-ns;
  dockapps = recurseIntoAttrs windowmaker.dockapps;
  docker = docker_29;
  docker-buildx = callPackage ../applications/virtualization/docker/buildx.nix { };
  docker-client = docker.override { clientOnly = true; };
  docker-compose = callPackage ../applications/virtualization/docker/compose.nix { };
  docker-gc = callPackage ../applications/virtualization/docker/gc.nix { };
  docker-sbom = callPackage ../applications/virtualization/docker/sbom.nix { };
  dockerAutoLayer = callPackage ../build-support/docker/auto-layer.nix { };
  dockerMakeLayers = callPackage ../build-support/docker/make-layers.nix { };

  dockerTools = callPackage ../build-support/docker {
    writePython3 = buildPackages.writers.writePython3;
  };

  documentation-highlighter = callPackage ../misc/documentation-highlighter { };
  docutils = with python3Packages; toPythonApplication docutils;
  dodgy = with python3Packages; toPythonApplication dodgy;
  doit = with python3Packages; toPythonApplication doit;
  dot2tex = with python3.pkgs; toPythonApplication dot2tex;
  dotnet-aspnetcore = dotnetCorePackages.aspnetcore_8_0;
  dotnet-aspnetcore_10 = dotnetCorePackages.aspnetcore_10_0;
  dotnet-aspnetcore_11 = dotnetCorePackages.aspnetcore_11_0;
  dotnet-aspnetcore_6 = dotnetCorePackages.aspnetcore_6_0-bin;
  dotnet-aspnetcore_7 = dotnetCorePackages.aspnetcore_7_0-bin;
  dotnet-aspnetcore_8 = dotnetCorePackages.aspnetcore_8_0;
  dotnet-aspnetcore_9 = dotnetCorePackages.aspnetcore_9_0;
  dotnet-runtime = dotnetCorePackages.runtime_8_0;
  dotnet-runtime_10 = dotnetCorePackages.runtime_10_0;
  dotnet-runtime_11 = dotnetCorePackages.runtime_11_0;
  dotnet-runtime_6 = dotnetCorePackages.runtime_6_0-bin;
  dotnet-runtime_7 = dotnetCorePackages.runtime_7_0-bin;
  dotnet-runtime_8 = dotnetCorePackages.runtime_8_0;
  dotnet-runtime_9 = dotnetCorePackages.runtime_9_0;
  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  dotnet-sdk_10 = dotnetCorePackages.sdk_10_0;
  dotnet-sdk_11 = dotnetCorePackages.sdk_11_0;
  dotnet-sdk_6 = dotnetCorePackages.sdk_6_0-bin;
  dotnet-sdk_7 = dotnetCorePackages.sdk_7_0-bin;
  dotnet-sdk_8 = dotnetCorePackages.sdk_8_0;
  dotnet-sdk_9 = dotnetCorePackages.sdk_9_0;
  # Dotnet
  dotnetCorePackages = recurseIntoAttrs (callPackage ../development/compilers/dotnet { });
  dotnetPackages = recurseIntoAttrs (callPackage ./dotnet-packages.nix { });

  dovecot_2_3 = callPackage ../by-name/do/dovecot/2.3.nix {
    dovecot_pigeonhole = dovecot_pigeonhole_0_5;
  };

  dovecot_2_4 = dovecot;

  dovecot_pigeonhole_0_5 = callPackage ../by-name/do/dovecot_pigeonhole/0.5.nix {
    dovecot = dovecot_2_3;
  };

  dovecot_pigeonhole_2_4 = dovecot_pigeonhole;
  doxygen_gui = lowPrio (doxygen.override { withGui = true; });
  dprint-plugins = recurseIntoAttrs (callPackage ../by-name/dp/dprint/plugins { });
  drake = callPackage ../development/tools/build-managers/drake { };

  drawpile-server-headless = drawpile.override {
    buildClient = false;
    buildServerGui = false;
  };

  drawterm-wayland = callPackage ../by-name/dr/drawterm/package.nix { withWayland = true; };

  # Multi-arch "drivers" which we want to build for i686.
  driversi686Linux = recurseIntoAttrs {
    inherit (pkgsi686Linux)
      intel-media-driver
      intel-vaapi-driver
      mesa
      mesa-demos
      libva-vdpau-driver
      libvdpau-va-gl
      vdpauinfo
      ;
  };

  duden = python3Packages.toPythonApplication python3Packages.duden;

  dune_2 = callPackage ../by-name/du/dune/package.nix {
    version = "2.9.3";
  };

  dune_3 = callPackage ../by-name/du/dune/package.nix { };

  durden-wrapped = arcan.wrapper.override {
    appls = [ durden ];
    name = "durden-wrapped";
  };

  dvc = with python3.pkgs; toPythonApplication dvc;

  dvc-with-remotes = dvc.override {
    enableAWS = true;
    enableAzure = true;
    enableGoogle = true;
    enableSSH = true;
  };

  dvtm = callPackage ../tools/misc/dvtm {
    # if you prefer a custom config, write the config.h in dvtm.config.h
    # and enable
    # customConfig = builtins.readFile ./dvtm.config.h;
  };

  dvtm-unstable = callPackage ../tools/misc/dvtm/unstable.nix { };
  dwarf-fortress-packages = recurseIntoAttrs (callPackage ../games/dwarf-fortress { });
  dwarfdump = libdwarf.bin;

  dysnomia = callPackage ../tools/package-management/disnix/dysnomia (
    config.disnix or {
      inherit (python3Packages) supervisor;
    }
  );

  easycrypt = callPackage ../applications/science/logic/easycrypt {
    why3 = pkgs.why3.override {
      coqPackages = {
        coq = null;
        flocq = null;
      };

      ideSupport = false;
    };
  };

  easycrypt-runtest = callPackage ../applications/science/logic/easycrypt/runtest.nix { };
  easyocr = with python3.pkgs; toPythonApplication easyocr;

  # Embeddable Common Lisp
  ecl = wrapLisp {
    faslExt = "fas";
    pkg = callPackage ../development/compilers/ecl { };
  };

  ecl_16_1_2 = wrapLisp {
    faslExt = "fas";
    pkg = callPackage ../development/compilers/ecl/16.1.2.nix { };
  };

  eclipses = recurseIntoAttrs (callPackage ../applications/editors/eclipse { });

  ekrhyper = callPackage ../applications/science/logic/ekrhyper {
    ocaml = ocaml-ng.ocamlPackages_4_14_unsafe_string.ocaml;
  };

  elasticsearch = elasticsearch7;

  elasticsearch7 = callPackage ../servers/search/elasticsearch/7.x.nix {
    jre_headless = jdk11_headless; # TODO: remove override https://github.com/NixOS/nixpkgs/pull/89731
    util-linux = util-linuxMinimal;
  };

  elasticsearchPlugins = recurseIntoAttrs (
    callPackage ../servers/search/elasticsearch/plugins.nix { }
  );

  electron = electron_41;
  electron-bin = electron_41-bin;
  electron-chromedriver = electron-chromedriver_41;
  electron-source = callPackage ../development/tools/electron { };
  electrum = libsForQt5.callPackage ../applications/misc/electrum { };
  electrum-grs = libsForQt5.callPackage ../applications/misc/electrum/grs.nix { };
  electrum-ltc = libsForQt5.callPackage ../applications/misc/electrum/ltc.nix { };

  elementsd = elements.override {
    withGui = false;
  };

  # Provided by libc on Operating Systems that use the Extensible Linker Format.
  elf-header = if stdenv.hostPlatform.isElf then null else elf-header-real;
  # The latest version used by elasticsearch, logstash, kibana and the the beats from elastic.
  # When updating make sure to update all plugins or they will break!
  elk7Version = "7.17.27";
  elm2nix = haskell.lib.compose.justStaticExecutables haskellPackages.elm2nix;
  elmPackages = recurseIntoAttrs (callPackage ../development/compilers/elm { });
  emacs = emacs30;
  emacs-gtk = emacs30-gtk3;
  emacs-macport = emacs30-macport;
  emacs-nox = emacs30-nox;
  emacs-pgtk = emacs30-pgtk;

  # We want emacsPackages to be visible in search but not be build on hydra
  emacsPackages = recurseIntoAttrsWith {
    eval = false;
    hydra = false;
  } emacs.pkgs;

  emacsPackagesFor =
    emacs:
    import ./emacs-packages.nix {
      inherit lib;
      emacs' = emacs;
      pkgs' = pkgs; # default pkgs used for bootstrapping the emacs package set
    };

  emborg = python3Packages.callPackage ../development/python-modules/emborg { };

  ### LUA interpreters
  emiluaPlugins = recurseIntoAttrs (
    callPackage ./emilua-plugins.nix { } (callPackage ../development/interpreters/emilua { })
  );

  emscripten = callPackage ../development/compilers/emscripten {
    llvmPackages = llvmPackages_22;
  };

  emscriptenPackages = recurseIntoAttrs (callPackage ./emscripten-packages.nix { });

  emscriptenStdenv = stdenv // {
    mkDerivation = buildEmscriptenPackage;
  };

  # intended to be used like nix-build -E 'with import <nixpkgs> { }; enableDebugging fooPackage'
  enableDebugging = pkg: pkg.override { stdenv = stdenvAdapters.keepDebugInfo pkg.stdenv; };

  enableGCOVInstrumentation = makeSetupHook {
    name = "enable-gcov-instrumentation-hook";
    meta.license = lib.licenses.mit;
  } ../build-support/setup-hooks/enable-coverage-instrumentation.sh;

  enchant = enchant_2;
  enlightenment = recurseIntoAttrs (callPackage ../desktops/enlightenment { });
  # Zip file format only allows times after year 1980, which makes e.g. Python
  # wheel building fail with:
  # ValueError: ZIP does not support timestamps before 1980
  ensureNewerSourcesForZipFilesHook = ensureNewerSourcesHook { year = "1980"; };

  ensureNewerSourcesHook =
    { year }:
    makeSetupHook
      {
        name = "ensure-newer-sources-hook";
        meta.license = lib.licenses.mit;
      }
      (
        writeScript "ensure-newer-sources-hook.sh" ''
          postUnpackHooks+=(_ensureNewerSources)
          _ensureNewerSources() {
            local r=$sourceRoot
            # Avoid passing option-looking directory to find. The example is diffoscope-269:
            #   https://salsa.debian.org/reproducible-builds/diffoscope/-/issues/378
            [[ $r == -* ]] && r="./$r"
            '${findutils}/bin/find' "$r" \
              '!' -newermt '${year}-01-01' -exec touch -h -d '${year}-01-02' '{}' '+'
          }
        ''
      );

  eprover-ho = eprover.override { enableHO = true; };
  error-inject = recurseIntoAttrs (callPackages ../os-specific/linux/error-inject { });

  espanso-wayland = espanso.override {
    waylandSupport = !stdenv.hostPlatform.isDarwin;
    x11Support = false;
  };

  espeak = espeak-ng;

  evilwm = callPackage ../applications/window-managers/evilwm {
    patches = config.evilwm.patches or [ ];
  };

  evolution = callPackage ../applications/networking/mailreaders/evolution/evolution { };

  evolution-data-server-gtk4 = evolution-data-server.override {
    withGtk3 = false;
    withGtk4 = true;
  };

  evolutionWithPlugins =
    callPackage ../applications/networking/mailreaders/evolution/evolution/wrapper.nix
      {
        plugins = [
          evolution
          evolution-ews
        ];
      };

  executor = with python3Packages; toPythonApplication executor;
  exiftool = perlPackages.ImageExifTool;
  expect = tclPackages.expect;

  experienced-pixel-dungeon =
    callPackage ../by-name/sh/shattered-pixel-dungeon/experienced-pixel-dungeon
      { };

  expidus = recurseIntoAttrs (
    callPackages ../desktops/expidus {
      # Use the Nix built Flutter Engine for testing.
      # Also needed when we eventually package Genesis Shell.
      flutterPackages = flutterPackages-source;
    }
  );

  factor-lang = factor-lang-0_101;
  factor-lang-0_100 = factorPackages-0_100.factor-lang;
  factor-lang-0_101 = factorPackages-0_101.factor-lang;
  factor-lang-0_99 = factorPackages-0_99.factor-lang;
  factorPackages = factorPackages-0_101;

  factorPackages-0_100 = callPackage ./factor-packages.nix {
    factor-unwrapped = callPackage ../development/compilers/factor-lang/0.100.nix {
      stdenv = clangStdenv;
    };
  };

  factorPackages-0_101 = callPackage ./factor-packages.nix {
    factor-unwrapped = callPackage ../development/compilers/factor-lang/0.101.nix {
      stdenv = clangStdenv;
    };
  };

  factorPackages-0_99 = callPackage ./factor-packages.nix {
    factor-unwrapped = callPackage ../development/compilers/factor-lang/0.99.nix { };
  };

  factorio-demo = factorio.override { releaseType = "demo"; };

  factorio-demo-experimental = factorio.override {
    experimental = true;
    releaseType = "demo";
  };

  factorio-experimental = factorio.override {
    experimental = true;
    releaseType = "alpha";
  };

  factorio-headless = factorio.override { releaseType = "headless"; };

  factorio-headless-experimental = factorio.override {
    experimental = true;
    releaseType = "headless";
  };

  factorio-space-age = factorio.override { releaseType = "expansion"; };

  factorio-space-age-experimental = factorio.override {
    experimental = true;
    releaseType = "expansion";
  };

  factorio-utils = callPackage ../by-name/fa/factorio/utils.nix { };

  faissWithCuda = faiss.override {
    cudaSupport = true;
  };

  fasm = pkgsi686Linux.callPackage ../development/compilers/fasm {
    inherit (stdenv.hostPlatform) isx86_64;
  };

  fasm-bin = callPackage ../development/compilers/fasm/bin.nix { };
  # This is not intended for use in nixpkgs but for providing a faster-running
  # compiler to nixpkgs users by building gcc with reproducibility-breaking
  # profile-guided optimizations
  fastStdenv = overrideCC gccStdenv (wrapNonDeterministicGcc gccStdenv buildPackages.gcc_latest);
  faust = faust2;

  fbc =
    if stdenv.hostPlatform.isDarwin then
      callPackage ../development/compilers/fbc/mac-bin.nix { }
    else
      callPackage ../development/compilers/fbc { };

  fceux-qt5 = fceux.override { ___qtVersion = "5"; };
  fceux-qt6 = fceux.override { ___qtVersion = "6"; };
  fedora-backgrounds = recurseIntoAttrs (callPackage ../data/misc/fedora-backgrounds { });
  feishin-web = feishin.override { webVersion = true; };

  ferdium = callPackage ../applications/networking/instant-messengers/ferdium {
    mkFranzDerivation = callPackage ../applications/networking/instant-messengers/franz/generic.nix { };
  };

  fetchCrate = callPackage ../build-support/rust/fetchcrate.nix { };

  fetchDebianPatch = callPackage ../build-support/fetchdebianpatch { } // {
    tests = pkgs.tests.fetchDebianPatch;
  };

  fetchDockerConfig = callPackage ../build-support/fetchdocker/fetchDockerConfig.nix { };
  fetchDockerLayer = callPackage ../build-support/fetchdocker/fetchDockerLayer.nix { };

  fetchFirefoxAddon = callPackage ../build-support/fetchfirefoxaddon { } // {
    tests = pkgs.tests.fetchFirefoxAddon;
  };

  fetchFrom9Front = callPackage ../build-support/fetch9front { };
  fetchFromBitbucket = callPackage ../build-support/fetchbitbucket { };
  fetchFromCodeberg = callPackage ../build-support/fetchcodeberg { };
  fetchFromForgejo = fetchFromGitea;
  fetchFromGitHub = callPackage ../build-support/fetchgithub { };
  fetchFromGitLab = callPackage ../build-support/fetchgitlab { };
  fetchFromGitea = callPackage ../build-support/fetchgitea { };
  fetchFromGitiles = callPackage ../build-support/fetchgitiles { };
  fetchFromRadicle = callPackage ../build-support/fetchradicle { };
  fetchFromRepoOrCz = callPackage ../build-support/fetchrepoorcz { };
  fetchFromSavannah = callPackage ../build-support/fetchsavannah { };
  fetchFromSourcehut = callPackage ../build-support/fetchsourcehut { };
  fetchItchIo = callPackage ../build-support/fetchitchio { };
  fetchMavenArtifact = callPackage ../build-support/fetchmavenartifact { };
  fetchNextcloudApp = callPackage ../build-support/fetchnextcloudapp { };
  fetchNuGet = callPackage ../build-support/dotnet/fetchnuget { };
  fetchPypi = callPackage ../build-support/fetchpypi { };
  fetchPypiLegacy = callPackage ../build-support/fetchpypilegacy { };
  fetchRadiclePatch = callPackage ../build-support/fetchradiclepatch { };
  fetchRepoProject = callPackage ../build-support/fetchrepoproject { };
  fetchbzr = callPackage ../build-support/fetchbzr { };

  fetchcvs =
    if
      stdenv.buildPlatform != stdenv.hostPlatform
    # hack around splicing being crummy with things that (correctly) don't eval.
    then
      buildPackages.fetchcvs
    else
      callPackage ../build-support/fetchcvs { };

  fetchdarcs = callPackage ../build-support/fetchdarcs { };
  fetchdocker = callPackage ../build-support/fetchdocker { };
  fetchfossil = callPackage ../build-support/fetchfossil { };

  fetchgit =
    (callPackage ../build-support/fetchgit {
      cacert = buildPackages.cacert;
      git = buildPackages.gitMinimal;
      git-lfs = buildPackages.git-lfs;
    })
    // {
      # fetchgit is a function, so we use // instead of passthru.
      tests = pkgs.tests.fetchgit;
    };

  fetchgitLocal = callPackage ../build-support/fetchgitlocal { };
  fetchgx = callPackage ../build-support/fetchgx { };
  fetchhg = callPackage ../build-support/fetchhg { };
  fetchipfs = callPackage ../build-support/fetchipfs { };
  fetchmtn = callPackage ../build-support/fetchmtn (config.fetchmtn or { });

  fetchpatch =
    callPackage ../build-support/fetchpatch {
      # 0.3.4 would change hashes: https://github.com/NixOS/nixpkgs/issues/25154
      patchutils = __splicedPackages.patchutils_0_3_3;
    }
    // {
      version = 1;
      tests = pkgs.tests.fetchpatch;
    };

  fetchpatch2 =
    callPackage ../build-support/fetchpatch {
      patchutils = __splicedPackages.patchutils_0_4_2;
    }
    // {
      version = 2;
      tests = pkgs.tests.fetchpatch2;
    };

  fetchpijul = callPackage ../build-support/fetchpijul { };
  fetchs3 = callPackage ../build-support/fetchs3 { };

  fetchsvn =
    if
      stdenv.buildPlatform != stdenv.hostPlatform
    # hack around splicing being crummy with things that (correctly) don't eval.
    then
      buildPackages.fetchsvn
    else
      callPackage ../build-support/fetchsvn { };

  fetchsvnrevision = import ../build-support/fetchsvnrevision runCommand subversion;
  fetchsvnssh = callPackage ../build-support/fetchsvnssh { };
  fetchtorrent = callPackage ../build-support/fetchtorrent { };

  # `fetchurl' downloads a file from the network.
  fetchurl =
    if stdenv.buildPlatform != stdenv.hostPlatform then
      buildPackages.fetchurl # No need to do special overrides twice,
    else
      makeOverridable (import ../build-support/fetchurl) {
        inherit lib stdenvNoCC buildPackages;
        inherit cacert;
        inherit (config) hashedMirrors rewriteURL;

        curl = buildPackages.curlMinimal.override (old: rec {
          # break dependency cycles
          fetchurl = stdenv.fetchurlBoot;

          # On darwin, libkrb5 needs bootstrap_cmds which would require
          # converting many packages to fetchurl_boot to avoid evaluation cycles.
          # So turn gssSupport off there, and on Windows.
          # On other platforms, keep the previous value.
          gssSupport =
            if stdenv.hostPlatform.isDarwin || stdenv.hostPlatform.isWindows then
              false
            else
              old.gssSupport or true; # `? true` is the default

          libkrb5 = buildPackages.krb5.override {
            inherit pkg-config perl openssl;
            byacc = buildPackages.byacc.override { fetchurl = stdenv.fetchurlBoot; };
            fetchurl = stdenv.fetchurlBoot;
            keyutils = buildPackages.keyutils.override { fetchurl = stdenv.fetchurlBoot; };
            withLibedit = false;
          };

          libssh2 = buildPackages.libssh2.override {
            inherit zlib openssl;
            fetchurl = stdenv.fetchurlBoot;
          };

          nghttp2 = buildPackages.nghttp2.override {
            inherit pkg-config;
            enableApp = false; # curl just needs libnghttp2
            enableTests = false; # avoids bringing `cunit` and `tzdata` into scope
            fetchurl = stdenv.fetchurlBoot;
          };

          openssl = buildPackages.openssl.override {
            inherit perl;

            buildPackages = {
              inherit perl;

              coreutils = buildPackages.coreutils.override {
                inherit perl;
                aclSupport = false;
                attrSupport = false;
                fetchurl = stdenv.fetchurlBoot;
                gmpSupport = false;
                xz = buildPackages.xz.override { fetchurl = stdenv.fetchurlBoot; };
              };
            };

            fetchurl = stdenv.fetchurlBoot;
          };

          perl = buildPackages.perl.override {
            inherit zlib;
            fetchurl = stdenv.fetchurlBoot;
          };

          pkg-config = buildPackages.pkg-config.override (old: {
            pkg-config = old.pkg-config.override {
              fetchurl = stdenv.fetchurlBoot;
            };
          });

          zlib = buildPackages.zlib.override { fetchurl = stdenv.fetchurlBoot; };
        });
      };

  fetchzip = callPackage ../build-support/fetchzip { } // {
    tests = pkgs.tests.fetchzip;
  };

  # NOTE: Override and set useIcon = false to use Awk instead of Icon.
  fffuu = haskell.lib.compose.justStaticExecutables (
    haskellPackages.callPackage ../tools/misc/fffuu { }
  );

  fftwFloat = fftwSinglePrec; # the configure option is just an alias
  fftwLongDouble = fftw.override { precision = "long-double"; };
  fftwMpi = fftw.override { enableMpi = true; };

  # Need gcc >= 4.6.0 to build with FFTW with quad precision, but Darwin defaults to Clang
  fftwQuad = fftw.override {
    precision = "quad-precision";
    stdenv = gccStdenv;
  };

  fftwSinglePrec = fftw.override { precision = "single"; };

  file = callPackage ../tools/misc/file {
    inherit (windows) libgnurx;
  };

  filebeat = filebeat7;
  filecheck = with python3Packages; toPythonApplication filecheck;

  findXMLCatalogs = makeSetupHook {
    name = "find-xml-catalogs-hook";
    meta.license = lib.licenses.mit;
  } ../build-support/setup-hooks/find-xml-catalogs.sh;

  findutils = callPackage ../tools/misc/findutils { };
  firefox = wrapFirefox firefox-unwrapped { };
  firefox-beta = wrapFirefox firefox-beta-unwrapped { };

  firefox-beta-unwrapped =
    import ../applications/networking/browsers/firefox/packages/firefox-beta.nix
      {
        inherit
          stdenv
          lib
          callPackage
          fetchurl
          nixosTests
          buildMozillaMach
          ;
      };

  firefox-bin = wrapFirefox firefox-bin-unwrapped {
    pname = "firefox-bin";
  };

  firefox-bin-unwrapped = callPackage ../applications/networking/browsers/firefox-bin {
    inherit (firefox-unwrapped.passthru) applicationName;
    generated = import ../applications/networking/browsers/firefox-bin/release_sources.nix;
  };

  firefox-devedition = wrapFirefox firefox-devedition-unwrapped { };

  firefox-devedition-unwrapped =
    import ../applications/networking/browsers/firefox/packages/firefox-devedition.nix
      {
        inherit
          stdenv
          lib
          callPackage
          fetchurl
          nixosTests
          buildMozillaMach
          ;
      };

  firefox-esr = firefox-esr-140;

  firefox-esr-140 = wrapFirefox firefox-esr-140-unwrapped {
    icon = "firefox-esr";
    nameSuffix = "-esr";
    wmClass = "firefox-esr";
  };

  firefox-esr-140-unwrapped =
    import ../applications/networking/browsers/firefox/packages/firefox-esr-140.nix
      {
        inherit
          stdenv
          lib
          callPackage
          fetchurl
          nixosTests
          buildMozillaMach
          ;
      };

  firefox-esr-unwrapped = firefox-esr-140-unwrapped;
  firefox-mobile = callPackage ../applications/networking/browsers/firefox/mobile-config.nix { };

  firefox-unwrapped = import ../applications/networking/browsers/firefox/packages/firefox.nix {
    inherit
      stdenv
      lib
      callPackage
      fetchurl
      nixosTests
      buildMozillaMach
      ;
  };

  firefoxpwa = wrapFirefox firefoxpwa-unwrapped { };
  firewalld-gui = firewalld.override { withGui = true; };
  fishPlugins = recurseIntoAttrs (callPackage ../shells/fish/plugins { });
  flang = llvmPackages_20.flang;
  flang_20 = llvmPackages_20.flang;
  flang_21 = llvmPackages_21.flang;
  flang_22 = llvmPackages_22.flang;

  flatpak-builder = callPackage ../development/tools/flatpak-builder {
    binutils = binutils-unwrapped;
  };

  flex = callPackage ../development/tools/parsing/flex { };
  flex_2_5_35 = callPackage ../development/tools/parsing/flex/2.5.35.nix { };

  floorp-bin = wrapFirefox floorp-bin-unwrapped {
    pname = "floorp-bin";
  };

  fltk = fltk_1_3;
  fltk-minimal = fltk_1_3-minimal;

  fltk_1_3-minimal = fltk_1_3.override {
    withCairo = false;
    withDocs = false;
    withExamples = false;
    withGL = false;
  };

  fltk_1_4-minimal = fltk_1_4.override {
    withCairo = false;
    withDocs = false;
    withExamples = false;
    withGL = false;
    withPango = false;
  };

  fluffychat-web = fluffychat.override { targetFlutterPlatform = "web"; };
  flutter = flutterPackages.stable;
  flutter329 = flutterPackages.v3_29;
  flutter332 = flutterPackages.v3_32;
  flutter335 = flutterPackages.v3_35;
  flutter338 = flutterPackages.v3_38;
  flutter341 = flutterPackages.v3_41;
  flutter344 = flutterPackages.v3_44;
  flutterPackages = flutterPackages-bin;
  flutterPackages-bin = recurseIntoAttrs (callPackage ../development/compilers/flutter { });

  flutterPackages-source = recurseIntoAttrs (
    callPackage ../development/compilers/flutter { useNixpkgsEngine = true; }
  );

  fmt = fmt_12;
  foks-server = foks.server;
  font-awesome = font-awesome_7;
  font-awesome_4 = (callPackage ../data/fonts/font-awesome { }).v4;
  font-awesome_5 = (callPackage ../data/fonts/font-awesome { }).v5;
  font-awesome_6 = (callPackage ../data/fonts/font-awesome { }).v6;
  font-awesome_7 = (callPackage ../data/fonts/font-awesome { }).v7;
  font-v = with python3Packages; toPythonApplication font-v;
  fontbakery = with python3Packages; toPythonApplication fontbakery;
  fontconfig = callPackage ../development/libraries/fontconfig { };

  foomatic-db-ppds-withNonfreeDb = callPackage ../by-name/fo/foomatic-db-ppds/package.nix {
    withNonfreeDb = true;
  };

  forgejo-lts = callPackage ../by-name/fo/forgejo/lts.nix { };

  fossil = callPackage ../applications/version-management/fossil {
    sqlite = sqlite.override { enableDeserialize = true; };
  };

  foxdot = with python3Packages; toPythonApplication foxdot;
  fpc = callPackage ../development/compilers/fpc { };
  fpm = callPackage ../tools/package-management/fpm { };

  franz = callPackage ../applications/networking/instant-messengers/franz {
    mkFranzDerivation = callPackage ../applications/networking/instant-messengers/franz/generic.nix { };
  };

  freebsd = callPackage ../os-specific/bsd/freebsd { };
  freeciv_gtk = freeciv;

  freeciv_qt = freeciv.override {
    gtkClient = false;
    qtClient = true;
    sdl2Client = false;
  };

  freeciv_sdl2 = freeciv.override {
    gtkClient = false;
    qtClient = false;
    sdl2Client = true;
  };

  freefall = callPackage ../os-specific/linux/freefall {
    inherit (linuxPackages) kernel;
  };

  # Derivation's result is not used by nixpkgs. Useful for validation for
  # regressions of bootstrapTools on hydra and on ofborg. Example:
  #     pkgsCross.aarch64-multiplatform.freshBootstrapTools.build
  freshBootstrapTools =
    if stdenv.hostPlatform.isDarwin then
      callPackage ../stdenv/darwin/make-bootstrap-tools.nix {
        crossSystem = if stdenv.buildPlatform == stdenv.hostPlatform then null else stdenv.hostPlatform;
        localSystem = stdenv.buildPlatform;
      }
    else if stdenv.hostPlatform.isLinux then
      callPackage ../stdenv/linux/make-bootstrap-tools.nix { }
    else if stdenv.hostPlatform.isFreeBSD then
      callPackage ../stdenv/freebsd/make-bootstrap-tools.nix { }
    else
      throw "freshBootstrapTools: unknown hostPlatform ${stdenv.hostPlatform.config}";

  freshrss = callPackage ../servers/web-apps/freshrss { };
  freshrss-extensions = recurseIntoAttrs (callPackage ../servers/web-apps/freshrss/extensions { });
  frostwire-bin = callPackage ../applications/networking/p2p/frostwire/frostwire-bin.nix { };
  fts = if stdenv.hostPlatform.isMusl then musl-fts else null;
  fuse = fuse2;
  fuse2 = lowPrio (if stdenv.hostPlatform.isDarwin then macfuse-stubs else fusePackages.fuse_2);

  fuse3 = lowPrio (
    if stdenv.hostPlatform.isDarwin then
      macfuse-stubs.override { isFuse3 = true; }
    else
      fusePackages.fuse_3
  );

  fusePackages = dontRecurseIntoAttrs (
    callPackage ../os-specific/linux/fuse {
      util-linux = util-linuxMinimal;
    }
  );

  futhark = haskell.lib.compose.justStaticExecutables haskellPackages.futhark;
  fvwm = fvwm2;
  # unstable until the first 1.x release
  fwts = callPackage ../os-specific/linux/fwts { };

  gajim = callPackage ../applications/networking/instant-messengers/gajim {
    inherit (gst_all_1) gstreamer gst-plugins-base gst-libav;
    gst-plugins-good = gst_all_1.gst-plugins-good.override { gtkSupport = true; };
  };

  gambit = callPackage ../development/compilers/gambit { };
  gambit-support = callPackage ../development/compilers/gambit/gambit-support.nix { };
  gambit-unstable = callPackage ../development/compilers/gambit/unstable.nix { };

  gamescope-wsi = callPackage ../by-name/ga/gamescope/package.nix {
    enableExecutable = false;
    enableWsi = true;
  };

  gams = callPackage ../tools/misc/gams (config.gams or { });
  gamt = callPackage ../by-name/am/amtterm/package.nix { withGamt = true; };
  gancioPlugins = recurseIntoAttrs (callPackage ../by-name/ga/gancio/plugins.nix { });
  gap-full = lowPrio (gap.override { packageSet = "full"; });
  gap-minimal = lowPrio (gap.override { packageSet = "minimal"; });
  gauche = callPackage ../development/interpreters/gauche { };
  gaucheBootstrap = callPackage ../development/interpreters/gauche/boot.nix { };
  gaugePlugins = recurseIntoAttrs (callPackage ../by-name/ga/gauge/plugins { });
  gawd = python3Packages.toPythonApplication python3Packages.gawd;

  gawk = callPackage ../tools/text/gawk {
    inherit (darwin) locale;
  };

  gawk-with-extensions = callPackage ../tools/text/gawk/gawk-with-extensions.nix {
    extensions = gawkextlib.full;
  };

  gawkInteractive = gawk.override { interactive = true; };
  gawkextlib = callPackage ../tools/text/gawk/gawkextlib.nix { };
  gcc = pkgs.${"gcc${toString default-gcc-version}"};
  gcc-arm-embedded = gcc-arm-embedded-15;
  gcc-unwrapped = gcc.cc;
  gcc13Stdenv = overrideCC gccStdenv buildPackages.gcc13;
  gcc14Stdenv = overrideCC gccStdenv buildPackages.gcc14;
  gcc15Stdenv = overrideCC gccStdenv buildPackages.gcc15;
  gcc16Stdenv = overrideCC gccStdenv buildPackages.gcc16;
  gccCrossLibcStdenv = overrideCC stdenvNoCC buildPackages.gccWithoutTargetLibc;

  # This is for e.g. LLVM libraries on linux.
  gccForLibs =
    if
      stdenv.targetPlatform == stdenv.hostPlatform && targetPackages.stdenv.cc.isGNU
    # Can only do this is in the native case, otherwise we might get infinite
    # recursion if `targetPackages.stdenv.cc.cc` itself uses `gccForLibs`.
    then
      targetPackages.stdenv.cc.cc
    else
      gcc.cc;

  gccFun = callPackage ../development/compilers/gcc;
  gccMultiStdenv = overrideCC stdenv buildPackages.gcc_multi;

  gccStdenv =
    if stdenv.cc.isGNU then
      stdenv
    else
      stdenv.override {
        allowedRequisites = null;
        cc = buildPackages.gcc;
        # Remove libcxx/libcxxabi, and add clang for AS if on darwin (it uses
        # clang's internal assembler).
        extraBuildInputs = lib.optional stdenv.hostPlatform.isDarwin clang.cc;
      };

  gccStdenvNoLibs = mkStdenvNoLibs gccStdenv;

  # The GCC used to build libc for the target platform. Normal gccs will be
  # built with, and use, that cross-compiled libc.
  gccWithoutTargetLibc =
    let
      libc1 = binutilsNoLibc.libc;
    in
    (wrapCCWith {
      bintools = binutilsNoLibc;

      cc = gccFun {
        # copy-pasted
        inherit noSysDirs;

        enableShared =
          stdenv.targetPlatform.hasSharedLibraries

          # temporarily disabled due to breakage;
          # see https://github.com/NixOS/nixpkgs/pull/243249
          && !stdenv.targetPlatform.isWindows
          && !stdenv.targetPlatform.isCygwin
          && !(stdenv.targetPlatform.useLLVM or false);

        isl = if !stdenv.hostPlatform.isDarwin then isl_0_20 else null;
        langCC = stdenv.targetPlatform.isCygwin; # can't compile libcygwin1.a without C++
        libcCross = libc1;
        majorMinorVersion = toString default-gcc-version;
        profiledCompiler = false;
        reproducibleBuild = true;
        targetPackages.stdenv.cc.bintools = binutilsNoLibc;
        withoutTargetLibc = true;
      };

      extraPackages = [ ];
      libc = libc1;
    }).overrideAttrs
      (prevAttrs: {
        meta = prevAttrs.meta // {
          badPlatforms =
            (prevAttrs.meta.badPlatforms or [ ])
            ++ lib.optionals (stdenv.targetPlatform == stdenv.hostPlatform) [ stdenv.hostPlatform.system ];
        };
      });

  gcc_debug = lowPrio (
    wrapCC (
      gcc.cc.overrideAttrs {
        dontStrip = true;
      }
    )
  );

  gcc_latest = gcc16;
  gcc_multi = wrapCCMulti gcc;

  gccgo = wrapCC (
    gcc.cc.override {
      langC = true;
      langCC = true; # required for go.
      langGo = true;
      langJit = true;
      name = "gccgo";
      profiledCompiler = false;
    }
    // {
      # not supported on darwin: https://github.com/golang/go/issues/463
      meta.broken = stdenv.hostPlatform.isDarwin;
    }
  );

  gccgo13 = wrapCC (
    gcc13.cc.override {
      langC = true;
      langCC = true; # required for go.
      langGo = true;
      langJit = true;
      name = "gccgo";
      profiledCompiler = false;
    }
    // {
      # not supported on darwin: https://github.com/golang/go/issues/463
      meta.broken = stdenv.hostPlatform.isDarwin;
    }
  );

  gccgo14 = wrapCC (
    gcc14.cc.override {
      langC = true;
      langCC = true; # required for go.
      langGo = true;
      langJit = true;
      name = "gccgo";
      profiledCompiler = false;
    }
    // {
      # not supported on darwin: https://github.com/golang/go/issues/463
      meta.broken = stdenv.hostPlatform.isDarwin;
    }
  );

  gccgo15 = wrapCC (
    gcc15.cc.override {
      langC = true;
      langCC = true; # required for go.
      langGo = true;
      langJit = true;
      name = "gccgo";
      profiledCompiler = false;
    }
    // {
      # not supported on darwin: https://github.com/golang/go/issues/463
      meta.broken = stdenv.hostPlatform.isDarwin;
    }
  );

  gccgo16 = wrapCC (
    gcc16.cc.override {
      langC = true;
      langCC = true; # required for go.
      langGo = true;
      langJit = true;
      name = "gccgo";
      profiledCompiler = false;
    }
    // {
      # not supported on darwin: https://github.com/golang/go/issues/463
      meta.broken = stdenv.hostPlatform.isDarwin;
    }
  );

  # GNU Common Lisp
  gcl = wrapLisp {
    faslExt = "o";
    pkg = callPackage ../development/compilers/gcl { };
  };

  gdalMinimal = gdal.override {
    useMinimalFeatures = true;
  };

  gdbHostCpuOnly = gdb.override { hostCpuOnly = true; };
  gdown = with python3Packages; toPythonApplication gdown;

  geda = callPackage ../applications/science/electronics/geda {
    guile = guile_2_2;
  };

  geekbench_4 = callPackage ../by-name/ge/geekbench/4.nix { };
  geekbench_5 = callPackage ../by-name/ge/geekbench/5.nix { };
  geekbench_6 = geekbench;

  genealogos-api = genealogos-cli.override {
    crate = "api";
  };

  genericUpdater = callPackage ../common-updater/generic-updater.nix { };
  geoclue2-with-demo-agent = geoclue2.override { withDemoAgent = true; };

  geoipWithDatabase = makeOverridable (callPackage ../by-name/ge/geoip/package.nix) {
    drvName = "geoip-tools";
    geoipDatabase = geolite-legacy;
  };

  gerbil = callPackage ../development/compilers/gerbil { };
  gerbil-support = callPackage ../development/compilers/gerbil/gerbil-support.nix { };
  gerbil-unstable = callPackage ../development/compilers/gerbil/unstable.nix { };
  gerbilPackages-unstable = pkgs.gerbil-support.gerbilPackages-unstable; # NB: don't recurseIntoAttrs for (unstable!) libraries

  gerbv = callPackage ../applications/science/electronics/gerbv {
    cairo = cairo.override { x11Support = true; };
  };

  gettext = callPackage ../development/libraries/gettext { };

  # haskellPackages.ghc is build->host (it exposes the compiler used to build the
  # set, similarly to stdenv.cc), but pkgs.ghc should be host->target to be more
  # consistent with the gcc, gnat, clang etc. derivations
  #
  # We use targetPackages.haskellPackages.ghc if available since this also has
  # the withPackages wrapper available. In the final cross-compiled package set
  # however, targetPackages won't be populated, so we need to fall back to the
  # plain, cross-compiled compiler (which is only theoretical at the moment).
  ghc =
    targetPackages.haskellPackages.ghc or (
      # Prefer native-bignum to avoid linking issues with gmp;
      # GHC 9.10 doesn't work too well with iserv-proxy.
      if stdenv.hostPlatform.isStatic then
        haskell.compiler.native-bignum.ghc912
      # JS backend can't use GMP
      else if stdenv.targetPlatform.isGhcjs then
        haskell.compiler.native-bignum.ghc910
      else
        haskell.compiler.ghc910
    );

  ghc-standalone-archive =
    {
      haskellPackages,
      name,
      src,
      deps ? p: [ ],
    }:
    let
      inherit (haskellPackages) ghc ghcWithPackages;
      with-env = ghcWithPackages deps;
      ghcName = "${ghc.targetPrefix}ghc";
    in
    runCommand name
      {
        buildInputs = [
          with-env
          cctools
        ];
      }
      ''
        mkdir -p $out/lib
        mkdir -p $out/include
        ${ghcName} ${src} -staticlib -outputdir . -o $out/lib/${name}.a -stubdir $out/include
        for file in ${ghc}/lib/${ghcName}-${ghc.version}/include/*; do
          ln -sv $file $out/include
        done
      '';

  ghcid = haskellPackages.ghcid.bin;
  ghdl-gcc = ghdl.override { backend = "gcc"; };
  ghdl-llvm = ghdl.override { backend = "llvm"; };
  ghdl-llvm-jit = ghdl.override { backend = "llvm-jit"; };
  ghdl-mcode = ghdl.override { backend = "mcode"; };

  ghidra = callPackage ../tools/security/ghidra/build.nix {
    protobuf = protobuf_21;
  };

  ghidra-bin = callPackage ../tools/security/ghidra { };
  ghidra-extensions = recurseIntoAttrs (callPackage ../tools/security/ghidra/extensions.nix { });
  ghp-import = with python3Packages; toPythonApplication ghp-import;
  ghrepo-stats = with python3Packages; toPythonApplication ghrepo-stats;
  giac-with-xcas = giac.override { enableGUI = true; };
  gibberish-detector = with python3Packages; toPythonApplication gibberish-detector;

  gimagereader-qt = qt6Packages.callPackage ../by-name/gi/gimagereader/package.nix {
    withQt6 = true;
  };

  gimp = callPackage ../applications/graphics/gimp {
    lcms = lcms2;
  };

  gimp-with-plugins = callPackage ../applications/graphics/gimp/wrapper.nix {
    plugins = null; # All packaged plugins enabled, if not explicit plugin list supplied
  };

  gimp2 = callPackage ../applications/graphics/gimp/2.0 {
    lcms = lcms2;
    stdenv = if stdenv.cc.isGNU then gcc14Stdenv else stdenv;
  };

  gimp2-with-plugins = callPackage ../applications/graphics/gimp/wrapper.nix {
    gimpPlugins = gimp2Plugins;
    plugins = null; # All packaged plugins enabled, if not explicit plugin list supplied
  };

  gimp2Plugins = recurseIntoAttrs (
    callPackage ../applications/graphics/gimp/plugins {
      gimp = gimp2;
    }
  );

  gimpPlugins = recurseIntoAttrs (callPackage ../applications/graphics/gimp/plugins { });
  gistyc = with python3Packages; toPythonApplication gistyc;
  git-autofixup = perlPackages.GitAutofixup;
  git-credential-aol = callPackage ../by-name/gi/git-credential-email/git-credential-aol { };
  git-credential-gmail = callPackage ../by-name/gi/git-credential-email/git-credential-gmail { };
  git-credential-outlook = callPackage ../by-name/gi/git-credential-email/git-credential-outlook { };
  git-credential-yahoo = callPackage ../by-name/gi/git-credential-email/git-credential-yahoo { };

  git-doc =
    # doc attribute is not present at least for pkgsLLVM
    if (gitFull ? doc) then
      lib.addMetaAttrs {
        description = "Additional documentation for Git";

        longDescription = ''
          This package contains additional documentation (HTML and text files) that
          is referenced in the man pages of Git.
        '';
      } gitFull.doc
    else
      throw "'git-doc' can't be evaluated as 'gitFull' does not expose 'doc' attribute";

  git-filter-repo = with python3Packages; toPythonApplication git-filter-repo;
  git-msgraph = callPackage ../by-name/gi/git-credential-email/git-msgraph { };
  git-protonmail = callPackage ../by-name/gi/git-credential-email/git-protonmail { };
  git-revise = with python3Packages; toPythonApplication git-revise;

  ### APPLICATIONS/VERSION-MANAGEMENT
  # The full-featured Git.
  gitFull = git.override {
    guiSupport = true;
    sendEmailSupport = stdenv.buildPlatform == stdenv.hostPlatform;
    svnSupport = stdenv.buildPlatform == stdenv.hostPlatform;
    withLibsecret = !stdenv.hostPlatform.isDarwin;
    withSsh = true;
  };

  gitMinimal = git.override {
    curl = if stdenv.hostPlatform.isFreeBSD then curlMinimal else curl; # Needed for FreeBSD bootstrap
    osxkeychainSupport = false;
    perlSupport = false;
    pythonSupport = false;
    rustSupport = false; # Needed for bootstrap
    withManual = false;
    withpcre2 = false;
  };

  gitRepo = git-repo;
  # Git with SVN support, but without GUI.
  gitSVN = lowPrio (git.override { svnSupport = true; });
  gitUpdater = callPackage ../common-updater/git-updater.nix { };
  github-cli = gh;
  github-to-sqlite = with python3Packages; toPythonApplication github-to-sqlite;

  gitlab-ee = callPackage ../by-name/gi/gitlab/package.nix {
    gitlabEnterprise = true;
  };

  gitlab-workhorse = callPackage ../by-name/gi/gitlab/gitlab-workhorse { };
  glanceclient = with python313Packages; toPythonApplication python-glanceclient;
  glfw = glfw3;

  glfw3-minecraft = callPackage ../by-name/gl/glfw3/package.nix {
    withMinecraftPatch = true;
  };

  glibc = callPackage ../development/libraries/glibc (
    if stdenv.hostPlatform != stdenv.buildPlatform then
      {
        libgcc = callPackage ../development/libraries/gcc/libgcc {
          gcc = gccCrossLibcStdenv.cc;
          glibc = glibc.override { libgcc = null; };
          stdenvNoLibs = gccCrossLibcStdenv;
        };

        stdenv = gccCrossLibcStdenv; # doesn't compile without gcc
      }
    else
      {
        stdenv = gccStdenv; # doesn't compile without gcc
      }
  );

  glibcInfo = callPackage ../development/libraries/glibc/info.nix { };

  # Only supported on Linux and only on glibc
  glibcLocales =
    if stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isGnu then
      callPackage ../development/libraries/glibc/locales.nix {
        stdenv = if (!stdenv.cc.isGNU) then gccStdenv else stdenv;
        withLinuxHeaders = !stdenv.cc.isGNU;
      }
    else
      null;

  glibcLocalesUtf8 =
    if stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isGnu then
      callPackage ../development/libraries/glibc/locales.nix {
        allLocales = false;
        stdenv = if (!stdenv.cc.isGNU) then gccStdenv else stdenv;
        withLinuxHeaders = !stdenv.cc.isGNU;
      }
    else
      null;

  glibc_memusage = callPackage ../development/libraries/glibc {
    withGd = true;
  };

  glibc_multi = callPackage ../development/libraries/glibc/multi.nix {
    # The buildPackages is required for cross-compilation. The pkgsi686Linux set
    # has target and host always set to the same value based on target platform
    # of the current set. We need host to be same as build to correctly get i686
    # variant of glibc.
    glibc32 = pkgsi686Linux.buildPackages.glibc;
  };

  glirc = haskell.lib.compose.justStaticExecutables haskellPackages.glirc;
  glm_1_0_1 = callPackage ../by-name/gl/glm/1_0_1.nix { };
  glow-lang = pkgs.gerbilPackages-unstable.glow-lang;

  glsurf = callPackage ../applications/science/math/glsurf {
    ocamlPackages = ocaml-ng.ocamlPackages_4_14_unsafe_string;
  };

  glucose-syrup = glucose.override {
    enableUnfree = true;
  };

  gmime = gmime2;
  gmime2 = callPackage ../development/libraries/gmime/2.nix { };
  gmime3 = callPackage ../development/libraries/gmime/3.nix { };
  gmp = gmp6;
  gmp6 = callPackage ../development/libraries/gmp/6.x.nix { };
  gmpxx = gmp.override { cxx = true; };

  gmrender-resurrect = callPackage ../tools/networking/gmrender-resurrect {
    inherit (gst_all_1)
      gstreamer
      gst-plugins-base
      gst-plugins-good
      gst-plugins-bad
      gst-plugins-ugly
      gst-libav
      ;
  };

  gnat = pkgs."gnat${toString default-gcc-version}"; # When changing this, update also gnatPackages
  gnat-bootstrap = pkgs."gnat-bootstrap${toString default-gcc-version}";

  gnat-bootstrap13 = wrapCCWith {
    cc = callPackage ../development/compilers/gnat-bootstrap { majorVersion = "13"; };
    isAlireGNAT = true;
  };

  gnat-bootstrap14 = wrapCCWith {
    cc = callPackage ../development/compilers/gnat-bootstrap { majorVersion = "14"; };
    isAlireGNAT = true;
  };

  gnat-bootstrap15 = wrapCCWith {
    cc = callPackage ../development/compilers/gnat-bootstrap { majorVersion = "15"; };
    isAlireGNAT = true;
  };

  gnat-bootstrap16 = wrapCCWith {
    cc = callPackage ../development/compilers/gnat-bootstrap { majorVersion = "16"; };
    isAlireGNAT = true;
  };

  gnat13 = wrapCC (
    gcc13.cc.override {
      # As per upstream instructions building a cross compiler
      # should be done with a (native) compiler of the same version.
      # If we are cross-compiling GNAT, we may as well do the same.
      gnat-bootstrap =
        if stdenv.hostPlatform == stdenv.targetPlatform && stdenv.buildPlatform == stdenv.hostPlatform then
          buildPackages.gnat-bootstrap13
        else
          buildPackages.gnat13;

      langAda = true;
      langC = true;
      langCC = false;
      name = "gnat";
      profiledCompiler = false;

      stdenv =
        if
          stdenv.hostPlatform == stdenv.targetPlatform
          && stdenv.buildPlatform == stdenv.hostPlatform
          && stdenv.buildPlatform.isDarwin
        then
          overrideCC gccStdenv gnat-bootstrap13
        else
          stdenv;
    }
  );

  gnat13Packages = recurseIntoAttrs (callPackage ./ada-packages.nix { gnat = buildPackages.gnat13; });

  gnat14 = wrapCC (
    gcc14.cc.override {
      # As per upstream instructions building a cross compiler
      # should be done with a (native) compiler of the same version.
      # If we are cross-compiling GNAT, we may as well do the same.
      gnat-bootstrap =
        if stdenv.hostPlatform == stdenv.targetPlatform && stdenv.buildPlatform == stdenv.hostPlatform then
          buildPackages.gnat-bootstrap14
        else
          buildPackages.gnat14;

      langAda = true;
      langC = true;
      langCC = false;
      name = "gnat";
      profiledCompiler = false;

      stdenv =
        if
          stdenv.hostPlatform == stdenv.targetPlatform
          && stdenv.buildPlatform == stdenv.hostPlatform
          && stdenv.buildPlatform.isDarwin
        then
          overrideCC gccStdenv gnat-bootstrap14
        else
          stdenv;
    }
  );

  gnat14Packages = recurseIntoAttrs (callPackage ./ada-packages.nix { gnat = buildPackages.gnat14; });

  gnat15 = wrapCC (
    gcc15.cc.override {
      # As per upstream instructions building a cross compiler
      # should be done with a (native) compiler of the same version.
      # If we are cross-compiling GNAT, we may as well do the same.
      gnat-bootstrap =
        if stdenv.hostPlatform == stdenv.targetPlatform && stdenv.buildPlatform == stdenv.hostPlatform then
          buildPackages.gnat-bootstrap15
        else
          buildPackages.gnat15;

      langAda = true;
      langC = true;
      langCC = false;
      name = "gnat";
      profiledCompiler = false;

      stdenv =
        if
          stdenv.hostPlatform == stdenv.targetPlatform
          && stdenv.buildPlatform == stdenv.hostPlatform
          && stdenv.buildPlatform.isDarwin
        then
          overrideCC gccStdenv gnat-bootstrap15
        else
          stdenv;
    }
  );

  gnat15Packages = recurseIntoAttrs (callPackage ./ada-packages.nix { gnat = buildPackages.gnat15; });

  gnat16 = wrapCC (
    gcc16.cc.override {
      # As per upstream instructions building a cross compiler
      # should be done with a (native) compiler of the same version.
      # If we are cross-compiling GNAT, we may as well do the same.
      gnat-bootstrap =
        if stdenv.hostPlatform == stdenv.targetPlatform && stdenv.buildPlatform == stdenv.hostPlatform then
          buildPackages.gnat-bootstrap16
        else
          buildPackages.gnat16;

      langAda = true;
      langC = true;
      langCC = false;
      name = "gnat";
      profiledCompiler = false;

      stdenv =
        if
          stdenv.hostPlatform == stdenv.targetPlatform
          && stdenv.buildPlatform == stdenv.hostPlatform
          && stdenv.buildPlatform.isDarwin
        then
          overrideCC gccStdenv gnat-bootstrap16
        else
          stdenv;
    }
  );

  gnat16Packages = recurseIntoAttrs (callPackage ./ada-packages.nix { gnat = buildPackages.gnat16; });
  gnatPackages = pkgs."gnat${toString default-gcc-version}Packages";
  gnome = recurseIntoAttrs (callPackage ../desktops/gnome { });
  gnome-panel-with-modules = callPackage ../by-name/gn/gnome-panel/wrapper.nix { };
  gnome-session-ctl = callPackage ../by-name/gn/gnome-session/ctl.nix { };
  gnome2 = recurseIntoAttrs (callPackage ../desktops/gnome-2 { });

  gnuStdenv =
    if stdenv.cc.isGNU then
      stdenv
    else
      gccStdenv.override {
        cc = gccStdenv.cc.override {
          bintools = buildPackages.binutils;
        };
      };

  gnucap-full = gnucap.withPlugins (p: [ p.verilog ]);

  gnudatalanguage = callPackage ../development/interpreters/gnudatalanguage {
    inherit (llvmPackages) openmp;
    # MPICH currently build on Darwin
    mpi = mpich;
  };

  gnugrep = callPackage ../tools/text/gnugrep { };
  gnupatch = callPackage ../tools/text/gnupatch { };
  gnupg = gnupg24;
  gnupg1 = gnupg1compat; # use config.packageOverrides if you prefer original gnupg1
  gnupg1compat = callPackage ../tools/security/gnupg/1compat.nix { };

  gnupg24 = callPackage ../tools/security/gnupg/24.nix {
    pinentry = if stdenv.hostPlatform.isDarwin then pinentry_mac else pinentry-gtk2;
  };

  gnupgMinimal = gnupg.override {
    enableMinimal = true;
    guiSupport = false;
  };

  gnuradio = callPackage ../applications/radio/gnuradio/wrapper.nix {
    unwrapped = callPackage ../applications/radio/gnuradio {
      python = python3;
    };
  };

  gnuradioPackages = recurseIntoAttrs gnuradio.pkgs;
  gnused = callPackage ../tools/text/gnused { };
  gnvim = callPackage ../applications/editors/neovim/gnvim/wrapper.nix { };
  gnvim-unwrapped = callPackage ../applications/editors/neovim/gnvim { };
  ### DEVELOPMENT / GO
  # the unversioned attributes should always point to the same go version
  go = go_1_26;
  go2tv-lite = go2tv.override { withGui = false; };
  go_1_25 = callPackage ../development/compilers/go/1.25.nix { };
  go_1_26 = callPackage ../development/compilers/go/1.26.nix { };
  go_latest = go_1_26;

  goattracker-stereo = callPackage ../by-name/go/goattracker/package.nix {
    isStereo = true;
  };

  #GMP ex-satellite, so better keep it near gmp
  # A GMP fork
  gobject-introspection = callPackage ../development/libraries/gobject-introspection/wrapper.nix { };

  gobject-introspection-unwrapped = callPackage ../development/libraries/gobject-introspection {
    nixStoreDir = config.nix.storeDir or builtins.storeDir;
  };

  google-cloud-sdk-gce = google-cloud-sdk.override {
    with-gce = true;
  };

  google-compute-engine = with python3.pkgs; toPythonApplication google-compute-engine;

  gpac-unstable = callPackage ../by-name/gp/gpac/package.nix {
    releaseChannel = "unstable";
  };

  gparted-full = gparted.override { withAllTools = true; };
  gpm-ncurses = gpm.override { withNcurses = true; };
  gprof2dot = with python3Packages; toPythonApplication gprof2dot;

  gpsbabel-gui = gpsbabel.override {
    withDoc = true;
    withGUI = true;
  };

  gpt4all-cuda = gpt4all.override {
    cudaSupport = true;
  };

  gqrx-gr-audio = gqrx.override {
    portaudioSupport = false;
    pulseaudioSupport = false;
  };

  gqrx-portaudio = gqrx.override {
    portaudioSupport = true;
    pulseaudioSupport = false;
  };

  graalvmPackages = recurseIntoAttrs (callPackage ../development/compilers/graalvm { });
  gradle = gradle-packages.gradle.wrapped;
  gradle-packages = callPackage ../development/tools/build-managers/gradle { };
  gradle-unwrapped = gradle-packages.gradle;
  gradle_7 = gradle-packages.gradle_7.wrapped;
  gradle_7-unwrapped = gradle-packages.gradle_7;
  gradle_8 = gradle-packages.gradle_8.wrapped;
  gradle_8-unwrapped = gradle-packages.gradle_8;
  gradle_9 = gradle-packages.gradle_9.wrapped;
  gradle_9-unwrapped = gradle-packages.gradle_9;
  grafanaPlugins = recurseIntoAttrs (callPackages ../servers/monitoring/grafana/plugins { });
  grails = callPackage ../development/web/grails { jdk = null; };
  graphicsmagick-imagemagick-compat = graphicsmagick.imagemagick-compat;
  graphicsmagick_q16 = graphicsmagick.override { quantumdepth = 16; };
  graphite2 = callPackage ../development/libraries/silgraphite/graphite2.nix { };

  graphviz-nox = graphviz.override {
    withXorg = false;
  };

  graylog-6_0 = callPackage ../tools/misc/graylog/6.0.nix { };

  graylogPlugins = recurseIntoAttrs (
    callPackage ../tools/misc/graylog/plugins.nix { graylogPackage = graylog-6_0; }
  );

  gridcoin-researchd = gridcoin-research.override { withGui = false; };
  griffe = with python3Packages; toPythonApplication griffe;

  groestlcoind = groestlcoin.override {
    withGui = false;
  };

  ### SCIENCE/MOLECULAR-DYNAMICS
  gromacs = callPackage ../applications/science/molecular-dynamics/gromacs {
    fftw = fftwSinglePrec;
    singlePrec = true;
  };

  gromacsCudaMpi = lowPrio (
    gromacs.override {
      enableCuda = true;
      enableMpi = true;
      fftw = fftwSinglePrec;
      singlePrec = true;
    }
  );

  gromacsDouble = lowPrio (
    gromacs.override {
      enableCuda = false; # CUDA is only implemented for single precision
      fftw = fftw;
      singlePrec = false;
    }
  );

  gromacsDoubleMpi = lowPrio (
    gromacs.override {
      enableCuda = false; # CUDA is only implemented for single precision
      enableMpi = true;
      fftw = fftw;
      singlePrec = false;
    }
  );

  gromacsMpi = lowPrio (
    gromacs.override {
      enableMpi = true;
      fftw = fftwSinglePrec;
      singlePrec = true;
    }
  );

  gromacsPlumed = lowPrio (
    gromacs.override {
      enablePlumed = true;
      fftw = fftwSinglePrec;
      singlePrec = true;
    }
  );

  gruppled-white-cursors = gruppled-black-cursors.override { theme = "white"; };
  gruppled-white-lite-cursors = gruppled-black-lite-cursors.override { theme = "white"; };
  gruut = with python3.pkgs; toPythonApplication gruut;
  gruut-ipa = with python3.pkgs; toPythonApplication gruut-ipa;
  gruvterial-theme = callPackage ../data/themes/gtk-theme-framework { theme = "gruvterial"; };
  gst_all_1 = recurseIntoAttrs (callPackage ../development/libraries/gstreamer { });

  gtk-mac-integration-gtk2 = gtk-mac-integration.override {
    gtk = gtk2;
  };

  gtk-mac-integration-gtk3 = gtk-mac-integration;
  gtk-pipe-viewer = perlPackages.callPackage ../applications/video/pipe-viewer { withGtk3 = true; };

  gtk2-x11 = gtk2.override {
    cairo = cairo.override { x11Support = true; };
    gdktarget = "x11";

    pango = pango.override {
      cairo = cairo.override { x11Support = true; };
      x11Support = true;
    };
  };

  # On darwin gtk uses cocoa by default instead of x11.
  gtk3-x11 = gtk3.override {
    cairo = cairo.override { x11Support = true; };

    pango = pango.override {
      cairo = cairo.override { x11Support = true; };
      x11Support = true;
    };

    x11Support = true;
  };

  gtksourceview = gtksourceview3;
  gtksourceview3 = callPackage ../development/libraries/gtksourceview/3.x.nix { };
  gtksourceview4 = callPackage ../development/libraries/gtksourceview/4.x.nix { };
  gtksourceview5 = callPackage ../development/libraries/gtksourceview/5.x.nix { };
  guile = guile_3_0;
  guile_1_8 = callPackage ../development/interpreters/guile/1.8.nix { };
  # Needed for autogen
  guile_2_0 = callPackage ../development/interpreters/guile/2.0.nix { };
  guile_2_2 = callPackage ../development/interpreters/guile/2.2.nix { };
  guile_3_0 = callPackage ../development/interpreters/guile/3.0.nix { };
  gvm-tools = with python3.pkgs; toPythonApplication gvm-tools;
  gwenhywfar = callPackage ../development/libraries/aqbanking/gwenhywfar.nix { };
  gwt240 = callPackage ../development/compilers/gwt/2.4.0.nix { };
  gzip = callPackage ../tools/compression/gzip { };
  h3 = h3_3;
  hachoir = with python3Packages; toPythonApplication hachoir;
  hadolint = haskell.lib.compose.justStaticExecutables haskellPackages.hadolint;
  hadoop = hadoop3;
  hadoop3 = hadoop_3_4;
  hamlib = hamlib_3;
  happy = haskell.lib.compose.justStaticExecutables haskellPackages.happy;
  ### DEVELOPMENT / HARE
  hareHook = callPackage ../by-name/ha/hare/hook.nix { };
  hareThirdParty = recurseIntoAttrs (callPackage ./hare-third-party.nix { });

  harfbuzzFull = harfbuzz.override {
    withGraphite2 = true;
    withIcu = true;
  };

  # Haskell and GHC
  haskell = recurseIntoAttrs (callPackage ./haskell-packages.nix { });

  haskell-ci =
    # TODO: Erroneous references to GHC on aarch64-darwin: https://github.com/NixOS/nixpkgs/issues/318013
    (
      if stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64 then
        lib.id
      else
        haskell.lib.compose.justStaticExecutables
    )
      haskellPackages.haskell-ci;

  haskell-language-server =
    callPackage ../development/tools/haskell/haskell-language-server/withWrapper.nix
      { };

  haskellPackages = recurseIntoAttrs (
    # Prefer native-bignum to avoid linking issues with gmp;
    # GHC 9.10 doesn't work too well with iserv-proxy.
    if stdenv.hostPlatform.isStatic then
      haskell.packages.native-bignum.ghc912
    # JS backend can't use gmp
    else if stdenv.hostPlatform.isGhcjs then
      haskell.packages.native-bignum.ghc910
    else
      haskell.packages.ghc910
  );

  hassil = with python3Packages; toPythonApplication hassil;
  haste-client = callPackage ../tools/misc/haste-client { };
  haxe = haxe_4_3;
  haxePackages = recurseIntoAttrs (callPackage ./haxe-packages.nix { });
  hbase = hbase2; # when updating, point to the latest stable release
  hbase2 = hbase_2_6;
  hbase3 = hbase_3_0;

  hdf5 = callPackage ../tools/misc/hdf5 {
    fortran = gfortran;
    fortranSupport = false;
  };

  hdf5-cpp = hdf5.override { cppSupport = true; };
  hdf5-fortran = hdf5.override { fortranSupport = true; };

  hdf5-fortran-mpi = hdf5.override {
    cppSupport = false;
    fortranSupport = true;
    mpiSupport = true;
  };

  hdf5-mpi = hdf5.override {
    cppSupport = false;
    mpiSupport = true;
  };

  hdf5-threadsafe = hdf5.override {
    cppSupport = false;
    threadsafe = true;
  };

  hdf5_1_10 = callPackage ../tools/misc/hdf5/1.10.nix { };
  heartbeat = heartbeat7;
  heatclient = with python313Packages; toPythonApplication python-heatclient;

  helmfile-wrapped = helmfile.override {
    inherit (kubernetes-helm-wrapped.passthru) pluginsDir;
  };

  ### SCIENCE / PHYSICS
  hepmc3 = callPackage ../development/libraries/physics/hepmc3 {
    python = null;
  };

  highfive-mpi = highfive.override { hdf5 = hdf5-mpi; };

  highlight = callPackage ../tools/text/highlight {
    lua = lua5;
  };

  hinit = haskell.lib.compose.justStaticExecutables haskellPackages.hinit;
  hjson = with python3Packages; toPythonApplication hjson;
  hledger = haskell.lib.compose.justStaticExecutables haskellPackages.hledger;
  hledger-iadd = haskell.lib.compose.justStaticExecutables haskellPackages.hledger-iadd;
  hledger-interest = haskell.lib.compose.justStaticExecutables haskellPackages.hledger-interest;
  hledger-ui = haskell.lib.compose.justStaticExecutables haskellPackages.hledger-ui;
  hledger-utils = with python3.pkgs; toPythonApplication hledger-utils;

  hledger-web =
    # TODO: Erroneous references to GHC on aarch64-darwin: https://github.com/NixOS/nixpkgs/issues/318013
    (
      if stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64 then
        lib.id
      else
        haskell.lib.compose.justStaticExecutables
    )
      haskellPackages.hledger-web;

  hlint = haskell.lib.compose.justStaticExecutables haskellPackages.hlint;
  hocr-tools = with python3Packages; toPythonApplication hocr-tools;
  home-assistant = callPackage ../servers/home-assistant { };
  home-assistant-cli = callPackage ../servers/home-assistant/cli.nix { };

  home-assistant-custom-components = recurseIntoAttrs (
    lib.makeExtensible (
      self:
      lib.packagesFromDirectoryRecursive {
        inherit (home-assistant.python3Packages) callPackage;
        directory = ../servers/home-assistant/custom-components;
      }
    )
  );

  home-assistant-custom-lovelace-modules = recurseIntoAttrs (
    lib.makeExtensible (
      self:
      lib.packagesFromDirectoryRecursive {
        inherit callPackage;
        directory = ../servers/home-assistant/custom-lovelace-modules;
      }
    )
  );

  home-assistant-themes = lib.recurseIntoAttrs (
    lib.packagesFromDirectoryRecursive {
      inherit callPackage;
      directory = ../servers/home-assistant/themes;
    }
  );

  host = bind.host;
  hpack = haskell.lib.compose.justStaticExecutables haskellPackages.hpack;
  hpccm = with python3Packages; toPythonApplication hpccm;
  hplipWithPlugin = hplip.override { withPlugin = true; };
  hscolour = haskell.lib.compose.justStaticExecutables haskellPackages.hscolour;
  html-proofer = callPackage ../tools/misc/html-proofer { };
  htop-vim = htop.override { withVimKeys = true; };
  httpTwoLevelsUpdater = callPackage ../common-updater/http-two-levels-updater.nix { };
  httpie = with python3Packages; toPythonApplication httpie;
  humanfriendly = with python3Packages; toPythonApplication humanfriendly;
  hunspellDicts = recurseIntoAttrs (callPackages ../by-name/hu/hunspell/dictionaries.nix { });

  hunspellDictsChromium = recurseIntoAttrs (
    callPackages ../by-name/hu/hunspell/dictionaries-chromium.nix { }
  );

  hunspellWithDicts =
    dicts:
    lib.warn "hunspellWithDicts is deprecated, please use hunspell.withDicts instead."
      hunspell.withDicts
      (_: dicts);

  hw-probe = perlPackages.callPackage ../tools/system/hw-probe { };
  hwi = with python3Packages; toPythonApplication hwi;
  hy = with python3Packages; toPythonApplication hy;

  hydrogen-web = callPackage ../applications/networking/instant-messengers/hydrogen-web/wrapper.nix {
    conf = config.hydrogen-web.conf or { };
  };

  hydrogen-web-unwrapped =
    callPackage ../applications/networking/instant-messengers/hydrogen-web/unwrapped.nix
      { };

  hyperglot = with python3Packages; toPythonApplication hyperglot;
  hyphen = callPackage ../development/libraries/hyphen { };
  hyphenDicts = recurseIntoAttrs (callPackages ../development/libraries/hyphen/dictionaries.nix { });

  hypr = callPackage ../applications/window-managers/hyprwm/hypr {
    cairo = cairo.override { xcbSupport = true; };
  };

  hyprlandPlugins = recurseIntoAttrs (
    callPackage ../applications/window-managers/hyprwm/hyprland-plugins { }
  );

  i-pi = with python3Packages; toPythonApplication i-pi;
  iaca = iaca_3_0;
  iaca_2_1 = callPackage ../development/tools/iaca/2.1.nix { };
  iaca_3_0 = callPackage ../development/tools/iaca/3.0.nix { };

  ibus-engines = recurseIntoAttrs {
    anthy = callPackage ../tools/inputmethods/ibus-engines/ibus-anthy { };
    bamboo = callPackage ../tools/inputmethods/ibus-engines/ibus-bamboo { };
    cangjie = callPackage ../tools/inputmethods/ibus-engines/ibus-cangjie { };
    chewing = callPackage ../tools/inputmethods/ibus-engines/ibus-chewing { };
    hangul = callPackage ../tools/inputmethods/ibus-engines/ibus-hangul { };
    libpinyin = callPackage ../tools/inputmethods/ibus-engines/ibus-libpinyin { };
    libthai = callPackage ../tools/inputmethods/ibus-engines/ibus-libthai { };
    m17n = callPackage ../tools/inputmethods/ibus-engines/ibus-m17n { };
    mozc = mozc.override { withIbus = true; };
    mozc-ut = mozc-ut.override { withIbus = true; };
    pinyin = callPackage ../tools/inputmethods/ibus-engines/ibus-pinyin { };
    rime = callPackage ../tools/inputmethods/ibus-engines/ibus-rime { };
    table = callPackage ../tools/inputmethods/ibus-engines/ibus-table { };

    table-chinese = callPackage ../tools/inputmethods/ibus-engines/ibus-table-chinese {
      ibus-table = ibus-engines.table;
    };

    table-others = callPackage ../tools/inputmethods/ibus-engines/ibus-table-others {
      ibus-table = ibus-engines.table;
    };

    typing-booster = callPackage ../tools/inputmethods/ibus-engines/ibus-typing-booster/wrapper.nix {
      typing-booster = ibus-engines.typing-booster-unwrapped;
    };

    typing-booster-unwrapped = callPackage ../tools/inputmethods/ibus-engines/ibus-typing-booster { };
    uniemoji = callPackage ../tools/inputmethods/ibus-engines/ibus-uniemoji { };
  };

  icepeak = haskell.lib.compose.justStaticExecutables haskellPackages.icepeak;
  icingaweb2 = callPackage ../servers/icingaweb2 { };
  icingaweb2-ipl = callPackage ../servers/icingaweb2/ipl.nix { };
  icingaweb2-thirdparty = callPackage ../servers/icingaweb2/thirdparty.nix { };

  icingaweb2Modules = recurseIntoAttrs {
    theme-april = callPackage ../servers/icingaweb2/theme-april { };
    theme-lsd = callPackage ../servers/icingaweb2/theme-lsd { };
    theme-particles = callPackage ../servers/icingaweb2/theme-particles { };
    theme-snow = callPackage ../servers/icingaweb2/theme-snow { };
    theme-spring = callPackage ../servers/icingaweb2/theme-spring { };
  };

  iconv =
    if
      lib.elem stdenv.hostPlatform.libc [
        "glibc"
        "musl"
      ]
    then
      lib.getBin libc
    else if stdenv.hostPlatform.isDarwin then
      lib.getBin libiconv
    else if stdenv.hostPlatform.isFreeBSD then
      lib.getBin freebsd.iconv
    else
      lib.getBin libiconvReal;

  icu = icu76;
  icu-versions = callPackages ../development/libraries/icu { };
  idasen = with python3Packages; toPythonApplication idasen;
  idris = idrisPackages.with-packages [ idrisPackages.base ];
  idris2Packages = recurseIntoAttrs (callPackage ../development/compilers/idris2 { });

  idrisPackages = recurseIntoAttrs (
    callPackage ../development/idris-modules {
      idris-no-deps = haskellPackages.idris;
    }
  );

  ihaskell = callPackage ../development/tools/haskell/ihaskell/wrapper.nix {
    inherit (haskellPackages) ghcWithPackages;

    jupyter = python3.withPackages (ps: [
      ps.jupyter
      ps.notebook
    ]);

    packages = config.ihaskell.packages or (_: [ ]);
  };

  ikiwiki = callPackage ../applications/misc/ikiwiki {
    inherit
      (perlPackages.override {
        pkgs = pkgs // {
          imagemagick = imagemagickBig;
        };
      })
      ImageMagick
      ;
  };

  ikiwiki-full = ikiwiki.override {
    bazaarSupport = false; # tests broken
    cvsSupport = true;
    docutilsSupport = true;
    gitSupport = true;
    mercurialSupport = true;
    monotoneSupport = true;
    subversionSupport = true;
  };

  imagemagickBig = lowPrio (
    imagemagick.override {
      ghostscriptSupport = true;
    }
  );

  imagemagick_light = lowPrio (
    imagemagick.override {
      bzip2Support = false;
      djvulibreSupport = false;
      fontconfigSupport = false;
      freetypeSupport = false;
      lcms2Support = false;
      libX11Support = false;
      libXtSupport = false;
      libheifSupport = false;
      libjpegSupport = false;
      libjxlSupport = false;
      liblqr1Support = false;
      libpngSupport = false;
      libraqmSupport = false;
      librsvgSupport = false;
      libtiffSupport = false;
      libwebpSupport = false;
      libxml2Support = false;
      openexrSupport = false;
      openjpegSupport = false;
      zlibSupport = false;
    }
  );

  img2pdf = with python3Packages; toPythonApplication img2pdf;

  imlib2-nox = imlib2.override {
    x11Support = false;
  };

  imlib2Full = imlib2.override {
    heifSupport = !stdenv.hostPlatform.isDarwin;
    jxlSupport = true;
    psSupport = true;
    # Compilation error on Darwin with librsvg. For more information see:
    # https://github.com/NixOS/nixpkgs/pull/166452#issuecomment-1090725613
    svgSupport = !stdenv.hostPlatform.isDarwin;
    webpSupport = true;
  };

  importNpmLock = callPackages ../build-support/node/import-npm-lock { };

  include-what-you-use = callPackage ../development/tools/analysis/include-what-you-use {
    llvmPackages = llvmPackages_22;
  };

  incus-lts = callPackage ../by-name/in/incus/lts.nix { };
  indexed-bzip2 = with python3Packages; toPythonApplication indexed-bzip2;

  indi-3rdparty = recurseIntoAttrs (
    callPackages ../development/libraries/science/astronomy/indilib/indi-3rdparty.nix { }
  );

  indilib = callPackage ../development/libraries/science/astronomy/indilib { };
  infisical = callPackage ../development/tools/infisical { };

  inkscape = callPackage ../applications/graphics/inkscape {
    lcms = lcms2;
  };

  inkscape-extensions = recurseIntoAttrs (
    callPackages ../applications/graphics/inkscape/extensions.nix { }
  );

  inkscape-with-extensions = callPackage ../applications/graphics/inkscape/with-extensions.nix { };
  inspircdMinimal = inspircd.override { extraModules = [ ]; };
  intelLlvmStdenv = intel-llvm.stdenv;
  intensity-normalization = with python3Packages; toPythonApplication intensity-normalization;
  interception-tools = callPackage ../tools/inputmethods/interception-tools { };

  interception-tools-plugins = recurseIntoAttrs {
    caps2esc = callPackage ../tools/inputmethods/interception-tools/caps2esc.nix { };

    dual-function-keys =
      callPackage ../tools/inputmethods/interception-tools/dual-function-keys.nix
        { };
  };

  internetarchive = with python3Packages; toPythonApplication internetarchive;
  iocextract = with python3Packages; toPythonApplication iocextract;
  iocsearcher = with python3Packages; toPythonApplication iocsearcher;
  # used as base package for iortcw forks
  iortcw_sp = callPackage ../by-name/io/iortcw/sp.nix { };
  ios-cross-compile = callPackage ../development/compilers/ios-cross-compile/9.2.nix { };
  iosevka-comfy = recurseIntoAttrs (callPackages ../data/fonts/iosevka/comfy.nix { });
  ioskeley-mono = recurseIntoAttrs (callPackage ../data/fonts/ioskeley-mono { });
  iperf = iperf3;
  # hiPrio for collisions with inetutils (ping)
  iptables-nftables-compat = iptables;

  ipu6ep-camera-hal = ipu6-camera-hal.override {
    ipuVersion = "ipu6ep";
  };

  ipu6epmtl-camera-hal = ipu6-camera-hal.override {
    ipuVersion = "ipu6epmtl";
  };

  iputils = hiPrio (callPackage ../os-specific/linux/iputils { });
  ironicclient = with python313Packages; toPythonApplication python-ironicclient;

  irony-server = callPackage ../development/tools/irony-server {
    # The repository of irony to use -- must match the version of the employed emacs
    # package.  Wishing we could merge it into one irony package, to avoid this issue,
    # but its emacs-side expression is autogenerated, and we can't hook into it (other
    # than peek into its version).
    inherit (emacs.pkgs.melpaStablePackages) irony;
  };

  irrlicht =
    if !stdenv.hostPlatform.isDarwin then
      callPackage ../development/libraries/irrlicht { }
    else
      callPackage ../development/libraries/irrlicht/mac.nix {
      };

  isabelle-components = recurseIntoAttrs (callPackage ../by-name/is/isabelle/components { });

  iso-flags-png-320x240 = iso-flags.overrideAttrs (oldAttrs: {
    buildFlags = [ "png-country-320x240-fancy" ];

    installPhase = ''
      runHook preInstall
      mkdir -p $out/share && mv build/png-country-4x2-fancy/res-320x240 $out/share/iso-flags-png
      runHook postInstall
    '';
  });

  itgmaniaPackages = recurseIntoAttrs (callPackage ../by-name/it/itgmania/packages.nix { });
  itk = itk_5;
  itk_5 = callPackage ../development/libraries/itk/5.x.nix { };

  itk_5_2 = callPackage ../development/libraries/itk/5.2.x.nix {
    enableRtk = false;
  };

  j2cli = with python311Packages; toPythonApplication j2cli;
  j2lint = with python3Packages; toPythonApplication j2lint;
  jacinda = haskell.lib.compose.justStaticExecutables haskellPackages.jacinda;
  jack_autoconnect = jack-autoconnect;

  jackline = callPackage ../applications/networking/instant-messengers/jackline {
    ocamlPackages = ocaml-ng.ocamlPackages_4_14;
  };

  jackmix_jack1 = jackmix.override { jack = jack1; };

  jamesdsp-pulse = callPackage ../by-name/ja/jamesdsp/package.nix {
    usePipewire = false;
    usePulseaudio = true;
  };

  janet = callPackage ../development/interpreters/janet { };
  ### DEVELOPMENT / JAVA MODULES
  javaPackages = recurseIntoAttrs (callPackage ./java-packages.nix { });
  jc = with python3Packages; toPythonApplication jc;
  # default JDK
  jdk = jdk21;
  jdk11 = openjdk11;
  jdk11_headless = openjdk11_headless;
  jdk17 = openjdk17;
  jdk17_headless = openjdk17_headless;
  jdk21 = openjdk21;
  jdk21_headless = openjdk21_headless;
  jdk25 = openjdk25;
  jdk25_headless = openjdk25_headless;
  jdk8 = openjdk8;
  jdk8_headless = openjdk8_headless;
  jdk_headless = jdk21_headless;
  jello = with python3Packages; toPythonApplication jello;
  jenkins-job-builder = with python3Packages; toPythonApplication jenkins-job-builder;

  jetbrains = (
    recurseIntoAttrs (
      callPackages ../applications/editors/jetbrains {
        jdk = jetbrains.jdk;
        vmopts = config.jetbrains.vmopts or null;
      }
    )
    // {
      jcef = callPackage ../development/compilers/jetbrains-jdk/jcef.nix {
        jdk = jdk25;
      };

      jcef-21 = callPackage ../development/compilers/jetbrains-jdk/jcef.nix {
        jdk = jdk21;
      };

      jdk = callPackage ../development/compilers/jetbrains-jdk {
        jdk = jdk25;
      };

      jdk-21 = callPackage ../development/compilers/jetbrains-jdk/21.nix {
        jdk = jdk21;
      };

      jdk-no-jcef = callPackage ../development/compilers/jetbrains-jdk {
        jdk = jdk25;
        withJcef = false;
      };

      jdk-no-jcef-21 = callPackage ../development/compilers/jetbrains-jdk/21.nix {
        jdk = jdk21;
        withJcef = false;
      };
    }
    // lib.optionalAttrs config.allowAliases {
      jdk-no-jcef-17 = throw "'jdk-no-jcef-17' has been removed because it is unused in nixpkgs."; # Added 2026-01-24
    }
  );

  jetty = jetty_12;
  jl = haskellPackages.jl;
  jool-cli = callPackage ../os-specific/linux/jool/cli.nix { };
  jpm = callPackage ../development/interpreters/janet/jpm.nix { };
  jpylyzer = with python3Packages; toPythonApplication jpylyzer;
  # Since the introduction of the Java Platform Module System in Java 9, Java
  # no longer ships a separate JRE package.
  #
  # If you are building a 'minimal' system/image, you are encouraged to use
  # 'jre_minimal' to build a bespoke JRE containing only the modules you need.
  #
  # For a general-purpose system, 'jre' defaults to the full JDK:
  jre = jdk;
  jre8 = openjdk8.jre;
  jre8_headless = openjdk8_headless.jre;
  jre_headless = jdk_headless;
  jruby = callPackage ../development/interpreters/jruby { };
  jsbeautifier = with python3Packages; toPythonApplication jsbeautifier;
  json-schema-for-humans = with python3Packages; toPythonApplication json-schema-for-humans;
  json2yaml = haskell.lib.compose.justStaticExecutables haskellPackages.json2yaml;
  jsoncppSecureMemory = jsoncpp.override { secureMemory = true; };
  jtds_jdbc = callPackage ../servers/sql/mssql/jdbc/jtds.nix { };
  julia = julia-stable;
  julia-bin = julia-stable-bin;
  julia-lts = julia_110-bin;
  julia-lts-bin = julia_110-bin;
  julia-stable = julia_112;
  julia-stable-bin = julia_112-bin;
  jupyter = callPackage ../applications/editors/jupyter { };

  jupyter-all = jupyter.override {
    definitions = {
      clojure = clojupyter.definition;
      octave = octave-kernel.definition;
      r = r-ark-kernel.definition;
      ruby = iruby.definition;
      # wolfram = wolfram-for-jupyter-kernel.definition; # unfree
    };
  };

  jupyter-console = callPackage ../applications/editors/jupyter/console.nix { };
  jupyter-kernel = callPackage ../applications/editors/jupyter/kernel.nix { };
  k3s = k3s_1_35;
  kaggle = with python3Packages; toPythonApplication kaggle;

  kakoune = wrapKakoune kakoune-unwrapped {
    plugins = [ ]; # override with the list of desired plugins
  };

  kakoune-unwrapped = callPackage ../applications/editors/kakoune { };
  kakounePlugins = recurseIntoAttrs (callPackage ../applications/editors/kakoune/plugins { });
  kakouneUtils = callPackage ../applications/editors/kakoune/plugins/kakoune-utils.nix { };
  kanata-with-cmd = kanata.override { withCmd = true; };

  katagoCPU = katago.override {
    backend = "eigen";
  };

  katagoTensorRT = katago.override {
    backend = "tensorrt";
  };

  katagoWithCuda = katago.override {
    backend = "cuda";
  };

  kbdVlock = callPackage ../by-name/kb/kbd/package.nix { withVlock = true; };
  kbfs = callPackage ../tools/security/keybase/kbfs.nix { };
  kdePackages = callPackage ../kde { };

  keepBuildTree = makeSetupHook {
    name = "keep-build-tree-hook";
    meta.license = lib.licenses.mit;
  } ../build-support/setup-hooks/keep-build-tree.sh;

  kega-fusion = pkgsi686Linux.callPackage ../applications/emulators/kega-fusion { };
  kerf = kerf_1; # kerf2 is WIP

  kerf_1 = callPackage ../development/interpreters/kerf {
    stdenv = clangStdenv;
  };

  kernelPackagesExtensions = [ ];
  keybase = callPackage ../tools/security/keybase { };
  keybase-gui = callPackage ../tools/security/keybase/gui.nix { };

  kgt = callPackage ../development/tools/kgt {
    inherit (skawarePackages) cleanPackaging;
  };

  # this is the same but without the (sizable) 3D models library
  kicad-small = kicad.override {
    pname = "kicad-small";
    with3d = false;
  };

  # this is the stable branch at whatever point update.sh last updated versions.nix
  kicad-testing = kicad.override {
    pname = "kicad-testing";
    testing = true;
  };

  # and a small version of that
  kicad-testing-small = kicad.override {
    pname = "kicad-testing-small";
    testing = true;
    with3d = false;
  };

  # this is the master branch at whatever point update.sh last updated versions.nix
  kicad-unstable = kicad.override {
    pname = "kicad-unstable";
    stable = false;
  };

  # and a small version of that
  kicad-unstable-small = kicad.override {
    pname = "kicad-unstable-small";
    stable = false;
    with3d = false;
  };

  kicadAddons = recurseIntoAttrs (callPackage ../by-name/ki/kicad/addons/package.nix { });
  kiro-fhs = kiro.fhs;
  kiro-fhsWithPackages = kiro.fhsWithPackages;

  kissfftFloat = kissfft.override {
    datatype = "float";
  };

  klaus = with python3Packages; toPythonApplication klaus;
  klibc = callPackage ../os-specific/linux/klibc { };
  klibcShrunk = lowPrio (callPackage ../os-specific/linux/klibc/shrunk.nix { });
  klipper = callPackage ../servers/klipper { };
  klipper-firmware = callPackage ../servers/klipper/klipper-firmware.nix { };
  klipper-flash = callPackage ../servers/klipper/klipper-flash.nix { flashDevice = "/dev/null"; };
  klipper-genconf = callPackage ../servers/klipper/klipper-genconf.nix { };
  kmod = callPackage ../os-specific/linux/kmod { };
  kmonad = haskellPackages.kmonad.bin;

  koboredux-free = callPackage ../by-name/ko/koboredux/package.nix {
    useProprietaryAssets = false;
  };

  kodi = callPackage ../applications/video/kodi {
    ffmpeg = ffmpeg_6;
    jre_headless = buildPackages.jdk11_headless;
  };

  kodi-gbm = callPackage ../applications/video/kodi {
    ffmpeg = ffmpeg_6;
    gbmSupport = true;
    jre_headless = buildPackages.jdk11_headless;
  };

  kodi-wayland = callPackage ../applications/video/kodi {
    ffmpeg = ffmpeg_6;
    jre_headless = buildPackages.jdk11_headless;
    waylandSupport = true;
  };

  kodiPackages = recurseIntoAttrs (kodi.packages);
  kops = kops_1_33;

  kotatogram-desktop =
    callPackage ../applications/networking/instant-messengers/telegram/kotatogram-desktop
      { };

  kotlin = callPackage ../development/compilers/kotlin { };
  kotlin-native = callPackage ../development/compilers/kotlin/native.nix { };
  krank = haskell.lib.compose.justStaticExecutables haskellPackages.krank;
  kubectl-convert = kubectl.convert;

  kubectl-view-allocations =
    callPackage ../applications/networking/cluster/kubectl-view-allocations
      { };

  kubernetes-helm = callPackage ../applications/networking/cluster/helm { };
  kubernetes-helm-wrapped = wrapHelm kubernetes-helm { };

  kubernetes-helmPlugins = recurseIntoAttrs (
    callPackage ../applications/networking/cluster/helm/plugins { }
  );

  kustomize = callPackage ../development/tools/kustomize { };
  kustomize-sops = callPackage ../development/tools/kustomize/kustomize-sops.nix { };
  kustomize_3 = callPackage ../development/tools/kustomize/3.nix { };
  kustomize_4 = callPackage ../development/tools/kustomize/4.nix { };
  kzipmix = pkgsi686Linux.callPackage ../tools/compression/kzipmix { };

  l-smash = callPackage ../development/libraries/l-smash {
    stdenv = gccStdenv;
  };

  lagrange-tui = lagrange.override { enableTUI = true; };
  lambda-lisp-blc = lambda-lisp;

  lambdabot = callPackage ../development/tools/haskell/lambdabot {
    haskellLib = haskell.lib.compose;
  };

  lapack-ilp64 = lapack.override { isILP64 = true; };
  latex2mathml = with python3Packages; toPythonApplication latex2mathml;

  lazarus = callPackage ../development/compilers/fpc/lazarus.nix {
    fpc = fpc;
  };

  lazarus-qt5 = libsForQt5.callPackage ../development/compilers/fpc/lazarus.nix {
    fpc = fpc;
    withQt = true;
  };

  lazarus-qt6 = qt6Packages.callPackage ../development/compilers/fpc/lazarus.nix {
    fpc = fpc;
    withQt = true;
  };

  lcms = lcms2;

  ld-is-cc-hook = makeSetupHook {
    name = "ld-is-cc-hook";
    meta.license = lib.licenses.mit;
  } ../build-support/setup-hooks/ld-is-cc-hook.sh;

  ldapdomaindump = with python3Packages; toPythonApplication ldapdomaindump;

  ldmud-full = callPackage ../by-name/ld/ldmud/package.nix {
    ipv6Support = true;
    mccpSupport = true;
    mysqlSupport = true;
    postgresSupport = true;
    pythonSupport = true;
    sqliteSupport = true;
    tlsSupport = true;
  };

  lean3 = lean;
  leanPackages = recurseIntoAttrs (callPackage ../top-level/lean-packages.nix { });
  leanblueprint = with python3Packages; toPythonApplication leanblueprint;
  lemmy-server = callPackage ../servers/web-apps/lemmy/server.nix { };
  lemmy-ui = callPackage ../servers/web-apps/lemmy/ui.nix { };

  leo2 = callPackage ../applications/science/logic/leo2 {
    inherit (ocaml-ng.ocamlPackages_4_14_unsafe_string) ocaml camlp4;
  };

  lerna = lerna_8;
  lexicon = with python3Packages; toPythonApplication dns-lexicon;
  lgogdownloader-gui = callPackage ../by-name/lg/lgogdownloader/package.nix { enableGui = true; };
  lhs2tex = haskellPackages.lhs2tex;

  ## libGL/libGLU/Mesa stuff
  # Default libGL implementation.
  #
  # Android NDK provides an OpenGL implementation, we can just use that.
  #
  # On macOS, the SDK provides the OpenGL framework in `stdenv`.
  # Packages that still need GLX specifically can pull in `libGLX`
  # instead. If you have a package that should work without X11 but it
  # can’t find the library, it may help to add the path to
  # `$NIX_CFLAGS_COMPILE`:
  #
  #    preConfigure = ''
  #      export NIX_CFLAGS_COMPILE+=" -L$SDKROOT/System/Library/Frameworks/OpenGL.framework/Versions/Current/Libraries"
  #    '';
  #
  # If you still can’t get it working, please don’t hesitate to ping
  # @NixOS/darwin-maintainers to ask an expert to take a look.
  libGL =
    if stdenv.hostPlatform.useAndroidPrebuilt then
      stdenv
    else if stdenv.hostPlatform.isDarwin then
      null
    else
      libglvnd;

  # On macOS, the SDK provides the OpenGL framework in `stdenv`.
  # Packages that use `libGLX` on macOS may need to depend on
  # `mesa_glu` directly if this doesn’t work.
  libGLU = if stdenv.hostPlatform.isDarwin then null else mesa_glu;
  # `libglvnd` does not work (yet?) on macOS.
  libGLX = if stdenv.hostPlatform.isDarwin then mesa else libglvnd;
  libappindicator-gtk2 = libappindicator.override { gtkVersion = "2"; };
  libappindicator-gtk3 = libappindicator.override { gtkVersion = "3"; };
  libastyle = astyle.override { asLibrary = true; };
  libbass = (callPackage ../development/libraries/audio/libbass { }).bass;
  libbass_fx = (callPackage ../development/libraries/audio/libbass { }).bass_fx;
  libbassmidi = (callPackage ../development/libraries/audio/libbass { }).bassmidi;
  libbassmix = (callPackage ../development/libraries/audio/libbass { }).bassmix;
  libbfd = callPackage ../development/tools/misc/binutils/libbfd.nix { };

  libbfd_2_38 = callPackage ../development/tools/misc/binutils/2.38/libbfd.nix {
    autoreconfHook = buildPackages.autoreconfHook269;
  };

  libbpf = callPackage ../os-specific/linux/libbpf { };
  libbpf_0 = callPackage ../os-specific/linux/libbpf/0.x.nix { };

  # We can choose:
  libc =
    let
      inherit (stdenv.hostPlatform) libc;
      # libc is hackily often used from the previous stage. This `or`
      # hack fixes the hack, *sigh*.
    in
    if libc == null then
      null
    else if libc == "glibc" then
      glibc
    else if libc == "bionic" then
      bionic
    else if libc == "uclibc" then
      uclibc-ng
    else if libc == "avrlibc" then
      avrlibc
    else if libc == "newlib" && stdenv.hostPlatform.isMsp430 then
      msp430Newlib
    else if libc == "newlib" && stdenv.hostPlatform.isVc4 then
      vc4-newlib
    else if libc == "newlib" && stdenv.hostPlatform.isOr1k then
      or1k-newlib
    else if libc == "newlib" then
      newlib
    else if libc == "newlib-nano" then
      newlib-nano
    else if libc == "musl" then
      musl
    else if libc == "msvcrt" then
      if stdenv.hostPlatform.isMinGW then windows.mingw_w64 else windows.sdk
    else if libc == "ucrt" then
      if stdenv.hostPlatform.isMinGW then windows.mingw_w64 else windows.sdk
    else if libc == "cygwin" then
      cygwin.newlib-cygwin-nobin
    else if libc == "libSystem" then
      if stdenv.hostPlatform.useiOSPrebuilt then darwin.iosSdkPkgs.libraries else darwin.libSystem
    else if libc == "fblibc" then
      freebsd.libc
    else if libc == "oblibc" then
      openbsd.libc
    else if libc == "nblibc" then
      netbsd.libc
    else if libc == "wasilibc" then
      wasilibc
    else if libc == "relibc" then
      relibc
    else if libc == "llvm" then
      llvmPackages_20.libc
    else
      throw "Unknown libc ${libc}";

  libcIconv =
    libc:
    let
      inherit (libc) pname version;
      libcDev = lib.getDev libc;
    in
    runCommand "${pname}-iconv-${version}" { strictDeps = true; } ''
      mkdir -p $out/include
      ln -sv ${libcDev}/include/iconv.h $out/include
    '';

  libcamera-qcam = callPackage ../by-name/li/libcamera/package.nix { withQcam = true; };

  libcanberra-gtk2 = pkgs.libcanberra.override {
    gtkSupport = "gtk2";
  };

  libcanberra-gtk3 = pkgs.libcanberra.override {
    gtkSupport = "gtk3";
  };

  libcanberra_kde =
    if (config.kde_runtime.libcanberraWithoutGTK or true) then
      pkgs.libcanberra
    else
      pkgs.libcanberra-gtk2;

  libceph = ceph.lib;
  libchipcard = callPackage ../development/libraries/aqbanking/libchipcard.nix { };
  libclang = llvmPackages.libclang;
  libclc = llvmPackages.libclc;
  libcxx = llvmPackages.libcxx;
  libcxxStdenv = if stdenv.hostPlatform.isDarwin then stdenv else lowPrio llvmPackages.libcxxStdenv;

  libdbi-drivers-base = libdbi-drivers.override {
    withMysql = false;
    withSqlite = false;
  };

  libdbusmenu-gtk2 = libdbusmenu.override { gtkVersion = "2"; };
  libdbusmenu-gtk3 = libdbusmenu.override { gtkVersion = "3"; };
  libdislocator = callPackage ../tools/security/aflplusplus/libdislocator.nix { };
  liberation_ttf = liberation_ttf_v2;
  libffado = ffado;
  # Use Apple’s fork of libffi by default, which provides APIs and trampoline functionality that is not yet
  # merged upstream. This is needed by some packages (such as cffi).
  #
  # `libffiReal` is provided in case the upstream libffi package is needed on Darwin instead of the fork.
  libffi = if stdenv.hostPlatform.isDarwin then darwin.libffi else libffiReal;

  libfm-extra = libfm.override {
    extraOnly = true;
  };

  libfx2 = with python3Packages; toPythonApplication fx2;
  libgbm = callPackage ../development/libraries/mesa/gbm.nix { };
  libgcc = stdenv.cc.cc.libgcc or null;

  libgccjit = gcc.cc.override {
    enableLTO = false;
    langC = false;
    langCC = false;
    langFortran = false;
    langJit = true;
    name = "libgccjit";
    profiledCompiler = false;
  };

  # On macOS, the SDK provides the GLUT framework in `stdenv`. Packages
  # that use `libGLX` on macOS may need to depend on `freeglut`
  # directly if this doesn’t work.
  libglut = if stdenv.hostPlatform.isDarwin then null else freeglut;

  # https://git.gnupg.org/cgi-bin/gitweb.cgi?p=libgpg-error.git;a=blob;f=README;h=fd6e1a83f55696c1f7a08f6dfca08b2d6b7617ec;hb=70058cd9f944d620764e57c838209afae8a58c78#l118
  libgpg-error-gen-posix-lock-obj = libgpg-error.override {
    genPosixLockObjOnly = true;
  };

  # GNU libc provides libiconv so systems with glibc don't need to
  # build libiconv separately. Additionally, Apple forked/repackaged
  # libiconv, so build and use the upstream one with a compatible ABI,
  # and BSDs include libiconv in libc.
  #
  # We also provide `libiconvReal`, which will always be a standalone libiconv,
  # just in case you want it regardless of platform.
  libiconv =
    if
      lib.elem stdenv.hostPlatform.libc [
        "glibc"
        "musl"
        "nblibc"
        "wasilibc"
        "fblibc"
      ]
    then
      libcIconv pkgs.libc
    else if stdenv.hostPlatform.isDarwin then
      darwin.libiconv
    else
      libiconvReal;

  libiconvReal = callPackage ../development/libraries/libiconv { };
  libidn2 = callPackage ../development/libraries/libidn2 { };
  libindicator-gtk2 = libindicator.override { gtkVersion = "2"; };
  libindicator-gtk3 = libindicator.override { gtkVersion = "3"; };

  libinput = callPackage ../development/libraries/libinput {
    graphviz = graphviz-nox;
  };

  libintPsi4 = libint.override {
    cartGaussOrd = "standard";
    enableContracted = false;
    enableFortran = false;
    enableGeneric = false;
    enableOneBody = true;
    enableSSE = false;

    eri2Am = [
      6
      5
      4
    ];

    eri2Deriv = 2;

    eri2OptAm = [
      3
      2
      2
    ];

    eri2PureSh = false;

    eri3Am = [
      6
      5
      4
    ];

    eri3Deriv = 2;

    eri3OptAm = [
      3
      2
      2
    ];

    eri3PureSh = false;

    eriAm = [
      6
      5
      4
    ];

    eriDeriv = 2;

    eriOptAm = [
      3
      2
      2
    ];

    maxAm = 6;
    oneBodyDerivOrd = 2;
    shGaussOrd = "gaussian";
  };

  # On non-GNU systems we need GNU Gettext for libintl.
  libintl = if stdenv.hostPlatform.libc != "glibc" then gettext else null;
  libjack2 = jack2.override { prefix = "lib"; };
  # also known as libturbojpeg
  libjpeg = libjpeg_turbo;
  libjpeg8 = libjpeg_turbo.override { enableJpeg8 = true; };
  libkrb5 = krb5; # TODO(de11n) Try to make krb5 reuse libkrb5 as a dependency
  libkrun-sev = libkrun.override { variant = "sev"; };
  libkrun-tdx = libkrun.override { variant = "tdx"; };
  liblapack = lapack-reference;
  libliftoff = libliftoff_0_5;
  libllvm = llvmPackages.libllvm;
  libmicrohttpd = libmicrohttpd_1_0;

  libmpg123 = mpg123.override {
    libOnly = true;
    withConplay = false;
  };

  libmysqlclient = libmysqlclient_3_3;
  libmysqlclient_3_1 = mariadb-connector-c_3_1;
  libmysqlclient_3_2 = mariadb-connector-c_3_2;
  libmysqlclient_3_3 = mariadb-connector-c_3_3;
  libnghttp2 = nghttp2.lib;
  libnma-gtk4 = libnma.override { withGtk4 = true; };
  libopcodes = callPackage ../development/tools/misc/binutils/libopcodes.nix { };

  libopcodes_2_38 = callPackage ../development/tools/misc/binutils/2.38/libopcodes.nix {
    autoreconfHook = buildPackages.autoreconfHook269;
  };

  libpeas = callPackage ../development/libraries/libpeas { };
  libpeas2 = callPackage ../development/libraries/libpeas/2.x.nix { };
  libportal-gtk3 = libportal.override { variant = "gtk3"; };
  libportal-gtk4 = libportal.override { variant = "gtk4"; };
  libportal-qt5 = libportal.override { variant = "qt5"; };
  libportal-qt6 = libportal.override { variant = "qt6"; };

  libpostalWithData = callPackage ../by-name/li/libpostal/package.nix {
    withData = true;
  };

  libpulseaudio = pulseaudio.override {
    libOnly = true;
  };

  librdf_raptor2 = callPackage ../development/libraries/librdf/raptor2.nix { };
  librdf_rasqal = callPackage ../development/libraries/librdf/rasqal.nix { };
  librdf_redland = callPackage ../development/libraries/librdf/redland.nix { };

  librealsense-gui = librealsense.override {
    enableGUI = true;
  };

  librealsenseWithCuda = librealsense.override {
    cudaSupport = true;
  };

  librealsenseWithoutCuda = librealsense.override {
    cudaSupport = false;
  };

  libreoffice = hiPrio libreoffice-still;
  libreoffice-bin = callPackage ../applications/office/libreoffice/darwin { };

  libreoffice-collabora = callPackage ../applications/office/libreoffice {
    variant = "collabora";
    withFonts = true;
  };

  libreoffice-fresh = lowPrio (
    callPackage ../applications/office/libreoffice/wrapper.nix {
      unwrapped = callPackage ../applications/office/libreoffice {
        variant = "fresh";
      };
    }
  );

  libreoffice-fresh-unwrapped = libreoffice-fresh.unwrapped;
  libreoffice-qt = hiPrio libreoffice-qt-still;

  libreoffice-qt-fresh = lowPrio (
    callPackage ../applications/office/libreoffice/wrapper.nix {
      unwrapped = kdePackages.callPackage ../applications/office/libreoffice {
        kdeIntegration = true;
        variant = "fresh";
      };
    }
  );

  libreoffice-qt-fresh-unwrapped = libreoffice-qt-fresh.unwrapped;

  libreoffice-qt-still = lowPrio (
    callPackage ../applications/office/libreoffice/wrapper.nix {
      unwrapped = kdePackages.callPackage ../applications/office/libreoffice {
        kdeIntegration = true;
        variant = "still";
      };
    }
  );

  libreoffice-qt-still-unwrapped = libreoffice-qt-still.unwrapped;
  libreoffice-qt-unwrapped = libreoffice-qt.unwrapped;

  libreoffice-still = lowPrio (
    callPackage ../applications/office/libreoffice/wrapper.nix {
      unwrapped = callPackage ../applications/office/libreoffice {
        variant = "still";
      };
    }
  );

  libreoffice-still-unwrapped = libreoffice-still.unwrapped;
  libreoffice-unwrapped = libreoffice.unwrapped;
  libretranslate = with python3.pkgs; toPythonApplication libretranslate;
  ### APPLICATIONS/EMULATORS/RETROARCH
  libretro = recurseIntoAttrs (callPackage ../applications/emulators/libretro { });

  librewolf = wrapFirefox librewolf-unwrapped {
    inherit (librewolf-unwrapped) extraPrefsFiles extraPoliciesFiles;
    libName = "librewolf";
  };

  librewolf-bin = wrapFirefox librewolf-bin-unwrapped {
    pname = "librewolf-bin";

    extraPoliciesFiles = [
      "${librewolf-bin-unwrapped}/lib/librewolf-bin-${librewolf-bin-unwrapped.version}/distribution/extra-policies.json"
    ];

    extraPrefsFiles = [
      "${librewolf-bin-unwrapped}/lib/librewolf-bin-${librewolf-bin-unwrapped.version}/librewolf.cfg"
    ];
  };

  librsb = callPackage ../development/libraries/librsb {
    # Taken from https://build.opensuse.org/package/view_file/science/librsb/librsb.spec
    memHierarchy = "L3:16/64/8192K,L2:16/64/2048K,L1:8/64/16K";
  };

  libsForQt5 = recurseIntoAttrs (
    import ./qt5-packages.nix {
      inherit
        lib
        config
        __splicedPackages
        makeScopeWithSplicing'
        generateSplicesForMkScope
        pkgsHostTarget
        ;
    }
  );

  libsigcxx = callPackage ../development/libraries/libsigcxx { };
  libsigcxx30 = callPackage ../development/libraries/libsigcxx/3.0.nix { };
  libsoup_3 = callPackage ../development/libraries/libsoup/3.x.nix { };
  libsysprof-capture = callPackage ../development/tools/profiling/sysprof/capture.nix { };
  libtensorflow = python3.pkgs.tensorflow-build.libtensorflow;
  libtool = libtool_2;
  libtool_1_5 = callPackage ../development/tools/misc/libtool { };
  libtool_2 = callPackage ../development/tools/misc/libtool/libtool2.nix { };
  libtorch-bin = callPackage ../development/libraries/science/math/libtorch/bin.nix { };
  libtorrent-rasterbar = libtorrent-rasterbar-2_0_x;
  libubox = callPackage ../development/libraries/libubox { with_ustream_ssl = true; };

  libubox-mbedtls = libubox.override {
    ustream-ssl = ustream-ssl-mbedtls;
    with_ustream_ssl = true;
  };

  libubox-nossl = libubox.override { with_ustream_ssl = false; };
  libunique = callPackage ../development/libraries/libunique { };
  libunique3 = callPackage ../development/libraries/libunique/3.x.nix { };
  libunistring = callPackage ../development/libraries/libunistring { };

  libunwind =
    # Use the system unwinder in the SDK but provide a compatibility package to:
    # 1. avoid evaluation errors with setting `unwind` to `null`; and
    # 2. provide a `.pc` for compatibility with packages that expect to find libunwind that way.
    if stdenv.hostPlatform.isDarwin then
      darwin.libunwind
    else if stdenv.hostPlatform.system == "riscv32-linux" then
      llvmPackages.libunwind
    else
      callPackage ../development/libraries/libunwind { };

  libusb-compat-0_1 = callPackage ../development/libraries/libusb-compat/0.1.nix { };
  libuuid = if stdenv.hostPlatform.isLinux then util-linuxMinimal else null;

  libv4l = lowPrio (
    v4l-utils.override {
      withUtils = false;
    }
  );

  libva = libva-minimal.override { minimal = false; };
  libva-minimal = callPackage ../development/libraries/libva { minimal = true; };
  libva-utils = callPackage ../development/libraries/libva/utils.nix { };

  libvlc = vlc.override {
    onlyLibVLC = true;
    withQt5 = false;
  };

  libwnck = callPackage ../development/libraries/libwnck { };
  libwnck2 = callPackage ../development/libraries/libwnck/2.nix { };
  libwpd = callPackage ../development/libraries/libwpd { };
  libwpd_08 = callPackage ../development/libraries/libwpd/0.8.nix { };
  libwpe = callPackage ../development/libraries/libwpe { };
  libwpe-fdo = callPackage ../development/libraries/libwpe/fdo.nix { };
  ### SCIENCE/CHEMISTY
  libxc_7 = pkgs.libxc.override { version = "7.0.0"; };

  libxcrypt = callPackage ../development/libraries/libxcrypt {
    fetchurl = stdenv.fetchurlBoot;

    perl = buildPackages.perl.override {
      enableCrypt = false;
      fetchurl = stdenv.fetchurlBoot;
    };
  };

  libxcrypt-legacy = libxcrypt.override { enableHashes = "all"; };
  libxfs = xfsprogs.dev;
  libxkbcommon = libxkbcommon_8;

  libxml2Python =
    let
      inherit (python3.pkgs) libxml2;
    in
    pkgs.buildEnv {
      # the hook to find catalogs is hidden by buildEnv
      postBuild = ''
        mkdir "$out/nix-support"
        cp '${libxml2.dev}/nix-support/propagated-build-inputs' "$out/nix-support/"
      '';

      # slightly hacky
      name = "libxml2+py-${res.libxml2.version}";

      paths = with libxml2; [
        dev
        bin
        py
      ];

      # Avoid update.nix/tests conflicts with libxml2.
      passthru = removeAttrs libxml2.passthru [
        "updateScript"
        "tests"
      ];
    };

  libxmlxx = callPackage ../development/libraries/libxmlxx { };
  libxmlxx3 = callPackage ../development/libraries/libxmlxx/v3.nix { };
  libxpdf = callPackage ../applications/misc/xpdf/libxpdf.nix { };
  libzint = zint-qt.override { withGUI = false; };
  licensee = callPackage ../tools/package-management/licensee { };
  lightdm_qt = lightdm.override { withQt5 = true; };

  lilypond-unstable-with-fonts = lilypond-with-fonts.override {
    lilypond = lilypond-unstable;
  };

  lima-additional-guestagents = callPackage ../by-name/li/lima/additional-guestagents.nix { };
  limine-full = limine.override { enableAll = true; };
  linkerd = callPackage ../applications/networking/cluster/linkerd { };
  linkerd_edge = callPackage ../applications/networking/cluster/linkerd/edge.nix { };
  linkerd_stable = linkerd;

  linphonePackages = recurseIntoAttrs (
    callPackage ../applications/networking/instant-messengers/linphone { }
  );

  linux = linuxPackages.kernel;
  linux-doc = callPackage ../os-specific/linux/kernel/htmldocs.nix { };
  linux-gpib = callPackage ../applications/science/electronics/linux-gpib/user.nix { };
  linux-router-without-wifi = linux-router.override { useWifiDependencies = false; };
  linuxKernel = recurseIntoAttrs (callPackage ./linux-kernels.nix { });
  linuxManualConfig = linuxKernel.manualConfig;
  # The current default kernel / kernel modules.
  linuxPackages = linuxKernel.packageAliases.linux_default;
  linuxPackagesFor = linuxKernel.packagesFor;
  linuxPackages_custom = linuxKernel.customPackage;

  # This serves as a test for linuxPackages_custom
  linuxPackages_custom_tinyconfig_kernel =
    let
      base = linuxPackages.kernel;
      tinyLinuxPackages = linuxKernel.customPackage {
        inherit (base) version modDirVersion src;
        allowImportFromDerivation = false;

        configfile = linuxConfig {
          src = base.src;
          makeTarget = "tinyconfig";
        };
      };
    in
    tinyLinuxPackages.kernel;

  linuxPackages_latest = linuxKernel.packageAliases.linux_latest;
  # Testing (rc) kernel
  linuxPackages_testing = linuxKernel.packages.linux_testing;
  # XanMod kernel
  linuxPackages_xanmod = linuxKernel.packages.linux_xanmod;
  linuxPackages_xanmod_latest = linuxKernel.packages.linux_xanmod_latest;
  linuxPackages_xanmod_stable = linuxKernel.packages.linux_xanmod_stable;
  # zen-kernel
  linuxPackages_zen = linuxKernel.packages.linux_zen;
  linux_latest = linuxPackages_latest.kernel;
  linux_testing = linuxKernel.kernels.linux_testing;
  linux_xanmod = linuxKernel.kernels.linux_xanmod;
  linux_xanmod_latest = linuxKernel.kernels.linux_xanmod_latest;
  linux_xanmod_stable = linuxKernel.kernels.linux_xanmod_stable;
  linux_zen = linuxPackages_zen.kernel;

  linuxkit = callPackage ../development/tools/misc/linuxkit {
    inherit (darwin) sigtool;
  };

  liquid-dsp = callPackage ../development/libraries/liquid-dsp {
    inherit (darwin) autoSignDarwinBinariesHook;
  };

  liquidctl = with python3Packages; toPythonApplication liquidctl;
  lit = with python3Packages; toPythonApplication lit;
  lix = lixPackageSets.stable.lix;

  lixPackageSets = recurseIntoAttrs (
    callPackage ../tools/package-management/lix {
      stateDir = config.nix.stateDir or "/nix/var";
      storeDir = config.nix.storeDir or "/nix/store";
    }
  );

  lixStatic = pkgsStatic.lix;
  lklWithFirewall = lkl.override { firewallSupport = true; };
  lld = llvmPackages.lld;
  lld_18 = llvmPackages_18.lld;
  lld_19 = llvmPackages_19.lld;
  lld_20 = llvmPackages_20.lld;
  lld_21 = llvmPackages_21.lld;
  lld_22 = llvmPackages_22.lld;
  lldb = llvmPackages.lldb;
  lldb_18 = llvmPackages_18.lldb;
  lldb_19 = llvmPackages_19.lldb;
  lldb_20 = llvmPackages_20.lldb;
  lldb_21 = llvmPackages_21.lldb;
  lldb_22 = llvmPackages_22.lldb;
  llvm = llvmPackages.llvm;
  llvm-manpages = llvmPackages.llvm-manpages;
  llvmPackages = llvmPackages_21;
  llvm_18 = llvmPackages_18.llvm;
  llvm_19 = llvmPackages_19.llvm;
  llvm_20 = llvmPackages_20.llvm;
  llvm_21 = llvmPackages_21.llvm;
  llvm_22 = llvmPackages_22.llvm;
  # ltunifi and solaar both provide udev rules but solaar's rules are more
  # up-to-date so we simply use that instead of having to maintain our own rules
  logitech-udev-rules = solaar.udev;
  logstash = logstash7;
  logstash-contrib = callPackage ../tools/misc/logstash/contrib.nix { };

  logstash7 = callPackage ../tools/misc/logstash/7.x.nix {
    # https://www.elastic.co/support/matrix#logstash-and-jvm
    jre = jdk11_headless;
  };

  logstash7-oss = callPackage ../tools/misc/logstash/7.x.nix {
    enableUnfree = false;
    # https://www.elastic.co/support/matrix#logstash-and-jvm
    jre = jdk11_headless;
  };

  # lohit-fonts.assamese lohit-fonts.bengali lohit-fonts.devanagari lohit-fonts.gujarati lohit-fonts.gurmukhi
  # lohit-fonts.kannada lohit-fonts.malayalam lohit-fonts.marathi lohit-fonts.nepali lohit-fonts.odia
  # lohit-fonts.tamil-classical lohit-fonts.tamil lohit-fonts.telugu
  # lohit-fonts.kashmiri lohit-fonts.konkani lohit-fonts.maithili lohit-fonts.sindhi
  lohit-fonts = recurseIntoAttrs (callPackages ../data/fonts/lohit-fonts { });
  lomiri = recurseIntoAttrs (callPackage ../desktops/lomiri { });
  lomiri-qt6 = recurseIntoAttrs (callPackage ../desktops/lomiri { useQt6 = true; });
  love = love_11;
  love_0_10 = callPackage ../development/interpreters/love/0.10.nix { };
  love_11 = callPackage ../development/interpreters/love/11.nix { };

  # Less secure variant of lowdown for use inside Nix builds.
  lowdown-unsandboxed = lowdown.override {
    enableDarwinSandbox = false;
  };

  lshw-gui = lshw.override { withGUI = true; };
  lua = lua5;
  lua5 = lua5_2_compat;
  lua51Packages = recurseIntoAttrs lua5_1.pkgs;
  lua52Packages = recurseIntoAttrs lua5_2.pkgs;
  lua53Packages = recurseIntoAttrs lua5_3.pkgs;
  lua54Packages = recurseIntoAttrs lua5_4.pkgs;
  lua55Packages = recurseIntoAttrs lua5_5.pkgs;
  luaInterpreters = callPackage ./../development/interpreters/lua-5 { };
  luaPackages = lua52Packages;
  luabind = callPackage ../development/libraries/luabind { lua = lua5_1; };
  luabind_luajit = luabind.override { lua = luajit; };
  luajit = luajit_2_1;
  luajitPackages = recurseIntoAttrs luajit.pkgs;
  luanti-client = luanti.override { buildServer = false; };
  luanti-server = luanti.override { buildClient = false; };
  luarocks = luaPackages.luarocks;
  luarocks-nix = luaPackages.luarocks-nix;
  luddite = with python3Packages; toPythonApplication luddite;

  luksmeta = callPackage ../development/libraries/luksmeta {
    asciidoc = asciidoc-full;
  };

  lumina = recurseIntoAttrs (callPackage ../desktops/lumina { });

  lvm2 = callPackage ../os-specific/linux/lvm2/2_03.nix {
    # break the cyclic dependency:
    # util-linux (non-minimal) depends (optionally, but on by default) on systemd,
    # systemd (optionally, but on by default) on cryptsetup and cryptsetup depends on lvm2
    util-linux = util-linuxMinimal;
  };

  lvm2_dmeventd = lvm2.override {
    enableCmdlib = true;
    enableDmeventd = true;
  };

  lvm2_vdo = lvm2_dmeventd.override {
    enableVDO = true;
  };

  ### DESKTOPS/LXDE
  lxappearance-gtk2 = callPackage ../by-name/lx/lxappearance/package.nix {
    gtk2 = gtk2-x11;
    withGtk3 = false;
  };

  lxqt = recurseIntoAttrs (
    import ../desktops/lxqt {
      inherit pkgs;
      inherit (lib) makeScope;
      inherit kdePackages;
    }
  );

  m32edit = callPackage ../applications/audio/midas/m32edit.nix { };
  m4 = gnum4;

  macvim =
    let
      macvimUtils = callPackage ../applications/editors/vim/macvim-configurable.nix { };
    in
    macvimUtils.makeCustomizable (
      callPackage ../applications/editors/vim/macvim.nix {
        stdenv = clangStdenv;
      }
    );

  madlang = haskell.lib.compose.justStaticExecutables haskellPackages.madlang;
  maestral = with python3Packages; toPythonApplication maestral;
  magic-wormhole = with python3Packages; toPythonApplication magic-wormhole;
  magika = with python3Packages; toPythonApplication magika;

  magma-cuda = magma.override {
    cudaSupport = true;
    rocmSupport = false;
  };

  magma-cuda-static = magma-cuda.override {
    static = true;
  };

  magma-hip = magma.override {
    cudaSupport = false;
    rocmSupport = true;
  };

  magnetophonDSP = recurseIntoAttrs {
    CharacterCompressor = callPackage ../applications/audio/magnetophonDSP/CharacterCompressor { };
    CompBus = callPackage ../applications/audio/magnetophonDSP/CompBus { };
    ConstantDetuneChorus = callPackage ../applications/audio/magnetophonDSP/ConstantDetuneChorus { };
    LazyLimiter = callPackage ../applications/audio/magnetophonDSP/LazyLimiter { };
    MBdistortion = callPackage ../applications/audio/magnetophonDSP/MBdistortion { };
    RhythmDelay = callPackage ../applications/audio/magnetophonDSP/RhythmDelay { };
    VoiceOfFaust = callPackage ../applications/audio/magnetophonDSP/VoiceOfFaust { };
    faustCompressors = callPackage ../applications/audio/magnetophonDSP/faustCompressors { };
    pluginUtils = callPackage ../applications/audio/magnetophonDSP/pluginUtils { };
    shelfMultiBand = callPackage ../applications/audio/magnetophonDSP/shelfMultiBand { };
  };

  magnumclient = with python313Packages; toPythonApplication python-magnumclient;
  mailman-web = mailmanPackages.web;
  mailmanPackages = recurseIntoAttrs (callPackage ../servers/mail/mailman { });

  make-minimal-bootstrap-sources =
    callPackage ../os-specific/linux/minimal-bootstrap/stage0-posix/make-bootstrap-sources.nix
      {
        inherit (stdenv) hostPlatform;
      };

  makeAutostartItem = callPackage ../build-support/make-startupitem { };
  makeDarwinBundle = callPackage ../build-support/make-darwin-bundle { };
  makeDesktopItem = callPackage ../build-support/make-desktopitem { };
  makeFontsCache = callPackage ../development/libraries/fontconfig/make-fonts-cache.nix { };
  makeFontsConf = callPackage ../development/libraries/fontconfig/make-fonts-conf.nix { };

  makeGCOVReport = makeSetupHook {
    propagatedBuildInputs = [
      lcov
      enableGCOVInstrumentation
    ];

    name = "make-gcov-report-hook";
    meta.license = lib.licenses.mit;
  } ../build-support/setup-hooks/make-coverage-analysis-report.sh;

  makeHardcodeGsettingsPatch = callPackage ../build-support/make-hardcode-gsettings-patch { };
  makeImpureTest = callPackage ../build-support/make-impure-test.nix;
  makeInitrd = callPackage ../build-support/kernel/make-initrd.nix; # Args intentionally left out
  makeInitrdNG = callPackage ../build-support/kernel/make-initrd-ng.nix;
  makeInitrdNGTool = callPackage ../build-support/kernel/make-initrd-ng-tool.nix { };

  makeModulesClosure =
    {
      firmware,
      kernel,
      rootModules,
      allowMissing ? false,
      extraFirmwarePaths ? [ ],
    }:
    callPackage ../build-support/kernel/modules-closure.nix {
      inherit
        kernel
        firmware
        rootModules
        allowMissing
        extraFirmwarePaths
        ;
    };

  makePkgconfigItem = callPackage ../build-support/make-pkgconfigitem { };
  makeRustPlatform = callPackage ../development/compilers/rust/make-rust-platform.nix { };

  makeShellWrapper = makeSetupHook {
    propagatedBuildInputs = [ dieHook ];
    name = "make-shell-wrapper-hook";

    substitutions = {
      # targetPackages.runtimeShell only exists when pkgs == targetPackages (when targetPackages is not  __raw)
      shell =
        if targetPackages ? runtimeShell then
          targetPackages.runtimeShell
        else
          throw "makeWrapper/makeShellWrapper must be in nativeBuildInputs";
    };

    passthru = {
      tests = tests.makeWrapper;
    };

    meta.license = lib.licenses.mit;
  } ../build-support/setup-hooks/make-wrapper.sh;

  makeWrapper = makeShellWrapper;
  malcontent = callPackage ../development/libraries/malcontent { };
  malcontent-ui = callPackage ../development/libraries/malcontent/ui.nix { };

  mame-tools = lib.addMetaAttrs {
    description = mame.meta.description + " (tools only)";
  } (lib.getOutput "tools" mame);

  man = man-db;
  manilaclient = with python313Packages; toPythonApplication python-manilaclient;
  maple-mono = recurseIntoAttrs (callPackage ../data/fonts/maple-font { });
  mariadb = mariadb_114;
  mariadb-connector-c = mariadb-connector-c_3_3;
  mariadb-connector-c_3_1 = callPackage ../servers/sql/mariadb/connector-c/3_1.nix { };
  mariadb-connector-c_3_2 = callPackage ../servers/sql/mariadb/connector-c/3_2.nix { };
  mariadb-connector-c_3_3 = callPackage ../servers/sql/mariadb/connector-c/3_3.nix { };
  mariadb-embedded = mariadb.override { withEmbedded = true; };
  marimo = with python3Packages; toPythonApplication marimo;
  mate = recurseIntoAttrs (callPackage ../desktops/mate { });
  materialx = with python3Packages; toPythonApplication materialx;

  mathematica-cuda = mathematica.override {
    cudaSupport = true;
  };

  mathematica-webdoc = mathematica.override {
    webdoc = true;
  };

  mathematica-webdoc-cuda = mathematica.override {
    cudaSupport = true;
    webdoc = true;
  };

  matrix-synapse-plugins = recurseIntoAttrs matrix-synapse-unwrapped.plugins;

  matterhorn =
    # TODO: Erroneous references to GHC on aarch64-darwin: https://github.com/NixOS/nixpkgs/issues/318013
    (
      if stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64 then
        lib.id
      else
        haskell.lib.compose.justStaticExecutables
    )
      haskellPackages.matterhorn;

  maubot = with python3Packages; toPythonApplication maubot;
  maven3 = maven;
  # BQN interpreters and compilers
  mbqn = bqn;

  mcelog = callPackage ../os-specific/linux/mcelog {
    util-linux = util-linuxMinimal;
  };

  mcstatus = with python3Packages; toPythonApplication mcstatus;
  md2gemini = with python3.pkgs; toPythonApplication md2gemini;
  mdadm = mdadm4;

  mdcat = callPackage ../tools/text/mdcat {
    inherit (python3Packages) ansi2html;
  };

  mediaelch-qt5 = callPackage ../by-name/me/mediaelch/package.nix { qtVersion = 5; };
  mediaelch-qt6 = mediaelch;
  mendeley = callPackage ../applications/office/mendeley { };
  mercurialFull = mercurial.override { fullBuild = true; };

  mesa =
    if stdenv.hostPlatform.isDarwin then
      callPackage ../development/libraries/mesa/darwin.nix { }
    else
      callPackage ../development/libraries/mesa { };

  mesa-gl-headers = callPackage ../development/libraries/mesa/headers.nix { };
  mesa_i686 = pkgsi686Linux.mesa; # make it build on Hydra

  # while building documentation meson may want to run binaries for host
  # which needs an emulator
  # example of an error which this fixes
  # [Errno 8] Exec format error: './gdk3-scan'
  mesonEmulatorHook =
    makeSetupHook
      {
        name = "mesonEmulatorHook";

        substitutions = {
          crossFile = writeText "cross-file.conf" ''
            [binaries]
            exe_wrapper = '${lib.escape [ "'" "\\" ] (stdenv.targetPlatform.emulator pkgs)}'
          '';
        };

        meta.license = lib.licenses.mit;
      }
      # The throw is moved into the `makeSetupHook` derivation, so that its
      # outer level, but not its outPath can still be evaluated if the condition
      # doesn't hold. This ensures that splicing still can work correctly.
      (
        if (!stdenv.hostPlatform.canExecute stdenv.targetPlatform) then
          ../by-name/me/meson/emulator-hook.sh
        else
          throw "mesonEmulatorHook may only be added to nativeBuildInputs when the target binaries can't be executed; however you are attempting to use it in a situation where ${stdenv.hostPlatform.config} can execute ${stdenv.targetPlatform.config}. Consider only adding mesonEmulatorHook according to a conditional based canExecute in your package expression."
      );

  metasploit = callPackage ../tools/security/metasploit { };
  metricbeat = metricbeat7;
  mfcj470dwlpr = pkgsi686Linux.callPackage ../misc/cups/drivers/mfcj470dwlpr { };
  mfcj6510dwlpr = pkgsi686Linux.callPackage ../misc/cups/drivers/mfcj6510dwlpr { };
  mfcl2700dnlpr = pkgsi686Linux.callPackage ../misc/cups/drivers/mfcl2700dnlpr { };
  mfcl3770cdwcupswrapper = (callPackage ../misc/cups/drivers/brother/mfcl3770cdw { }).cupswrapper;
  # This driver is only available as a 32 bit proprietary binary driver
  mfcl3770cdwlpr = (callPackage ../misc/cups/drivers/brother/mfcl3770cdw { }).driver;
  mhonarc = perlPackages.MHonArc;

  micro-full = micro.wrapper.override {
    extraPackages = [
      wl-clipboard
      xclip
    ];
  };

  micro-with-wl-clipboard = micro.wrapper.override {
    extraPackages = [
      wl-clipboard
    ];
  };

  micro-with-xclip = micro.wrapper.override {
    extraPackages = [
      xclip
    ];
  };

  # TODO(@NixOS/haskell): deprecate this alias?
  microhs = targetPackages.haskell.packages.microhs.ghc or haskell.compiler.microhs;
  minari = python3Packages.toPythonApplication python3Packages.minari;

  minc_tools = callPackage ../applications/science/biology/minc-tools {
    inherit (perlPackages) perl TextFormat;
  };

  mindustry-server = callPackage ../by-name/mi/mindustry/package.nix {
    enableClient = false;
    enableServer = true;
  };

  mindustry-wayland = callPackage ../by-name/mi/mindustry/package.nix {
    enableWayland = true;
  };

  minecraftServers = callPackage ../by-name/mi/minecraft-server/versions.nix { };

  # minimal-bootstrap packages aren't used for anything but bootstrapping our
  # stdenv. They should not be used for any other purpose and therefore not
  # show up in search results or repository tracking services that consume our
  # packages.json https://github.com/NixOS/nixpkgs/issues/244966
  minimal-bootstrap = recurseIntoAttrsWith { search = false; } (
    import ../os-specific/linux/minimal-bootstrap {
      inherit (stdenv) buildPlatform hostPlatform;
      inherit lib config;
      checkMeta = callPackage ../stdenv/generic/check-meta.nix { };

      fetchurl = import ../build-support/fetchurl/boot.nix {
        inherit (stdenv.buildPlatform) system;
        inherit (config) rewriteURL;
      };
    }
  );

  minimal-bootstrap-sources =
    callPackage ../os-specific/linux/minimal-bootstrap/stage0-posix/bootstrap-sources.nix
      {
        inherit (stdenv) hostPlatform;
      };

  miniupnpd-nftables = miniupnpd.override { firewall = "nftables"; };
  mistralclient = with python313Packages; toPythonApplication python-mistralclient;
  mitmproxy = with python3Packages; toPythonApplication mitmproxy;

  mitschemeX11 = mitscheme.override {
    enableX11 = true;
  };

  mjpegtoolsFull = mjpegtools.override {
    withMinimal = false;
  };

  mkBinaryCache = callPackage ../build-support/binary-cache { };
  mkSaneConfig = callPackage ../applications/graphics/sane/config.nix { };
  mkShell = callPackage ../build-support/mkshell { };
  mkShellNoCC = mkShell.override { stdenv = stdenvNoCC; };

  mkStdenvNoLibs =
    stdenv:
    let
      bintools = stdenv.cc.bintools.override {
        libc = null;
        noLibc = true;
      };
    in
    stdenv.override {
      allowedRequisites = lib.mapNullable (rs: rs ++ [ bintools ]) (stdenv.allowedRequisites or null);

      cc = stdenv.cc.override {
        inherit bintools;
        extraPackages = [ ];
        libc = null;
        noLibc = true;
      };
    };

  # ManKai Common Lisp
  mkcl = wrapLisp {
    faslExt = "fas";
    pkg = callPackage ../development/compilers/mkcl { };
  };

  mkdocs = with python3Packages; toPythonApplication mkdocs;
  mkfontdir = mkfontscale;
  mkosi-full = mkosi.override { withQemu = true; };
  mkpasswd = hiPrio (callPackage ../tools/security/mkpasswd { });
  mkspiffs-presets = recurseIntoAttrs (callPackages ../by-name/mk/mkspiffs/presets.nix { });

  ## End libGL/libGLU/Mesa stuff
  mkvtoolnix-cli = mkvtoolnix.override {
    withGUI = false;
  };

  ### APPLICATIONS/TERMINAL-EMULATORS
  mlterm-wayland = mlterm.override {
    enableX11 = false;
  };

  mlton = mlton20241230;
  moarvm = callPackage ../development/interpreters/rakudo/moarvm.nix { };
  moeli = eduli;
  molbar = with python3Packages; toPythonApplication molbar;

  mold = wrapBintoolsWith {
    bintools = mold-unwrapped;

    extraBuildCommands = ''
      wrap ${targetPackages.stdenv.cc.bintools.targetPrefix}ld.mold ${../build-support/bintools-wrapper/ld-wrapper.sh} ${mold-unwrapped}/bin/ld.mold
      wrap ${targetPackages.stdenv.cc.bintools.targetPrefix}mold ${../build-support/bintools-wrapper/ld-wrapper.sh} ${mold-unwrapped}/bin/mold
    '';
  };

  molecule = with python3Packages; toPythonApplication molecule;
  mongodb = hiPrio mongodb-7_0;

  mongodb-7_0 = callPackage ../servers/nosql/mongodb/7.0.nix {
    boost = boost179.override { enableShared = false; };
    sasl = cyrus_sasl;
  };

  mono = mono6;
  mono6 = callPackage ../development/compilers/mono/6.nix { };

  monotone = callPackage ../applications/version-management/monotone {
    lua = lua5;
  };

  moodle = callPackage ../servers/web-apps/moodle { };
  moodle-utils = callPackage ../servers/web-apps/moodle/moodle-utils.nix { };

  mopidyPackages = recurseIntoAttrs (
    callPackages ../applications/audio/mopidy {
      python = python3;
    }
  );

  mopsa = ocamlPackages.mopsa.bin;

  moreutils = callPackage ../tools/misc/moreutils {
    docbook-xsl = docbook_xsl;
  };

  moveBuildTree = makeSetupHook {
    name = "move-build-tree-hook";
    meta.license = lib.licenses.mit;
  } ../build-support/setup-hooks/move-build-tree.sh;

  mozart2 = callPackage ../development/compilers/mozart {
    emacs = emacs-nox;
    jre_headless = jre8_headless; # TODO: remove override https://github.com/NixOS/nixpkgs/pull/89731
  };

  mozart2-binary = callPackage ../development/compilers/mozart/binary.nix { };
  mpeg2dec = libmpeg2;

  mpg123 = callPackage ../applications/audio/mpg123 {
    jack = libjack2;
  };

  mpi = openmpi; # this attribute should used to build MPI applications

  mpich = callPackage ../development/libraries/mpich {
    automake = automake116x;
    ch4backend = libfabric;
  };

  mpich-pmix = mpich.override {
    pmixSupport = true;
    withPm = [ ];
  };

  mplayer = callPackage ../applications/video/mplayer (
    {
      libdvdnav = libdvdnav_4_2_1;
    }
    // (config.mplayer or { })
  );

  mplus-outline-fonts = recurseIntoAttrs (callPackage ../data/fonts/mplus-outline-fonts { });
  mpvScripts = callPackage ../by-name/mp/mpv/scripts.nix { };
  mrustc = callPackage ../development/compilers/mrustc { };
  mrustc-bootstrap = callPackage ../development/compilers/mrustc/bootstrap.nix { };
  mrustc-minicargo = callPackage ../development/compilers/mrustc/minicargo.nix { };
  msoffcrypto-tool = with python3.pkgs; toPythonApplication msoffcrypto-tool;
  msp430GccSupport = callPackage ../development/misc/msp430/gcc-support.nix { };
  msp430Newlib = callPackage ../development/misc/msp430/newlib.nix { };
  mspdebug = callPackage ../development/misc/msp430/mspdebug.nix { };
  mspds = callPackage ../development/misc/msp430/mspds { };
  mspds-bin = callPackage ../development/misc/msp430/mspds/binary.nix { };
  mssql_jdbc = callPackage ../servers/sql/mssql/jdbc { };
  mtr-gui = mtr.override { withGtk = true; };
  mtrace = callPackage ../development/libraries/glibc/mtrace.nix { };
  muchsync = callPackage ../applications/networking/mailreaders/notmuch/muchsync.nix { };
  multiStdenv = if stdenv.cc.isClang then clangMultiStdenv else gccMultiStdenv;

  multitran = recurseIntoAttrs (
    let
      callPackage = newScope pkgs.multitran;
    in
    {
      libbtree = callPackage ../tools/text/multitran/libbtree { };
      libfacet = callPackage ../tools/text/multitran/libfacet { };
      libmtquery = callPackage ../tools/text/multitran/libmtquery { };
      libmtsupport = callPackage ../tools/text/multitran/libmtsupport { };
      mtutils = callPackage ../tools/text/multitran/mtutils { };
      multitrandata = callPackage ../tools/text/multitran/data { };
    }
  );

  mumble =
    (callPackages ../applications/networking/mumble {
      avahi = avahi-compat;
      jackSupport = config.mumble.jackSupport or false;
      speechdSupport = config.mumble.speechdSupport or false;
    }).mumble;

  mumble_overlay = (callPackages ../applications/networking/mumble { }).overlay;
  mumps-mpi = callPackage ../by-name/mu/mumps/package.nix { mpiSupport = true; };

  muonStandalone = muon.override {
    buildDocs = false;
    embedSamurai = true;
  };

  mupdf-headless = mupdf.override {
    enableGL = false;
    enableX11 = false;
  };

  murmur =
    (callPackages ../applications/networking/mumble {
      avahi = avahi-compat;
      iceSupport = config.murmur.iceSupport or true;
      pulseSupport = config.pulseaudio or false;
    }).murmur;

  myEnvFun = callPackage ../misc/my-env {
    inherit (stdenv) mkDerivation;
  };

  myfitnesspal = with python3Packages; toPythonApplication myfitnesspal;
  mygpoclient = with python3.pkgs; toPythonApplication mygpoclient;
  mypy = with python3Packages; toPythonApplication mypy;
  mypy-protobuf = with python3Packages; toPythonApplication mypy-protobuf;
  mysql-shell = mysql-shell_8;

  mysql-shell-innovation = callPackage ../development/tools/mysql-shell/innovation.nix {
    antlr = antlr4_10;
    icu = icu77;

    protobuf = protobuf_25.override {
      abseil-cpp = abseil-cpp_202407;
    };
  };

  nagiosPlugins = recurseIntoAttrs (callPackages ../servers/monitoring/nagios-plugins { });
  nanoemoji = with python3Packages; toPythonApplication nanoemoji;
  nanopbMalloc = callPackage ../by-name/na/nanopb/package.nix { enableMalloc = true; };

  napalm =
    with python3Packages;
    toPythonApplication (
      napalm.overridePythonAttrs (attrs: {
        # add community frontends that depend on the napalm python package
        dependencies = attrs.dependencies ++ [
          napalm-hp-procurve
        ];
      })
    );

  napari = with python312Packages; toPythonApplication napari;

  navidromePlugins = recurseIntoAttrs (
    lib.makeExtensible (
      self:
      lib.packagesFromDirectoryRecursive {
        inherit callPackage;
        directory = ../by-name/na/navidrome/plugins;
      }
    )
  );

  ncdu_1 = callPackage ../by-name/nc/ncdu/1.nix { };

  ncurses =
    if stdenv.hostPlatform.useiOSPrebuilt then
      null
    else
      callPackage ../development/libraries/ncurses {
        # ncurses is included in the SDK. Avoid an infinite recursion by using a bootstrap stdenv.
        stdenv = if stdenv.hostPlatform.isDarwin then darwin.bootstrapStdenv else stdenv;
      };

  ncurses5 = ncurses.override {
    abiVersion = "5";
  };

  ncurses6 = ncurses.override {
    abiVersion = "6";
  };

  nemo-qml-plugin-dbus = libsForQt5.callPackage ../development/libraries/nemo-qml-plugin-dbus { };
  neovim = wrapNeovim neovim-unwrapped { };

  neovimUtils = callPackage ../applications/editors/neovim/utils.nix {
    lua = lua5_1;
  };

  nerd-fonts = recurseIntoAttrs (callPackage ../data/fonts/nerd-fonts { });
  nest-mpi = nest.override { withMpi = true; };

  net-tools =
    # some platforms refer back to this from unixtools, so this is needed to
    # break the cycle
    if stdenv.hostPlatform.isLinux || stdenv.hostPlatform.isCygwin then
      callPackage ../os-specific/linux/net-tools { }
    else
      unixtools.net-tools;

  # Not in aliases because it wouldn't get picked up by callPackage
  netbox = netbox_4_5;
  netboxPlugins = recurseIntoAttrs netbox.plugins;
  netbsd = callPackage ../os-specific/bsd/netbsd { };

  netcap-nodpi = callPackage ../by-name/ne/netcap/package.nix {
    withDpi = false;
  };

  netcat = libressl.nc.overrideAttrs (old: {
    meta = old.meta // {
      description = "Utility which reads and writes data across network connections — LibreSSL implementation";
      mainProgram = "nc";
    };
  });

  netcdf-mpi = netcdf.override {
    hdf5 = hdf5-mpi.override { apiVersion = "v110"; };
  };

  netdata = callPackage ../tools/system/netdata {
    protobuf = protobuf_21;
  };

  netdataCloud = netdata.override {
    withCloudUi = true;
  };

  netmaker = callPackage ../applications/networking/netmaker { subPackages = [ "." ]; };
  netmaker-full = callPackage ../applications/networking/netmaker { };
  nettle = import ../development/libraries/nettle { inherit callPackage fetchurl; };

  neuron-full = neuron-mpi.override {
    useCore = true;
    useRx3d = true;
  };

  neuron-mpi = neuron.override { useMpi = true; };
  neutronclient = with python313Packages; toPythonApplication python-neutronclient;

  newlib-nano = newlib.override {
    nanoizeNewlib = true;
  };

  nextcloud-notify_push = callPackage ../servers/nextcloud/notify_push.nix { };
  nextcloud32Packages = callPackage ../servers/nextcloud/packages { ncVersion = "32"; };
  nextcloud33Packages = callPackage ../servers/nextcloud/packages { ncVersion = "33"; };
  nextcloud34Packages = callPackage ../servers/nextcloud/packages { ncVersion = "34"; };

  nextpnrWithGui = libsForQt5.callPackage ../by-name/ne/nextpnr/package.nix {
    enableGui = true;
  };

  nexusmods-app-unfree = nexusmods-app.override {
    pname = "nexusmods-app-unfree";
    _7zz = _7zz-rar;
  };

  nftables = callPackage ../os-specific/linux/nftables { };
  nginx = nginxStable;

  nginxMainline = callPackage ../servers/http/nginx/mainline.nix {
    # We don't use `with` statement here on purpose!
    # See https://github.com/NixOS/nixpkgs/pull/10474#discussion_r42369334
    modules = [
      nginxModules.dav
      nginxModules.moreheaders
    ];

    withKTLS = true;
    withPerl = false;
    zlib-ng = zlib-ng.override { withZlibCompat = true; };
  };

  nginxModules = recurseIntoAttrs (callPackage ../servers/http/nginx/modules.nix { });

  # We should move to dynamic modules and create a nginxFull package with all modules
  nginxShibboleth = nginxStable.override {
    modules = [
      nginxModules.rtmp
      nginxModules.dav
      nginxModules.moreheaders
      nginxModules.shibboleth
    ];
  };

  nginxStable = callPackage ../servers/http/nginx/stable.nix {
    # We don't use `with` statement here on purpose!
    # See https://github.com/NixOS/nixpkgs/pull/10474#discussion_r42369334
    modules = [
      nginxModules.rtmp
      nginxModules.dav
      nginxModules.moreheaders
    ];

    openssl = openssl_4_0;
    withPerl = false;
    zlib-ng = zlib-ng.override { withZlibCompat = true; };
  };

  ngspice = libngspice.override {
    withNgshared = false;
  };

  ngtcp2 = callPackage ../development/libraries/ngtcp2 { };
  ngtcp2-gnutls = callPackage ../development/libraries/ngtcp2/gnutls.nix { };
  nimOverrides = callPackage ./nim-overrides.nix { };
  ninja_1_11 = callPackage ../by-name/ni/ninja/package.nix { ninjaRelease = "1.11"; };
  niv = lib.getBin (haskell.lib.compose.justStaticExecutables haskellPackages.niv);
  nix = nixVersions.stable;
  nix-delegate = haskell.lib.compose.justStaticExecutables haskellPackages.nix-delegate;
  nix-deploy = haskell.lib.compose.justStaticExecutables haskellPackages.nix-deploy;
  nix-derivation = haskellPackages.nix-derivation.bin;
  nix-diff = haskell.lib.compose.justStaticExecutables haskellPackages.nix-diff;

  nix-eval-jobs = callPackage ../tools/package-management/nix-eval-jobs {
    nixComponents = nixVersions.nixComponents_2_34;
  };

  ### Nixpkgs maintainer tools
  nix-generate-from-cpan = callPackage ../../maintainers/scripts/nix-generate-from-cpan.nix { };
  nix-gitignore = callPackage ../build-support/nix-gitignore { };
  nix-info = callPackage ../tools/nix/info { };
  nix-info-tested = nix-info.override { doCheck = true; };
  nix-prefetch-docker = callPackage ../build-support/docker/nix-prefetch-docker.nix { };
  nix-prefetch-github = with python3Packages; toPythonApplication nix-prefetch-github;

  nix-serve-ng =
    # FIXME: manually eliminate incorrect references on aarch64-darwin,
    # see https://github.com/NixOS/nixpkgs/issues/318013
    if stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64 then
      haskellPackages.nix-serve-ng
    else
      haskell.lib.compose.justStaticExecutables haskellPackages.nix-serve-ng;

  nix-tree = haskell.lib.compose.justStaticExecutables (haskellPackages.nix-tree);

  nixBufferBuilders = import ../applications/editors/emacs/build-support/buffer.nix {
    inherit lib writeText;
    inherit (emacs.pkgs) inherit-local;
  };

  nixDependencies = recurseIntoAttrs (
    callPackage ../tools/package-management/nix/dependencies-scope.nix { }
  );

  nixStatic = pkgsStatic.nix;
  nixVersions = recurseIntoAttrs (callPackage ../tools/package-management/nix { });
  # Useful with ofborg, e.g. commit prefix `nixops_unstablePlugins.nixops-digitalocean: ...` to trigger automatically.
  nixops_unstablePlugins = recurseIntoAttrs nixops_unstable_minimal.availablePlugins;

  /*
    Evaluate a NixOS configuration using this evaluation of Nixpkgs.

    With this function you can write, for example, a package that
    depends on a custom virtual machine image.

    Parameter:  A module, path or list of those that represent the
                configuration of the NixOS system to be constructed.

    Result: An attribute set containing packages produced by this
            evaluation of NixOS, such as toplevel, kernel and
            initialRamdisk.
            The result can be extended in the modules by defining
            extra attributes in system.build.
            Alternatively, you may use the result's config and
            options attributes to query any option.

    Example:

        let
          myOS = pkgs.nixos ({ lib, pkgs, config, ... }: {

            config.services.nginx = {
              enable = true;
              # ...
            };

            # Use config.system.build to exports relevant parts of a
            # configuration. The runner attribute should not be
            # considered a fully general replacement for systemd
            # functionality.
            config.system.build.run-nginx = config.systemd.services.nginx.runner;
          });
        in
          myOS.run-nginx

    Unlike in plain NixOS, the nixpkgs.config and
    nixpkgs.system options will be ignored by default. Instead,
    nixpkgs.pkgs will have the default value of pkgs as it was
    constructed right after invoking the nixpkgs function (e.g. the
    value of import <nixpkgs> { overlays = [./my-overlay.nix]; }
    but not the value of (import <nixpkgs> {} // { extra = ...; }).

    If you do want to use the config.nixpkgs options, you are
    probably better off by calling nixos/lib/eval-config.nix
    directly, even though it is possible to set config.nixpkgs.pkgs.

    For more information about writing NixOS modules, see
    https://nixos.org/nixos/manual/index.html#sec-writing-modules

    Note that you will need to have called Nixpkgs with the system
    parameter set to the right value for your deployment target.
  */
  nixos =
    configuration:
    let
      c = import (path + "/nixos/lib/eval-config.nix") {
        inherit lib;

        modules = [
          (
            { lib, ... }:
            {
              config.nixpkgs.localSystem = lib.mkDefault stdenv.hostPlatform;
              config.nixpkgs.pkgs = lib.mkDefault pkgs;
            }
          )
        ]
        ++ (if builtins.isList configuration then configuration else [ configuration ]);

        # The system is inherited from the current pkgs above.
        # Set it to null, to remove the "legacy" entrypoint's non-hermetic default.
        system = null;
      };
    in
    c.config.system.build // c;

  nixos-artwork = recurseIntoAttrs (callPackage ../data/misc/nixos-artwork { });

  nixos-test-driver = pkgs.python3Packages.callPackage ../../nixos/lib/test-driver {
    imagemagick_light = pkgs.imagemagick_light.override { inherit (pkgs) libtiff; };
    # We want `pkgs.systemd`, *not* `python3Packages.system`.
    systemd = pkgs.systemd;
    tesseract4 = pkgs.tesseract4.override { enableLanguages = [ "eng" ]; };
  };

  nixosOptionsDoc =
    attrs:
    (import ../../nixos/lib/make-options-doc) (
      {
        inherit lib;
        pkgs = pkgs.__splicedPackages;
      }
      // attrs
    );

  ### Push NixOS tests inside the fixed point
  # See also allTestsForSystem in nixos/release.nix
  nixosTests =
    import ../../nixos/tests/all-tests.nix {
      inherit pkgs;
      callTest = config: config.test;
      system = stdenv.hostPlatform.system;
    }
    // {
      # for typechecking of the scripts and evaluation of
      # the nodes, without running VMs.
      allDrivers = import ../../nixos/tests/all-tests.nix {
        inherit pkgs;
        callTest = config: config.test.driver;
        system = stdenv.hostPlatform.system;
      };
    };

  nixpkgs-lint = callPackage ../../maintainers/scripts/nixpkgs-lint.nix { };
  nixpkgs-manual = callPackage ../../doc/doc-support/package.nix { };
  nixpkgs-pytools = with python3.pkgs; toPythonApplication nixpkgs-pytools;
  nltk-data = recurseIntoAttrs (callPackage ../tools/text/nltk-data { });
  nodejs = nodejs_24;
  nodejs-slim = nodejs-slim_24;
  nodejs-slim_20 = callPackage ../development/web/nodejs/v20.nix { };
  nodejs-slim_22 = callPackage ../development/web/nodejs/v22.nix { };
  nodejs-slim_24 = callPackage ../development/web/nodejs/v24.nix { };
  nodejs-slim_26 = callPackage ../development/web/nodejs/v26.nix { };
  nodejs-slim_latest = nodejs-slim_26;
  nodejs_20 = callPackage ../development/web/nodejs/symlink.nix { nodejs-slim = nodejs-slim_20; };
  nodejs_22 = callPackage ../development/web/nodejs/symlink.nix { nodejs-slim = nodejs-slim_22; };
  nodejs_24 = callPackage ../development/web/nodejs/symlink.nix { nodejs-slim = nodejs-slim_24; };
  nodejs_26 = callPackage ../development/web/nodejs/symlink.nix { nodejs-slim = nodejs-slim_26; };
  # Update this when adding the newest nodejs major version!
  nodejs_latest = nodejs_26;
  nodepy-runtime = with python3.pkgs; toPythonApplication nodepy-runtime;

  notmuch = callPackage ../applications/networking/mailreaders/notmuch {
    pythonPackages = python3Packages;
  };

  notmuch-mutt = callPackage ../applications/networking/mailreaders/notmuch/mutt.nix { };

  noto-fonts-cjk-sans-static = callPackage ../by-name/no/noto-fonts-cjk-sans/package.nix {
    static = true;
  };

  noto-fonts-cjk-serif-static = callPackage ../by-name/no/noto-fonts-cjk-serif/package.nix {
    static = true;
  };

  noto-fonts-lgc-plus = callPackage ../by-name/no/noto-fonts/package.nix {
    longDescription = ''
      This package provides the Noto Fonts, but only for latin, greek
      and cyrillic scripts, as well as some extra fonts.
    '';

    suffix = "-lgc-plus";

    variants = [
      "Noto Sans"
      "Noto Serif"
      "Noto Sans Mono"
      "Noto Music"
      "Noto Sans Symbols"
      "Noto Sans Symbols 2"
      "Noto Sans Math"
    ];
  };

  notus-scanner = with python3Packages; toPythonApplication notus-scanner;
  npmHooks = recurseIntoAttrs (callPackage ../build-support/node/build-npm-package/hooks { });
  nqp = callPackage ../development/interpreters/rakudo/nqp.nix { };
  nsdiff = perlPackages.nsdiff;

  nsjail = callPackage ../tools/security/nsjail {
    protobuf = protobuf_21;
  };

  nss = nss_esr;
  nssTools = nss.tools;
  nss_esr = callPackage ../development/libraries/nss/esr.nix { };
  nss_latest = callPackage ../development/libraries/nss/latest.nix { };
  nsz = with python3.pkgs; toPythonApplication nsz;
  # ntfsprogs are merged into ntfs-3g
  ntfsprogs = pkgs.ntfs3g;
  nth = with python3Packages; toPythonApplication name-that-hash;

  nufraw-thumbnailer = nufraw.override {
    addThumbnailer = true;
  };

  nukeReferences = callPackage ../build-support/nuke-references {
    inherit (darwin) signingUtils;
  };

  nushellPlugins = recurseIntoAttrs {
    bson = callPackage ../by-name/nu/nushell-plugin-bson/package.nix { };

    dbus = callPackage ../by-name/nu/nushell-plugin-dbus/package.nix {
      inherit dbus;
    };

    desktop_notifications =
      callPackage ../by-name/nu/nushell-plugin-desktop_notifications/package.nix
        { };

    formats = callPackage ../by-name/nu/nushell-plugin-formats/package.nix { };
    gstat = callPackage ../by-name/nu/nushell-plugin-gstat/package.nix { };
    hcl = callPackage ../by-name/nu/nushell-plugin-hcl/package.nix { };
    highlight = callPackage ../by-name/nu/nushell-plugin-highlight/package.nix { };
    net = callPackage ../by-name/nu/nushell-plugin-net/package.nix { };
    polars = callPackage ../by-name/nu/nushell-plugin-polars/package.nix { };
    query = callPackage ../by-name/nu/nushell-plugin-query/package.nix { };
    semver = callPackage ../by-name/nu/nushell-plugin-semver/package.nix { };
    skim = callPackage ../by-name/nu/nushell-plugin-skim/package.nix { };
    units = callPackage ../by-name/nu/nushell-plugin-units/package.nix { };
  };

  nuspellWithDicts =
    dicts:
    lib.warn "nuspellWithDicts is deprecated, please use nuspell.withDicts instead." nuspell.withDicts (
      _: dicts
    );

  nv-codec-headers-10 = nv-codec-headers.override { majorVersion = "10"; };
  nv-codec-headers-11 = nv-codec-headers.override { majorVersion = "11"; };
  nv-codec-headers-12 = nv-codec-headers.override { majorVersion = "12"; };
  nv-codec-headers-9 = nv-codec-headers.override { majorVersion = "9"; };

  nvchecker =
    with python3Packages;
    toPythonApplication (
      nvchecker.overridePythonAttrs (oldAttrs: {
        propagatedBuildInputs =
          oldAttrs.dependencies ++ lib.concatAttrValues oldAttrs.optional-dependencies;
      })
    );

  nvfetcher = haskell.lib.compose.justStaticExecutables haskellPackages.nvfetcher;
  nvidia-vaapi-driver = hiPrio (callPackage ../development/libraries/nvidia-vaapi-driver { });

  nvidiaCtkPackages = recurseIntoAttrs (
    callPackage ../by-name/nv/nvidia-container-toolkit/packages.nix { }
  );

  nvtopPackages = recurseIntoAttrs (import ../tools/system/nvtop { inherit callPackage stdenv; });
  nwdiag = with python3Packages; toPythonApplication nwdiag;

  nwjs-sdk = nwjs.override {
    sdk = true;
  };

  nyxt = callPackage ../applications/networking/browsers/nyxt {
    inherit (gst_all_1)
      gstreamer
      gst-libav
      gst-plugins-base
      gst-plugins-good
      gst-plugins-bad
      gst-plugins-ugly
      ;

    sbcl = sbcl_2_4_6;
  };

  obs-studio = qt6Packages.callPackage ../applications/video/obs-studio { };
  obs-studio-plugins = recurseIntoAttrs (callPackage ../applications/video/obs-studio/plugins { });
  ocaml = ocamlPackages.ocaml;
  ocaml-crunch = ocamlPackages.crunch.bin;
  ocaml-ng = callPackage ./ocaml-packages.nix { };
  ocamlPackages = recurseIntoAttrs ocaml-ng.ocamlPackages;
  ocamlPackages_latest = recurseIntoAttrs ocaml-ng.ocamlPackages_latest;
  oceanic-theme = callPackage ../data/themes/gtk-theme-framework { theme = "oceanic"; };
  ociTools = callPackage ../build-support/oci-tools { };
  ocrmypdf = with python3.pkgs; toPythonApplication ocrmypdf;
  ### End of CuboCore
  octave = callPackage ../development/interpreters/octave { };
  octave-kernel = recurseIntoAttrs (callPackage ../applications/editors/jupyter-kernels/octave { });

  octaveFull = octave.override {
    enableQt = true;
  };

  octavePackages = recurseIntoAttrs octave.pkgs;
  octodns-providers = octodns.providers;
  ogre = ogre_14;
  oletools = with python3.pkgs; toPythonApplication oletools;
  olivetin-3k = callPackage ../by-name/ol/olivetin/3k.nix { };
  ollama-cpu = callPackage ../by-name/ol/ollama/package.nix { acceleration = false; };
  ollama-cuda = callPackage ../by-name/ol/ollama/package.nix { acceleration = "cuda"; };
  ollama-rocm = callPackage ../by-name/ol/ollama/package.nix { acceleration = "rocm"; };
  ollama-vulkan = callPackage ../by-name/ol/ollama/package.nix { acceleration = "vulkan"; };
  ome_zarr = with python3Packages; toPythonApplication ome-zarr;
  online-judge-tools = with python3.pkgs; toPythonApplication online-judge-tools;
  opam = callPackage ../development/tools/ocaml/opam { };
  opam-installer = callPackage ../development/tools/ocaml/opam/installer.nix { };
  open-interpreter = with python3Packages; toPythonApplication open-interpreter;

  open-music-kontrollers = recurseIntoAttrs {
    eteroj = callPackage ../applications/audio/open-music-kontrollers/eteroj.nix { };
    jit = callPackage ../applications/audio/open-music-kontrollers/jit.nix { };
    mephisto = callPackage ../applications/audio/open-music-kontrollers/mephisto.nix { };
    midi_matrix = callPackage ../applications/audio/open-music-kontrollers/midi_matrix.nix { };
    moony = callPackage ../applications/audio/open-music-kontrollers/moony.nix { };
    orbit = callPackage ../applications/audio/open-music-kontrollers/orbit.nix { };
    patchmatrix = callPackage ../applications/audio/open-music-kontrollers/patchmatrix.nix { };
    router = callPackage ../applications/audio/open-music-kontrollers/router.nix { };
    sherlock = callPackage ../applications/audio/open-music-kontrollers/sherlock.nix { };
    synthpod = callPackage ../applications/audio/open-music-kontrollers/synthpod.nix { };
    vm = callPackage ../applications/audio/open-music-kontrollers/vm.nix { };
  };

  open-vm-tools-headless = open-vm-tools.override { withX = false; };
  open-watcom-bin = wrapWatcom open-watcom-bin-unwrapped { };
  open-watcom-bin-unwrapped = callPackage ../development/compilers/open-watcom/bin.nix { };
  open-watcom-v2 = wrapWatcom open-watcom-v2-unwrapped { };
  open-watcom-v2-full = wrapWatcom open-watcom-v2-full-unwrapped { };

  open-watcom-v2-full-unwrapped = open-watcom-v2-unwrapped.override {
    withDocs = true;
    withGUI = true;
  };

  open-watcom-v2-unwrapped = callPackage ../development/compilers/open-watcom/v2.nix { };
  openai-whisper = with python3.pkgs; toPythonApplication openai-whisper;
  openal = openal-soft;

  openblas = callPackage ../development/libraries/science/math/openblas {
    inherit (llvmPackages) openmp;
  };

  # A version of OpenBLAS using 32-bit integers on all platforms for compatibility with
  # standard BLAS and LAPACK.
  openblasCompat = openblas.override { blas64 = false; };
  openbsd = callPackage ../os-specific/bsd/openbsd { };
  openbugs = pkgsi686Linux.callPackage ../applications/science/machine-learning/openbugs { };

  opencascade-occt_7_6 = opencascade-occt.overrideAttrs rec {
    pname = "opencascade-occt";
    version = "7.6.2";

    src = fetchurl {
      url = "https://git.dev.opencascade.org/gitweb/?p=occt.git;a=snapshot;h=${commit};sf=tgz";
      hash = "sha256-n3KFrN/mN1SVXfuhEUAQ1fJzrCvhiclxfEIouyj9Z18=";
      name = "occt-${commit}.tar.gz";
    };

    commit = "V${builtins.replaceStrings [ "." ] [ "_" ] version}";
  };

  opencascade-occt_7_6_1 = opencascade-occt.overrideAttrs {
    pname = "opencascade-occt";
    version = "7.6.1";

    src = fetchFromGitHub {
      owner = "Open-Cascade-SAS";
      repo = "OCCT";
      rev = "V7_6_1";
      sha256 = "sha256-C02P3D363UwF0NM6R4D4c6yE5ZZxCcu5CpUaoTOxh7E=";
    };
  };

  openconnectPackages = {
    inherit openconnect openconnect_openssl;
  };

  opencv = opencv4;

  opencv4 = callPackage ../development/libraries/opencv/4.x.nix {
    # TODO: LTO does not work.
    # https://github.com/NixOS/nixpkgs/issues/343123
    enableLto = false;
    pythonPackages = python3Packages;
  };

  opencv4WithoutCuda = opencv4.override {
    enableCuda = false;
  };

  openexr = callPackage ../development/libraries/openexr/3.nix { };
  openexr_2 = callPackage ../development/libraries/openexr/2.nix { };
  openjdk = jdk;
  openjdk11 = javaPackages.compiler.openjdk11;
  openjdk11-bootstrap = javaPackages.compiler.openjdk11-bootstrap;
  openjdk11_headless = javaPackages.compiler.openjdk11.headless;
  openjdk17 = javaPackages.compiler.openjdk17;
  openjdk17-bootstrap = javaPackages.compiler.openjdk17-bootstrap;
  openjdk17_headless = javaPackages.compiler.openjdk17.headless;
  openjdk21 = javaPackages.compiler.openjdk21;
  openjdk21_headless = javaPackages.compiler.openjdk21.headless;
  openjdk25 = javaPackages.compiler.openjdk25;
  openjdk25_headless = javaPackages.compiler.openjdk25.headless;
  openjdk8 = javaPackages.compiler.openjdk8;
  openjdk8-bootstrap = javaPackages.compiler.openjdk8-bootstrap;
  openjdk8_headless = javaPackages.compiler.openjdk8.headless;
  openjdk_headless = jdk_headless;
  openjfx17 = callPackage ../by-name/op/openjfx/package.nix { featureVersion = "17"; };
  openjfx21 = openjfx;
  openjfx25 = callPackage ../by-name/op/openjfx/package.nix { featureVersion = "25"; };
  openlilylib-fonts = recurseIntoAttrs (callPackage ../misc/lilypond/fonts.nix { });
  openmoji-black = callPackage ../data/fonts/openmoji { fontFormats = [ "glyf" ]; };
  openmoji-color = callPackage ../data/fonts/openmoji { fontFormats = [ "glyf_colr_0" ]; };

  openmvs = callPackage ../applications/science/misc/openmvs {
    inherit (llvmPackages) openmp;
  };

  openntpd_nixos = openntpd.override {
    privsepPath = "/var/empty";
    privsepUser = "ntp";
  };

  openra = openraPackages.engines.release;
  openraPackages = recurseIntoAttrs (callPackage ../games/openra { });

  openraPackages_2019 = import ../games/openra_2019 {
    inherit lib;
    pkgs = pkgs.__splicedPackages;
  };

  openra_2019 = openraPackages_2019.engines.release;
  openrazer-daemon = python3Packages.toPythonApplication python3Packages.openrazer-daemon;

  openresty = callPackage ../servers/http/openresty {
    modules = [ ];
    withPerl = false;
    zlib-ng = zlib;
  };

  openrgb-with-all-plugins = openrgb.withPlugins [
    openrgb-plugin-effects
    openrgb-plugin-hardwaresync
  ];

  opensmalltalk-vm = callPackage ../development/compilers/opensmalltalk-vm { };
  opensplatWithCuda = opensplat.override { cudaSupport = true; };
  opensplatWithRocm = opensplat.override { rocmSupport = true; };

  openssh = opensshPackages.openssh.override {
    etcDir = "/etc/ssh";
  };

  opensshPackages = dontRecurseIntoAttrs (callPackage ../tools/networking/openssh { });
  opensshTest = openssh.tests.openssh;

  opensshWithKerberos = openssh.override {
    withKerberos = true;
  };

  openssh_gssapi = opensshPackages.openssh_gssapi.override {
    etcDir = "/etc/ssh";
    withKerberos = true;
  };

  openssh_hpn = opensshPackages.openssh_hpn.override {
    etcDir = "/etc/ssh";
  };

  openssh_hpnWithKerberos = openssh_hpn.override {
    withKerberos = true;
  };

  openssl = openssl_3_6;

  openssl_legacy = openssl.override {
    conf = ../development/libraries/openssl/3.0/legacy.cnf;
  };

  openssl_oqs = openssl.override {
    autoloadProviders = true;

    extraINIConfig = {
      tls_system_default = {
        Groups = "X25519MLKEM768:X25519:P-256:X448:P-521:ffdhe2048:ffdhe3072";
      };
    };

    providers = [
      {
        name = "oqsprovider";
        package = pkgs.oqs-provider;
      }
    ];
  };

  openstackclient = with python313Packages; toPythonApplication python-openstackclient;

  openstackclient-full = openstackclient.overridePythonAttrs (oldAttrs: {
    dependencies = oldAttrs.dependencies ++ oldAttrs.optional-dependencies.cli-plugins;
  });

  opentelemetry-collector = opentelemetry-collector-releases.otelcol;
  opentelemetry-collector-builder = callPackage ../tools/misc/opentelemetry-collector/builder.nix { };
  opentelemetry-collector-contrib = opentelemetry-collector-releases.otelcol-contrib;

  opentelemetry-collector-releases =
    callPackage ../tools/misc/opentelemetry-collector/releases.nix
      { };

  openusd = python3Packages.openusd.override {
    withTools = true;
    withUsdView = true;
  };

  openvpn = callPackage ../tools/networking/openvpn { };

  openvpn-auth-ldap = callPackage ../tools/networking/openvpn/openvpn-auth-ldap.nix {
    inherit (llvmPackages) stdenv;
  };

  openvpn_learnaddress = callPackage ../tools/networking/openvpn/openvpn_learnaddress.nix { };
  openvswitch-dpdk = callPackage ../by-name/op/openvswitch/package.nix { withDPDK = true; };
  ophcrack-cli = ophcrack.override { enableGui = false; };
  opnplug = adlplug.override { type = "OPN"; };

  oprofile = callPackage ../development/tools/profiling/oprofile {
    libiberty_static = libiberty.override { staticBuild = true; };
  };

  optifine = optifinePackages.optifine-latest;
  optifinePackages = callPackage ../tools/games/minecraft/optifine { };
  or1k-newlib = callPackage ../development/misc/or1k/newlib.nix { };
  ormolu = lib.getBin (haskell.lib.compose.justStaticExecutables haskellPackages.ormolu);

  orpie = callPackage ../applications/misc/orpie {
    ocamlPackages = ocaml-ng.ocamlPackages_4_14;
  };

  p4c = callPackage ../development/compilers/p4c {
    protobuf = protobuf_21;
  };

  p4est-dbg = p4est.override { debug = true; };
  p4est-sc-dbg = p4est-sc.override { debug = true; };
  packagekit = callPackage ../tools/package-management/packagekit { };
  packetbeat = packetbeat7;
  pakcs = callPackage ../development/compilers/pakcs { };
  palenight-theme = callPackage ../data/themes/gtk-theme-framework { theme = "palenight"; };

  pam =
    if stdenv.hostPlatform.isLinux then
      linux-pam
    else if stdenv.hostPlatform.isFreeBSD then
      freebsd.libpam
    else
      openpam;

  pangomm = callPackage ../development/libraries/pangomm { };
  pangomm_2_42 = callPackage ../development/libraries/pangomm/2.42.nix { };
  pangomm_2_48 = callPackage ../development/libraries/pangomm/2.48.nix { };
  # Needed for elementary's gala, wingpanel and greeter until support for higher versions is provided
  pantheon = recurseIntoAttrs (callPackage ../desktops/pantheon { });
  papermc = papermcServers.papermc;
  papermcServers = callPackages ../games/papermc { };
  paperwork = callPackage ../applications/office/paperwork/paperwork-gtk.nix { };
  papis = with python3Packages; toPythonApplication papis;
  pass = callPackage ../tools/security/pass { };

  pass-nodmenu = pass.override {
    dmenuSupport = false;
    pass = pass-nodmenu;
  };

  pass-wayland = pass.override {
    pass = pass-wayland;
    waylandSupport = true;
  };

  passExtensions = recurseIntoAttrs pass.extensions;
  patch = gnupatch;
  patchelf = callPackage ../development/tools/misc/patchelf { };
  patchelfUnstable = lowPrio (callPackage ../development/tools/misc/patchelf/unstable.nix { });
  patchutils = callPackage ../tools/text/patchutils { };
  patchutils_0_3_3 = callPackage ../tools/text/patchutils/0.3.3.nix { };
  patchutils_0_4_2 = callPackage ../tools/text/patchutils/0.4.2.nix { };
  # For convenience, allow callers to get the path to Nixpkgs.
  path = ../..;
  patool = with python3Packages; toPythonApplication patool;
  pcmanfm-qt = lxqt.pcmanfm-qt;
  # pcre32 seems unused
  pcre-cpp = pcre.override { variant = "cpp"; };

  pcscliteWithPolkit = pcsclite.override {
    pname = "pcsclite-with-polkit";
    polkitSupport = true;
  };

  pdb2pqr = with python3Packages; toPythonApplication pdb2pqr;
  pdfium-binaries-v8 = pdfium-binaries.override { withV8 = true; };
  pdfminer = with python3Packages; toPythonApplication pdfminer-six;

  pdfpc = callPackage ../applications/misc/pdfpc {
    inherit (gst_all_1)
      gstreamer
      gst-plugins-base
      gst-plugins-good
      gst-libav
      ;
  };

  pdsh = callPackage ../tools/networking/pdsh {
    rsh = true; # enable internal rsh implementation
    ssh = openssh;
  };

  perl = perl5;
  perl5Packages = recurseIntoAttrs perl5.pkgs;
  ### DEVELOPMENT / PERL MODULES
  perlInterpreters = import ../development/interpreters/perl { inherit callPackage; };
  perlPackages = perl5Packages;
  perlcritic = perlPackages.PerlCritic;
  pgadmin4-desktopmode = pgadmin4.override { server-mode = false; };
  pgbadger = perlPackages.callPackage ../tools/misc/pgbadger { };
  pgcli = with pkgs.python3Packages; toPythonApplication pgcli;
  pgf = pgf2;
  philipstv = with python3Packages; toPythonApplication philipstv;

  phonetisaurus = callPackage ../development/libraries/phonetisaurus {
    # https://github.com/AdolfVonKleist/Phonetisaurus/issues/70
    openfst = openfst.overrideAttrs rec {
      version = "1.7.9";

      src = fetchurl {
        url = "http://www.openfst.org/twiki/pub/FST/FstDownload/openfst-${version}.tar.gz";
        hash = "sha256-kxmusx0eKVCuJUSYhOJVzCvJ36+Yf2AVkHY+YaEPvd4=";
      };
    };
  };

  phosh = callPackage ../applications/window-managers/phosh { };

  phosh-mobile-settings =
    callPackage ../applications/window-managers/phosh/phosh-mobile-settings.nix
      { };

  # PHP interpreters, packages and extensions.
  #
  # Set default PHP interpreter, extensions and packages
  php = php84;
  # PHP Extensions and Packages
  php82Extensions = recurseIntoAttrs php82.extensions;
  php82Packages = recurseIntoAttrs php82.packages;
  php83Extensions = recurseIntoAttrs php83.extensions;
  php83Packages = recurseIntoAttrs php83.packages;
  php84Extensions = recurseIntoAttrs php84.extensions;
  php84Packages = recurseIntoAttrs php84.packages;
  php85Extensions = recurseIntoAttrs php85.extensions;
  php85Packages = recurseIntoAttrs php85.packages;
  phpExtensions = recurseIntoAttrs php.extensions;
  phpPackages = recurseIntoAttrs php.packages;
  pianoteq = callPackage ../applications/audio/pianoteq { };

  pidginPackages = recurseIntoAttrs (
    callPackage ../applications/networking/instant-messengers/pidgin/pidgin-plugins { }
  );

  pijuice = with python3Packages; toPythonApplication pijuice;
  pinboard = with python3Packages; toPythonApplication pinboard;
  pinboard-notes-backup = haskell.lib.compose.justStaticExecutables haskellPackages.pinboard-notes-backup;
  pinegrow6 = pinegrow.override { pinegrowVersion = "6"; };
  pinentry_mac = callPackage ../tools/security/pinentry/mac.nix { };
  pipe-viewer = perlPackages.callPackage ../applications/video/pipe-viewer { };

  pipeworld-wrapped = arcan.wrapper.override {
    appls = [ pipeworld ];
    name = "pipeworld-wrapped";
  };

  pipx = with python3.pkgs; toPythonApplication pipx;
  pixcat = with python3Packages; toPythonApplication pixcat;

  pkg-config = callPackage ../build-support/pkg-config-wrapper {
    pkg-config = pkg-config-unwrapped;
  };

  pkg-configUpstream = lowPrio (
    pkg-config.override (old: {
      pkg-config = old.pkg-config.override {
        vanilla = true;
      };
    })
  );

  pkgconf = callPackage ../build-support/pkg-config-wrapper {
    baseBinName = "pkgconf";
    pkg-config = pkgconf-unwrapped;
  };

  pkgconf-unwrapped = libpkgconf;

  # A NixOS/home-manager/arion/... module that sets the `pkgs` module argument.
  pkgsModule =
    { options, ... }:
    {
      config =
        if options ? nixpkgs.pkgs then
          {
            # legacy / nixpkgs.nix style
            nixpkgs.pkgs = pkgs;
          }
        else
          {
            # minimal
            _module.args.pkgs = pkgs;
          };
    };

  place-cursor-at = haskell.lib.compose.justStaticExecutables haskellPackages.place-cursor-at;

  plan9port = callPackage ../tools/system/plan9port {
    inherit (darwin) DarwinTools;
  };

  platformio = if stdenv.hostPlatform.isLinux then platformio-chrootenv else platformio-core;
  playwright = playwright-driver;
  playwright-driver = (callPackage ../development/web/playwright/driver.nix { }).playwright-core;
  playwright-test = (callPackage ../development/web/playwright/driver.nix { }).playwright-test;
  pleroma-bot = python3Packages.callPackage ../development/python-modules/pleroma-bot { };
  pmars-x11 = pmars.override { enableXwinGraphics = true; };
  pnglatex = with python3Packages; toPythonApplication pnglatex;
  pnpm = pnpm_11;
  po4a = perlPackages.Po4a;
  poetryPlugins = recurseIntoAttrs poetry.plugins;
  pokerth-server = pokerth.override { target = "server"; };

  polybarFull = polybar.override {
    alsaSupport = true;
    githubSupport = true;
    i3Support = true;
    iwSupport = false;
    mpdSupport = true;
    nlSupport = true;
    pulseSupport = true;
  };

  poppler = callPackage ../development/libraries/poppler { lcms = lcms2; };

  poppler-utils = poppler.override {
    suffix = "utils";
    utils = true;
  };

  poppler_gi = lowPrio (
    poppler.override {
      introspectionSupport = true;
    }
  );

  poppler_min = poppler.override {
    # TODO: maybe reduce even more
    minimal = true;
    suffix = "min";
  };

  portableService = callPackage ../build-support/portable-service { };
  postgres-websockets = haskellPackages.postgres-websockets.bin;
  postgresql = postgresql_18;
  postgresql14Packages = recurseIntoAttrs postgresql_14.pkgs;
  postgresql15Packages = recurseIntoAttrs postgresql_15.pkgs;
  postgresql16Packages = recurseIntoAttrs postgresql_16.pkgs;
  postgresql17Packages = recurseIntoAttrs postgresql_17.pkgs;
  postgresql18Packages = recurseIntoAttrs postgresql_18.pkgs;
  postgresql19Packages = recurseIntoAttrs postgresql_19.pkgs;
  postgresqlPackages = recurseIntoAttrs postgresql.pkgs;
  postgresql_jit = postgresql_18_jit;
  postgrest = haskellPackages.postgrest.bin;
  powerline = with python3Packages; toPythonApplication powerline;

  ppsspp-qt =
    let
      argset = {
        enableQt = true;
        enableVulkan = false; # https://github.com/hrydgard/ppsspp/issues/11628
        forceWayland = false;
      };
    in
    ppsspp.override argset;

  ppsspp-sdl =
    let
      argset = {
        enableQt = false;
        enableVulkan = true;
        forceWayland = false;
      };
    in
    ppsspp.override argset;

  ppsspp-sdl-wayland =
    let
      argset = {
        enableQt = false;
        enableVulkan = false; # https://github.com/hrydgard/ppsspp/issues/13845
        forceWayland = true;
      };
    in
    ppsspp.override argset;

  # These are used when building compiler-rt / libgcc, prior to building libc.
  preLibcHeaders =
    let
      inherit (stdenv.hostPlatform) libc;
    in
    if stdenv.hostPlatform.isMinGW then
      windows.mingw_w64_headers or fallback
    else if libc == "nblibc" then
      netbsd.headers
    else if libc == "cygwin" then
      cygwin.newlib-cygwin-headers
    else
      null;

  prefer-remote-fetch = import ../build-support/prefer-remote-fetch;
  premake = premake4;
  premake4 = callPackage ../development/tools/misc/premake { };
  premake5 = callPackage ../development/tools/misc/premake/5.nix { };

  prio-wrapped = arcan.wrapper.override {
    appls = [ prio ];
    name = "prio-wrapped";
  };

  # pam_bioapi ( see http://www.thinkwiki.org/wiki/How_to_enable_the_fingerprint_reader )
  procps =
    # some platforms refer back to this from unixtools, so this is needed to
    # break the cycle
    if stdenv.hostPlatform.isLinux || stdenv.hostPlatform.isCygwin then
      callPackage ../os-specific/linux/procps-ng { }
    else
      unixtools.procps;

  # perhaps there are better apps for this task? It's how I had configured my previous system.
  # And I don't want to rewrite all rules
  profanity = callPackage ../applications/networking/instant-messengers/profanity (
    {
    }
    // (config.profanity or { })
  );

  prospector = callPackage ../development/tools/prospector { };
  # this version should align with the static protobuf version linked into python3.pkgs.tensorflow
  # $ nix-shell -I nixpkgs=$(git rev-parse --show-toplevel) -p python3.pkgs.tensorflow --run "python3 -c 'import google.protobuf; print(google.protobuf.__version__)'"
  protobuf = protobuf_35;

  protoc-gen-grpc-web = callPackage ../development/tools/protoc-gen-grpc-web {
    protobuf = protobuf_21;
  };

  protonup-ng = with python3Packages; toPythonApplication protonup-ng;

  pruneLibtoolFiles = makeSetupHook {
    name = "prune-libtool-files";
    meta.license = lib.licenses.mit;
  } ../build-support/setup-hooks/prune-libtool-files.sh;

  pth = if stdenv.hostPlatform.isMusl then npth else gnupth;
  pub2nix = recurseIntoAttrs (callPackage ../build-support/dart/pub2nix { });
  public-inbox = perlPackages.callPackage ../servers/mail/public-inbox { };

  # PulseAudio daemons
  pulseaudioFull = pulseaudio.override {
    advancedBluetoothCodecs = true;
    airtunesSupport = true;
    bluetoothSupport = true;
    jackaudioSupport = true;
    remoteControlSupport = true;
    x11Support = true;
    zeroconfSupport = true;
  };

  pulumiPackages = recurseIntoAttrs pulumi.pkgs;

  puredata-with-plugins =
    plugins: callPackage ../by-name/pu/puredata/wrapper.nix { inherit plugins; };

  purenix = haskell.lib.compose.justStaticExecutables haskellPackages.purenix;
  purescript = callPackage ../development/compilers/purescript/purescript { };

  putty = callPackage ../applications/networking/remote/putty {
    gtk3 = if stdenv.hostPlatform.isDarwin then gtk3-x11 else gtk3;
  };

  pwntools = with python3Packages; toPythonApplication pwntools;
  py-wacz = with python3Packages; toPythonApplication wacz;
  py3dtiles = with python3Packages; toPythonApplication py3dtiles;
  py65 = with python3.pkgs; toPythonApplication py65;
  py7zr = with python3Packages; toPythonApplication py7zr;
  pycflow2dot = with python3.pkgs; toPythonApplication pycflow2dot;
  pycobertura = with python3Packages; toPythonApplication pycobertura;
  pycoin = with python3Packages; toPythonApplication pycoin;
  pycritty = with python3Packages; toPythonApplication pycritty;
  pydeps = with python3Packages; toPythonApplication pydeps;
  pyinfra = with python3Packages; toPythonApplication pyinfra;
  pylint = with python3Packages; toPythonApplication pylint;
  pyocd = with python3Packages; toPythonApplication pyocd;
  pypass = with python3Packages; toPythonApplication pypass;
  pypiserver = with python3Packages; toPythonApplication pypiserver;
  pyprof2calltree = with python3Packages; toPythonApplication pyprof2calltree;
  pypy = pypy2;
  pypy2 = pypy27;
  pypy27Packages = pypy27.pkgs;
  pypy2Packages = pypy2.pkgs;
  pypy3 = pypy311;
  pypy310Packages = pypy310.pkgs;
  pypy311Packages = pypy311.pkgs;
  pypy3Packages = pypy3.pkgs;
  pypyPackages = pypy.pkgs;

  pythia = callPackage ../development/libraries/physics/pythia {
    hepmc = hepmc2;
  };

  python-matter-server =
    with python3Packages;
    toPythonApplication (
      python-matter-server.overridePythonAttrs (oldAttrs: {
        dependencies = oldAttrs.dependencies ++ oldAttrs.optional-dependencies.server;
      })
    );

  # Should eventually be moved inside Python interpreters.
  python-setup-hook = buildPackages.callPackage ../development/interpreters/python/setup-hook.nix { };
  # Python interpreters. All standard library modules are included except for tkinter, which is
  # available as `pythonPackages.tkinter` and can be used as any other Python package.
  # When switching these sets, please update docs at ../../doc/languages-frameworks/python.md
  python3 = python314;
  # Python package sets.
  python311Packages = python311.pkgs;
  python312Packages = python312.pkgs;

  # Python interpreter that is build with all modules, including tkinter.
  # These are for compatibility and should not be used inside Nixpkgs.
  # https://py-free-threading.github.io
  python313FreeThreading = python313.override {
    enableGIL = false;
    pythonAttr = "python313FreeThreading";
    self = python313FreeThreading;
  };

  python313Packages = recurseIntoAttrs python313.pkgs;

  python314FreeThreading = python314.override {
    enableGIL = false;
    pythonAttr = "python314FreeThreading";
    self = python314FreeThreading;
  };

  python314Packages = recurseIntoAttrs python314.pkgs;

  python315FreeThreading = python315.override {
    enableGIL = false;
    pythonAttr = "python315FreeThreading";
    self = python315FreeThreading;
  };

  python315Packages = python315.pkgs;
  # pythonPackages further below, but assigned here because they need to be in sync
  python3Packages = dontRecurseIntoAttrs python314Packages;
  pythonCondaPackages = callPackage ./../development/interpreters/python/conda { };
  pythonDocs = recurseIntoAttrs (callPackage ../development/interpreters/python/cpython/docs { });
  pythonInterpreters = callPackage ./../development/interpreters/python { };
  pythonManylinuxPackages = callPackage ./../development/interpreters/python/manylinux { };
  # List of extensions with overrides to apply to all Python package sets.
  pythonPackagesExtensions = [ ];
  pyupgrade = with python3Packages; toPythonApplication pyupgrade;

  qadwaitadecorations-qt6 = callPackage ../by-name/qa/qadwaitadecorations/package.nix {
    useQt6 = true;
  };

  qbittorrent-enhanced-nox = qbittorrent-enhanced.override { guiSupport = false; };
  qbittorrent-nox = qbittorrent.override { guiSupport = false; };
  qboot = pkgsi686Linux.callPackage ../applications/virtualization/qboot { };

  qemu-python-utils = python3Packages.toPythonApplication (
    python3Packages.qemu.override {
      fuseSupport = true;
    }
  );

  # variant of qemu building user space emulator only - intended to be used from pkgsStatic
  qemu-user = qemu.override {
    userOnly = true;
  };

  qemu-utils = qemu.override {
    toolsOnly = true;
  };

  qemu_full = lowPrio (
    qemu.override {
      cephSupport = lib.meta.availableOn stdenv.hostPlatform ceph;

      glusterfsSupport =
        lib.meta.availableOn stdenv.hostPlatform glusterfs
        && lib.meta.availableOn stdenv.hostPlatform libuuid;

      smbdSupport = lib.meta.availableOn stdenv.hostPlatform samba;
    }
  );

  qemu_kvm = lowPrio (qemu.override { hostCpuOnly = true; });

  qemu_test = lowPrio (
    qemu.override {
      hostCpuOnly = true;
      nixosTestRunner = true;
    }
  );

  qgis = callPackage ../applications/gis/qgis { };
  ### APPLICATIONS / GIS
  qgis-ltr = callPackage ../applications/gis/qgis/ltr.nix { };
  qgnomeplatform = libsForQt5.callPackage ../development/libraries/qgnomeplatform { };

  qgnomeplatform-qt6 = qt6Packages.callPackage ../development/libraries/qgnomeplatform {
    useQt6 = true;
  };

  qmasterpassword-wayland = qmasterpassword.override {
    waylandSupport = true;
    x11Support = false;
  };

  qmplay2-qt5 = qmplay2.override { qtVersion = "5"; };
  qmplay2-qt6 = qmplay2.override { qtVersion = "6"; };
  qt5 = recurseIntoAttrs (__splicedPackages.callPackage ../development/libraries/qt-5/5.15 { });
  qt6 = recurseIntoAttrs (callPackage ../development/libraries/qt-6 { });

  qt6Packages = recurseIntoAttrs (
    import ./qt6-packages.nix {
      inherit
        lib
        config
        __splicedPackages
        makeScopeWithSplicing'
        generateSplicesForMkScope
        pkgsHostTarget
        kdePackages
        ;

      inherit stdenv;
    }
  );

  qtEnv = qt5.env;

  quantum-espresso = callPackage ../applications/science/chemistry/quantum-espresso {
    hdf5 = hdf5-fortran;
  };

  quartoMinimal = quarto.override {
    python3 = null;
    rWrapper = null;
  };

  quasselClient = quassel.override {
    client = true;
    monolithic = false;
    tag = "-client-qt5";
  };

  quasselDaemon = quassel.override {
    enableDaemon = true;
    monolithic = false;
    tag = "-daemon-qt5";
  };

  quodlibet = callPackage ../applications/audio/quodlibet {
    kakasi = null;
    keybinder3 = null;
    libappindicator-gtk3 = null;
    libmodplug = null;
  };

  quodlibet-full = quodlibet.override {
    inherit gtksourceview;
    kakasi = kakasi;
    keybinder3 = keybinder3;
    libappindicator-gtk3 = libappindicator-gtk3;
    libmodplug = libmodplug;
    tag = "-full";
    withDbusPython = true;
    withMusicBrainzNgs = true;
    withPahoMqtt = true;
    withPypresence = true;
    withSoco = true;
  };

  quodlibet-without-gst-plugins = quodlibet.override {
    tag = "-without-gst-plugins";
    withGstPlugins = false;
  };

  quodlibet-xine = quodlibet.override {
    tag = "-xine";
    withGstreamerBackend = false;
    withXineBackend = true;
  };

  quodlibet-xine-full = quodlibet-full.override {
    tag = "-xine-full";
    withGstreamerBackend = false;
    withXineBackend = true;
  };

  quota = if stdenv.hostPlatform.isLinux then linuxquota else unixtools.quota;
  r-ark-kernel = callPackage ../applications/editors/jupyter-kernels/r-ark { };

  rPackages =
    recurseIntoAttrsWith
      {
        eval = false;
        hydra = false;
      }
      (
        callPackage ../development/r-modules {
          overrides = (config.rPackageOverrides or (_: { })) pkgs;
        }
      );

  rWrapper = callPackage ../development/r-modules/wrapper.nix {
    # Override this attribute to register additional libraries.
    packages = [ ];

    recommendedPackages = with rPackages; [
      boot
      class
      cluster
      codetools
      foreign
      KernSmooth
      lattice
      MASS
      Matrix
      mgcv
      nlme
      nnet
      rpart
      spatial
      survival
    ];
  };

  racket-minimal = callPackage ../by-name/ra/racket/minimal.nix {
    stdenv = stdenvAdapters.makeStaticLibraries stdenv;
  };

  radare2 = callPackage ../development/tools/analysis/radare2 (
    {
      lua = lua5;
    }
    // (config.radare or { })
  );

  radianWrapper = callPackage ../development/r-modules/wrapper-radian.nix {
    # Override this attribute to register additional libraries.
    packages = [ ];

    recommendedPackages = with rPackages; [
      boot
      class
      cluster
      codetools
      foreign
      KernSmooth
      lattice
      MASS
      Matrix
      mgcv
      nlme
      nnet
      rpart
      spatial
      survival
    ];

    # Override this attribute if you want to expose R with the same set of
    # packages as specified in radian
    wrapR = false;
  };

  radicle-node-unstable = callPackage ../by-name/ra/radicle-node/unstable.nix { };
  ragel = ragelStable;
  rainbowstream = with python3.pkgs; toPythonApplication rainbowstream;
  rakudo = callPackage ../development/interpreters/rakudo { };
  rapidgzip = with python3Packages; toPythonApplication rapidgzip;
  rat-king-adventure = callPackage ../by-name/sh/shattered-pixel-dungeon/rat-king-adventure { };
  ratarmount = with python3Packages; toPythonApplication ratarmount;
  raxml-mpi = raxml.override { useMpi = true; };
  reaction-plugins = reaction.passthru.plugins;
  readline = callPackage ../development/libraries/readline/8.3.nix { };
  readline70 = callPackage ../development/libraries/readline/7.0.nix { };
  readmdict = with python3Packages; toPythonApplication readmdict;
  recoll-nox = recoll.override { withGui = false; };

  /**
    Recurse into an attribute set depending on which `config.recursionMode` is set.

    This function only affects a single attribute set;
    it does not apply itself recursively for nested attribute sets.

    # Inputs
    `modes`
    : An attribute set containg keys from `config.recursionMode` defaulting to true.
    `attrs`
    : An attribute set to scan for derivations.

    # Type
    ```
    recurseIntoAttrsWith :: AttrSet -> AttrSet -> AttrSet
    ```

    # Examples
    :::{.example}
    ## `pkgs.recurseIntoAttrsWith` usage example
    ```nix
    { pkgs ? import <nixpkgs> {} }:
    {
      myTools = pkgs.recurseIntoAttrsWith { } {
        inherit (pkgs) hello figlet;
      };
    }
    ```
    :::
  */
  recurseIntoAttrsWith =
    {
      eval ? true,
      hydra ? true,
      search ? true,
    }:
    attrs:
    attrs
    // {
      recurseForDerivations =
        let
          modes = {
            inherit hydra eval search;
          };
        in
        modes.${config.recursionMode};
    };

  redland = librdf_redland; # added 2018-04-25
  referencesByPopularity = callPackage ../build-support/references-by-popularity { };
  releaseTools = callPackage ../build-support/release { };
  remarshal = with python3Packages; toPythonApplication remarshal;

  removeReferencesTo = callPackage ../build-support/remove-references-to {
    inherit (darwin) signingUtils;
  };

  reno = with python312Packages; toPythonApplication reno;
  replaceDependencies = callPackage ../build-support/replace-dependencies.nix { };

  replaceDependency =
    {
      drv,
      newDependency,
      oldDependency,
      verbose ? true,
    }:
    replaceDependencies {
      inherit drv verbose;
      # When newDependency depends on drv, instead of causing infinite recursion, keep it as is.
      cutoffPackages = [ newDependency ];

      replacements = [
        {
          inherit oldDependency newDependency;
        }
      ];
    };

  replaceDirectDependencies = callPackage ../build-support/replace-direct-dependencies.nix { };
  replaceVars = callPackage ../build-support/replace-vars/replace-vars.nix { };
  replaceVarsWith = callPackage ../build-support/replace-vars/replace-vars-with.nix { };
  # this is used by most `fetch*` functions
  repoRevToNameMaybe = lib.repoRevToName config.fetchedSourceNameDefault;
  reposilitePlugins = recurseIntoAttrs (callPackage ../by-name/re/reposilite/plugins.nix { });
  reptor = with python3.pkgs; toPythonApplication reptor;

  resolveMirrorURLs =
    { url }:
    fetchurl {
      inherit url;
      showURLs = true;
    };

  retroarch = wrapRetroArch { };

  # includes only cores for platform with free licenses
  retroarch-free = retroarch.withCores (
    cores:
    lib.filter (
      c: (c ? libretroCore) && (lib.meta.availableOn stdenv.hostPlatform c) && (!c.meta.unfree)
    ) (lib.attrValues cores)
  );

  # includes all cores for platform (including ones with non-free licenses)
  retroarch-full = retroarch.withCores (
    cores:
    lib.filter (c: (c ? libretroCore) && (lib.meta.availableOn stdenv.hostPlatform c)) (
      lib.attrValues cores
    )
  );

  reuse = with python3.pkgs; toPythonApplication reuse;
  rfkill_udev = callPackage ../os-specific/linux/rfkill/udev.nix { };
  ringboard-wayland = callPackage ../by-name/ri/ringboard/package.nix { displayServer = "wayland"; };

  ripcord =
    if stdenv.hostPlatform.isLinux then
      qt5.callPackage ../applications/networking/instant-messengers/ripcord { }
    else
      callPackage ../applications/networking/instant-messengers/ripcord/darwin.nix { };

  rizinPlugins = recurseIntoAttrs rizin.plugins;
  rke2 = rke2_stable;
  rkpd2 = callPackage ../by-name/sh/shattered-pixel-dungeon/rkpd2 { };
  rmate = rubyPackages.rmate;

  rmg-wayland = callPackage ../by-name/rm/rmg/package.nix {
    withWayland = true;
  };

  rml = callPackage ../development/compilers/rml {
    ocamlPackages = ocaml-ng.ocamlPackages_4_14;
  };

  rnginline = with python3Packages; toPythonApplication rnginline;

  rocksdb_6_23 = rocksdb.overrideAttrs rec {
    pname = "rocksdb";
    version = "6.23.3";

    src = fetchFromGitHub {
      owner = "facebook";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-SsDqhjdCdtIGNlsMj5kfiuS3zSGwcxi4KV71d95h7yk=";
    };
  };

  rocksdb_7_10 = rocksdb.overrideAttrs rec {
    pname = "rocksdb";
    version = "7.10.2";

    src = fetchFromGitHub {
      owner = "facebook";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-U2ReSrJwjAXUdRmwixC0DQXht/h/6rV8SOf5e2NozIs=";
    };
  };

  rocksdb_8_11 = rocksdb.overrideAttrs rec {
    pname = "rocksdb";
    version = "8.11.4";

    src = fetchFromGitHub {
      owner = "facebook";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-ZrU7G3xeimF3H2LRGBDHOq936u5pH/3nGecM4XEoWc8=";
    };
  };

  rocksdb_8_3 = rocksdb.overrideAttrs rec {
    pname = "rocksdb";
    version = "8.3.2";

    src = fetchFromGitHub {
      owner = "facebook";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-mfIRQ8nkUbZ3Bugy3NAvOhcfzFY84J2kBUIUBcQ2/Qg=";
    };
  };

  rocksdb_9_10 = rocksdb.overrideAttrs rec {
    pname = "rocksdb";
    version = "9.10.0";

    src = fetchFromGitHub {
      owner = "facebook";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-G+DlQwEUyd7JOCjS1Hg1cKWmA/qAiK8UpUIKcP+riGQ=";
    };
  };

  rocmPackages = recurseIntoAttrs (callPackage ../development/rocm-modules { });

  rofi-pass-wayland = rofi-pass.override {
    backend = "wayland";
  };

  ropgadget = with python3Packages; toPythonApplication ropgadget;
  roundcube = callPackage ../servers/roundcube { };
  roundcubePlugins = recurseIntoAttrs (callPackage ../servers/roundcube/plugins { });
  rpatool = with python3Packages; toPythonApplication rpatool;

  rpm = callPackage ../tools/package-management/rpm {
    lua = lua5_4;
  };

  rr = callPackage ../development/tools/analysis/rr { };
  rst2pdf = with python3Packages; toPythonApplication rst2pdf;
  rstcheck = with python3Packages; toPythonApplication rstcheck;

  rstcheckWithSphinx = rstcheck.overridePythonAttrs (oldAttrs: {
    dependencies = oldAttrs.dependencies ++ oldAttrs.optional-dependencies.sphinx;
  });

  rstudio-server = rstudio.override { server = true; };
  rstudioServerWrapper = rstudioWrapper.override { rstudio = rstudio-server; };

  rstudioWrapper = callPackage ../development/r-modules/wrapper-rstudio.nix {
    # Override this attribute to register additional libraries.
    packages = [ ];

    recommendedPackages = with rPackages; [
      boot
      class
      cluster
      codetools
      foreign
      KernSmooth
      lattice
      MASS
      Matrix
      mgcv
      nlme
      nnet
      rpart
      spatial
      survival
    ];
  };

  rtaudio = rtaudio_5;
  rtl-sdr = rtl-sdr-blog;

  rtmpdump_gnutls = rtmpdump.override {
    gnutlsSupport = true;
    opensslSupport = false;
  };

  rubocop = rubyPackages.rubocop;
  ruby = ruby_3_4;
  ruby-lsp = rubyPackages.ruby-lsp;
  rubyPackages = rubyPackages_3_4;
  rubyPackages_3_3 = recurseIntoAttrs ruby_3_3.gems;
  rubyPackages_3_4 = recurseIntoAttrs ruby_3_4.gems;
  rubyPackages_4_0 = recurseIntoAttrs ruby_4_0.gems;
  run-npush = callPackage ../by-name/np/npush/run.nix { };
  ### SHELLS
  runtimeShell = "${runtimeShellPackage}${runtimeShellPackage.shellPath}";
  runtimeShellPackage = bashNonInteractive;
  rust = rust_1_96;
  rust-bindgen = callPackage ../development/tools/rust/bindgen { };
  rust-bindgen-unwrapped = callPackage ../development/tools/rust/bindgen/unwrapped.nix { };
  rust-jemalloc-sys-unprefixed = rust-jemalloc-sys.override { unprefixed = true; };
  rustPackages = rustPackages_1_96;
  rustPackages_1_96 = rust_1_96.packages.stable;
  rust_1_96 = callPackage ../development/compilers/rust/1_96.nix { };
  rustfmt = rustPackages.rustfmt;
  rustup = callPackage ../development/tools/rust/rustup { };

  rustup-toolchain-install-master =
    callPackage ../development/tools/rust/rustup-toolchain-install-master
      {
      };

  rusty-psn-gui = rusty-psn.override { withGui = true; };

  rxvt-unicode-emoji = rxvt-unicode.override {
    rxvt-unicode-unwrapped = rxvt-unicode-unwrapped-emoji;
  };

  rxvt-unicode-plugins = recurseIntoAttrs (
    import ../applications/terminal-emulators/rxvt-unicode-plugins {
      inherit callPackage;
    }
  );

  rxvt-unicode-unwrapped-emoji = rxvt-unicode-unwrapped.override {
    emojiSupport = true;
  };

  s3-credentials = with python3Packages; toPythonApplication s3-credentials;
  safety-cli = with python3.pkgs; toPythonApplication safety;
  samba = samba4;
  samba4 = callPackage ../servers/samba/4.x.nix { };

  samba4Full = lowPrio (
    samba4.override {
      enableCephFS = !stdenv.hostPlatform.isAarch64;
      enableDomainController = true;
      enableLDAP = true;
      enableMDNS = true;
      enablePrinting = true;
      enableRegedit = true;
    }
  );

  sambaFull = samba4Full;
  samsung-unified-linux-driver = res.samsung-unified-linux-driver_4_01_17;
  samsung-unified-linux-driver_1_00_37 = callPackage ../misc/cups/drivers/samsung/1.00.37.nix { };
  samsung-unified-linux-driver_4_01_17 = callPackage ../misc/cups/drivers/samsung/4.01.17.nix { };
  sane-backends = callPackage ../applications/graphics/sane/backends (config.sane or { });
  sane-drivers = callPackage ../applications/graphics/sane/drivers.nix { };
  sane-frontends = callPackage ../applications/graphics/sane/frontends.nix { };
  saxon-he = saxon_12-he;
  ### DEVELOPMENT / LIBRARIES / JAVA
  saxonb = saxonb_8_8;
  sbcl = sbcl_2_6_5;
  sbclPackages = recurseIntoAttrs sbcl.pkgs;

  # Steel Bank Common Lisp
  sbcl_2_4_6 = wrapLisp {
    faslExt = "fasl";

    flags = [
      "--dynamic-space-size"
      "3000"
    ];

    pkg = callPackage ../development/compilers/sbcl { version = "2.4.6"; };
  };

  sbcl_2_6_4 = wrapLisp {
    faslExt = "fasl";

    flags = [
      "--dynamic-space-size"
      "3000"
    ];

    pkg = callPackage ../development/compilers/sbcl { version = "2.6.4"; };
  };

  sbcl_2_6_5 = wrapLisp {
    faslExt = "fasl";

    flags = [
      "--dynamic-space-size"
      "3000"
    ];

    pkg = callPackage ../development/compilers/sbcl { version = "2.6.5"; };
  };

  sbt = callPackage ../development/tools/build-managers/sbt { };
  sbt-with-scala-native = callPackage ../development/tools/build-managers/sbt/scala-native.nix { };
  scala = scala_3;

  scala-runners = callPackage ../development/compilers/scala-runners {
    coursier = coursier.override { jre = jdk8; };
  };

  scala_2_12 = callPackage ../development/compilers/scala/2.x.nix { majorVersion = "2.12"; };
  scala_2_13 = callPackage ../development/compilers/scala/2.x.nix { majorVersion = "2.13"; };
  scala_3 = callPackage ../development/compilers/scala { };

  scalapack-ilp64 = scalapack.override {
    blas = blas-ilp64;
    lapack = lapack-ilp64;
  };

  scalene = with python3Packages; toPythonApplication scalene;

  scheherazade-new = scheherazade.override {
    version = "4.400";
  };

  scour = with python3Packages; toPythonApplication scour;
  scx = recurseIntoAttrs (callPackage ../os-specific/linux/scx { });
  sdkmanager = with python3Packages; toPythonApplication sdkmanager;
  seabios-coreboot = seabios.override { ___build-type = "coreboot"; };
  seabios-csm = seabios.override { ___build-type = "csm"; };
  seabios-qemu = seabios.override { ___build-type = "qemu"; };
  seaborn-data = callPackage ../tools/misc/seaborn-data { };
  segger-jlink-headless = callPackage ../by-name/se/segger-jlink/package.nix { headless = true; };
  selinuxPackages = recurseIntoAttrs (callPackage ../os-specific/linux/selinux { });
  semeru-bin = semeru-bin-21;
  semeru-bin-11 = javaPackages.compiler.semeru-bin.jdk-11;
  semeru-bin-17 = javaPackages.compiler.semeru-bin.jdk-17;
  semeru-bin-21 = javaPackages.compiler.semeru-bin.jdk-21;
  semeru-bin-8 = javaPackages.compiler.semeru-bin.jdk-8;
  semeru-jre-bin = semeru-jre-bin-21;
  semeru-jre-bin-11 = javaPackages.compiler.semeru-bin.jre-11;
  semeru-jre-bin-17 = javaPackages.compiler.semeru-bin.jre-17;
  semeru-jre-bin-21 = javaPackages.compiler.semeru-bin.jre-21;
  semeru-jre-bin-8 = javaPackages.compiler.semeru-bin.jre-8;
  semgrep = python3.pkgs.toPythonApplication python3.pkgs.semgrep;

  separateDebugInfo = makeSetupHook {
    name = "separate-debug-info-hook";
    meta.license = lib.licenses.mit;
  } ../build-support/setup-hooks/separate-debug-info.sh;

  seqdiag = with python3Packages; toPythonApplication seqdiag;

  setupDebugInfoDirs = makeSetupHook {
    name = "setup-debug-info-dirs-hook";
    meta.license = lib.licenses.mit;
  } ../build-support/setup-hooks/setup-debug-info-dirs.sh;

  setupSystemdUnits = callPackage ../build-support/setup-systemd-units.nix { };
  sev-snp-measure = with python3Packages; toPythonApplication sev-snp-measure;

  sgt-puzzles-mobile = callPackage ../by-name/sg/sgt-puzzles/package.nix {
    isMobile = true;
  };

  sgx-psw = callPackage ../os-specific/linux/sgx/psw {
    protobuf = protobuf_33;
  };

  shairport-sync-airplay2 = shairport-sync.override {
    enableAirplay2 = true;
  };

  shake =
    # TODO: Erroneous references to GHC on aarch64-darwin: https://github.com/NixOS/nixpkgs/issues/318013
    (
      if stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64 then
        lib.id
      else
        haskell.lib.compose.justStaticExecutables
    )
      haskellPackages.shake;

  shaperglot = with python3Packages; toPythonApplication shaperglot;

  shellcheck = callPackage ../development/tools/shellcheck {
    inherit (__splicedPackages.haskellPackages) ShellCheck;
  };

  # Minimal shellcheck executable for package checks.
  # Use shellcheck which does not include docs, as
  # pandoc takes long to build and documentation isn't needed for just running the cli
  shellcheck-minimal = haskell.lib.compose.justStaticExecutables shellcheck.unwrapped;
  shellify = haskellPackages.shellify.bin;
  shiv = with python3Packages; toPythonApplication shiv;
  shorter-pixel-dungeon = callPackage ../by-name/sh/shattered-pixel-dungeon/shorter-pixel-dungeon { };
  siesta-mpi = callPackage ../by-name/si/siesta/package.nix { useMpi = true; };
  sieveshell = with python3.pkgs; toPythonApplication managesieve;

  simavr = callPackage ../development/tools/simavr {
    avrgcc = pkgsCross.avr.buildPackages.gcc;
    avrlibc = pkgsCross.avr.libc;
  };

  simple-dftd3 = callPackage ../development/libraries/science/chemistry/simple-dftd3 { };
  simpleBuildTool = sbt;
  simpleitk = callPackage ../development/libraries/simpleitk { lua = lua5_4; };
  ### SCIENCE / ELECTRONICS
  simulide_0_4_15 = callPackage ../by-name/si/simulide/package.nix { versionNum = "0.4.15"; };
  simulide_1_0_0 = callPackage ../by-name/si/simulide/package.nix { versionNum = "1.0.0"; };
  simulide_1_1_0 = callPackage ../by-name/si/simulide/package.nix { versionNum = "1.1.0"; };
  simulide_1_2_0 = callPackage ../by-name/si/simulide/package.nix { versionNum = "1.2.0"; };
  # get binaries without data built by Hydra
  simutrans_binaries = lowPrio simutrans.binaries;
  singularity-tools = callPackage ../build-support/singularity-tools { };
  skawarePackages = recurseIntoAttrs (callPackage ../development/skaware-packages { });
  skkDictionaries = recurseIntoAttrs (callPackages ../tools/inputmethods/skk/skk-dicts { });

  slibGuile = callPackage ../development/libraries/slib {
    scheme = guile;
  };

  slither-analyzer = with python3Packages; toPythonApplication slither-analyzer;
  smlnj = callPackage ../development/compilers/smlnj { };
  # smlnjBootstrap should be redundant, now that smlnj works on Darwin natively
  smlnjBootstrap = callPackage ../development/compilers/smlnj/bootstrap.nix { };
  snscrape = with python3Packages; toPythonApplication snscrape;
  socialscan = with python3.pkgs; toPythonApplication socialscan;
  solargraph = rubyPackages.solargraph;
  solc-select = with python3Packages; toPythonApplication solc-select;

  sourceAndTags = callPackage ../misc/source-and-tags {
    hasktags = haskellPackages.hasktags;
  };

  sourceFromHead = callPackage ../build-support/source-from-head-fun.nix { };
  spacecookie = haskell.lib.compose.justStaticExecutables haskellPackages.spacecookie;
  spacx-gtk-theme = callPackage ../data/themes/gtk-theme-framework { theme = "spacx"; };
  spandsp = callPackage ../development/libraries/spandsp { };
  spandsp3 = callPackage ../development/libraries/spandsp/3.nix { };
  spark = spark_4_0;
  spark3 = spark_3_5;
  spark4 = spark_4_0;
  # aka., pgp-tools
  specup = haskellPackages.specup.bin;

  speechd-minimal = speechd.override {
    libsOnly = true;
    withAlsa = false;
    withEspeak = false;
    withFlite = false;
    withLibao = false;
    withOss = false;
    withPico = false;
    withPulse = false;
  };

  speedtest-cli = with python3Packages; toPythonApplication speedtest-cli;

  speex = callPackage ../development/libraries/speex {
    fftw = fftwFloat;
  };

  speexdsp = callPackage ../development/libraries/speexdsp {
    fftw = fftwFloat;
  };

  spglib = callPackage ../development/libraries/spglib {
    inherit (llvmPackages) openmp;
  };

  sphinx = with python3Packages; toPythonApplication sphinx;
  sphinx-autobuild = with python3Packages; toPythonApplication sphinx-autobuild;
  sphinx-serve = with python3Packages; toPythonApplication sphinx-serve;
  # to match naming of other package repositories
  spire-agent = spire.agent;
  spire-server = spire.server;

  splint = callPackage ../development/tools/analysis/splint {
    flex = flex_2_5_35;
  };

  splot = haskell.lib.compose.justStaticExecutables haskellPackages.splot;
  spyder = with python3.pkgs; toPythonApplication spyder;

  sqitchMysql =
    (callPackage ../development/tools/misc/sqitch {
      mysqlSupport = true;
    }).overrideAttrs
      { pname = "sqitch-mysql"; };

  sqitchPg =
    (callPackage ../development/tools/misc/sqitch {
      postgresqlSupport = true;
    }).overrideAttrs
      { pname = "sqitch-pg"; };

  sqitchSqlite =
    (callPackage ../development/tools/misc/sqitch {
      sqliteSupport = true;
    }).overrideAttrs
      { pname = "sqitch-sqlite"; };

  sqlite = lowPrio (callPackage ../development/libraries/sqlite { });
  sqlite-interactive = (sqlite.override { interactive = true; }).bin;
  sqlite-utils = with python3Packages; toPythonApplication sqlite-utils;
  sqlmap = with python3Packages; toPythonApplication sqlmap;

  squeak = callPackage ../development/compilers/squeak {
    stdenv = clangStdenv;
  };

  squeezelite-pulse = callPackage ../by-name/sq/squeezelite/package.nix {
    audioBackend = "pulse";
  };

  squirrel-sql = callPackage ../development/tools/database/squirrel-sql {
    drivers = [
      jtds_jdbc
      mssql_jdbc
      mysql_jdbc
      postgresql_jdbc
    ];
  };

  srcOnly = callPackage ../build-support/src-only { };
  ssh-copy-id = callPackage ../tools/networking/openssh/copyid.nix { };
  sshd-openpgp-auth = callPackage ../by-name/ss/ssh-openpgp-auth/daemon.nix { };
  sshfs = sshfs-fuse; # added 2017-08-14

  sslscan = callPackage ../tools/security/sslscan {
    openssl = openssl.override { withZlib = true; };
  };

  stac-validator = with python3Packages; toPythonApplication stac-validator;

  stack =
    # TODO: Erroneous references to GHC on aarch64-darwin: https://github.com/NixOS/nixpkgs/issues/318013
    (
      if stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64 then
        lib.id
      else
        haskell.lib.compose.justStaticExecutables
    )
      haskellPackages.stack;

  stack2nix =
    with haskell.lib;
    overrideCabal (justStaticExecutables haskellPackages.stack2nix) (_: {
      postInstall = ''
        wrapProgram $out/bin/stack2nix \
          --prefix PATH ":" "${git}/bin:${cabal-install}/bin"
      '';

      executableToolDepends = [ makeWrapper ];
    });

  stalwart-enterprise = stalwart_0_15.override {
    stalwartEnterprise = true;
  };

  stalwart-spam-filter = stalwart_0_15.spam-filter;
  stalwart-webadmin = stalwart_0_15.webadmin;
  staticjinja = with python3.pkgs; toPythonApplication staticjinja;

  stdenvNoLibc =
    if stdenvNoCC.hostPlatform != stdenvNoCC.buildPlatform then
      (
        if stdenvNoCC.hostPlatform.isDarwin || stdenvNoCC.hostPlatform.useLLVM or false then
          overrideCC stdenvNoCC buildPackages.llvmPackages.clangNoLibc
        else
          gccCrossLibcStdenv
      )
    else
      mkStdenvNoLibs stdenv;

  stdenvNoLibs =
    if stdenvNoCC.hostPlatform != stdenvNoCC.buildPlatform then
      # We cannot touch binutils or cc themselves, because that will cause
      # infinite recursion. So instead, we just choose a libc based on the
      # current platform. That means we won't respect whatever compiler was
      # passed in with the stdenv stage argument.
      #
      # TODO It would be much better to pass the `stdenvNoCC` and *unwrapped*
      # cc, bintools, compiler-rt equivalent, etc. and create all final stdenvs
      # as part of the stage. Then we would never be tempted to override a later
      # thing to to create an earlier thing (leading to infinite recursion) and
      # we also would still respect the stage arguments choices for these
      # things.
      (
        if stdenvNoCC.hostPlatform.isDarwin || stdenvNoCC.hostPlatform.useLLVM or false then
          overrideCC stdenvNoCC buildPackages.llvmPackages.clangNoCompilerRt
        else
          gccCrossLibcStdenv
      )
    else
      mkStdenvNoLibs stdenv;

  # A stdenv capable of building 32-bit binaries.
  # On x86_64-linux, it uses GCC compiled with multilib support; on i686-linux,
  # it's just the plain stdenv.
  stdenv_32bit = lowPrio (if stdenv.hostPlatform.is32bit then stdenv else multiStdenv);
  steam-run = steam.run;
  steam-run-free = steam.run-free;
  steampipePackages = recurseIntoAttrs (callPackage ../tools/misc/steampipe-packages { });

  stirling-pdf-desktop = callPackage ../by-name/st/stirling-pdf/package.nix {
    isDesktopVariant = true;
  };

  stlink-gui = callPackage ../by-name/st/stlink/package.nix { withGUI = true; };
  stm32loader = with python3Packages; toPythonApplication stm32loader;
  stoken = callPackage ../tools/security/stoken (config.stoken or { });
  streamlink-twitch-gui-bin = callPackage ../applications/video/streamlink-twitch-gui/bin.nix { };
  ### SCIENCE/MACHINE LEARNING
  streamlit = with python3Packages; toPythonApplication streamlit;
  strip-nondeterminism = perlPackages.strip-nondeterminism;
  strongswanNM = strongswan.override { enableNetworkManager = true; };
  strongswanTNC = strongswan.override { enableTNC = true; };
  strongswanTPM = strongswan.override { enableTPM2 = true; };
  stumpwm-unwrapped = sbcl.pkgs.stumpwm;
  stutter = haskell.lib.compose.justStaticExecutables haskellPackages.stutter;
  stylish-cabal = haskell.lib.compose.justStaticExecutables haskellPackages.stylish-cabal;
  stylish-haskell = haskell.lib.compose.justStaticExecutables haskellPackages.stylish-haskell;
  su = shadow.su;
  sublime3 = sublime3Packages.sublime3;
  sublime3-dev = sublime3Packages.sublime3-dev;

  sublime3Packages = recurseIntoAttrs (
    callPackage ../applications/editors/sublime/3/packages.nix { }
  );

  substitute = callPackage ../build-support/substitute/substitute.nix { };

  subversionClient = subversion.override {
    bdbSupport = false;
    perlBindings = true;
    pythonBindings = true;
  };

  subzerod = with python3Packages; toPythonApplication subzerod;

  summoning-pixel-dungeon =
    callPackage ../by-name/sh/shattered-pixel-dungeon/summoning-pixel-dungeon
      { };

  super-slicer-beta = super-slicer.beta;
  super-slicer-latest = super-slicer.latest;

  supercollider = libsForQt5.callPackage ../development/interpreters/supercollider {
    fftw = fftwSinglePrec;
  };

  supercollider-with-plugins = callPackage ../development/interpreters/supercollider/wrapper.nix {
    plugins = [ ];
  };

  supercollider-with-sc3-plugins = supercollider-with-plugins.override {
    plugins = with supercolliderPlugins; [ sc3-plugins ];
  };

  supercolliderPlugins = recurseIntoAttrs {
    sc3-plugins = callPackage ../development/interpreters/supercollider/plugins/sc3-plugins.nix {
      fftw = fftwSinglePrec;
    };
  };

  supercollider_scel = supercollider.override { useSCEL = true; };

  supersonic-wayland = supersonic.override {
    waylandSupport = true;
  };

  svg2tikz = with python3.pkgs; toPythonApplication svg2tikz;

  svn-all-fast-export =
    libsForQt5.callPackage ../applications/version-management/svn-all-fast-export
      { };

  sway-contrib = recurseIntoAttrs (callPackages ../applications/misc/sway-contrib { });

  sweethome3d = recurseIntoAttrs (
    (callPackage ../applications/misc/sweethome3d { })
    // (callPackage ../applications/misc/sweethome3d/editors.nix {
      sweethome3dApp = sweethome3d.application;
    })
  );

  swi-prolog-gui = swi-prolog.override { withGui = true; };
  swift-corelibs-libdispatch = swiftPackages.Dispatch;
  swiftPackages = recurseIntoAttrs (callPackage ../development/compilers/swift { });
  swiftclient = with python313Packages; toPythonApplication python-swiftclient;
  synergyWithoutGUI = synergy.override { withGUI = false; };

  sysdig = callPackage ../os-specific/linux/sysdig {
    kernel = null;
  }; # sysdig is a client, for a driver look at linuxPackagesFor

  sysprof = callPackage ../development/tools/profiling/sysprof { };

  system-config-printer = callPackage ../tools/misc/system-config-printer {
    libxml2 = libxml2Python;
  };

  system-sendmail = lowPrio (callPackage ../servers/mail/system-sendmail { });

  systemd = callPackage ../os-specific/linux/systemd {
    # break some cyclic dependencies
    util-linux = util-linuxMinimal;
  };

  systemdLibs = systemdMinimal.override {
    pname = "systemd-minimal-libs";
    buildLibsOnly = true;
  };

  systemdMinimal = systemd.override {
    pname = "systemd-minimal";
    withAcl = false;
    withAnalyze = false;
    withApparmor = false;
    withAudit = false;
    withBootloader = false;
    withCompression = false;
    withCoredump = false;
    withCryptsetup = false;
    withDocumentation = false;
    withEfi = false;
    withFido2 = false;
    # withKmod = false; # breaks udevCheckHook of bcache-tools
    withFirstboot = false;
    withGcrypt = false;
    withHomed = false;
    withHostnamed = false;
    withHwdb = false;
    withImds = false;
    withImportd = false;
    withKexectools = false;
    withLibBPF = false;
    withLibarchive = false;
    withLibidn2 = false;
    withLibseccomp = false;
    withLocaled = false;
    withLogind = false;
    withMachined = false;
    withNetworkd = false;
    withNspawn = false;
    withNss = false;
    withOomd = false;
    withOpenSSL = false;
    withPCRE2 = false;
    withPam = false;
    withPasswordQuality = false;
    withPolkit = false;
    withPortabled = false;
    withQrencode = false;
    withRemote = false;
    withRepart = false;
    withResolved = false;
    withShellCompletions = false;
    withSysinstall = false;
    withSysupdate = false;
    withSysusers = false;
    withTimedated = false;
    withTimesyncd = false;
    withTpm2Tss = false;
    withUkify = false;
    withUserDb = false;
    withVConsole = false;
    withVmspawn = false;
  };

  # We do not want to include ukify in the normal systemd attribute as it
  # relies on Python at runtime.
  systemdUkify = systemd.override {
    withUkify = true;
  };

  sysvtools = sysvinit.override {
    withoutInitTools = true;
  };

  szurubooru = callPackage ../servers/web-apps/szurubooru { };

  tabbed = callPackage ../applications/window-managers/tabbed {
    # if you prefer a custom config, write the config.h in tabbed.config.h
    # and enable
    # customConfig = builtins.readFile ./tabbed.config.h;
  };

  tabview = with python3Packages; toPythonApplication tabview;

  taffybar = callPackage ../applications/window-managers/taffybar {
    inherit (haskellPackages) ghcWithPackages taffybar;
  };

  tarsum = callPackage ../build-support/docker/tarsum.nix { };

  tartube-yt-dlp = tartube.override {
    youtube-dl = yt-dlp;
  };

  taxi-cli = with python3Packages; toPythonApplication taxi;
  tblite = callPackage ../development/libraries/science/chemistry/tblite { };
  tcl = tcl-8_6;
  tcl-8_5 = callPackage ../development/interpreters/tcl/8.5.nix { };
  tcl-8_6 = callPackage ../development/interpreters/tcl/8.6.nix { };
  tcl-9_0 = callPackage ../development/interpreters/tcl/9.0.nix { };

  # We don't need minor-versioned package sets thanks to the tcl stubs mechanism.
  # Major versions have bigger incompatibilities and need package sets.
  tcl8Packages = recurseIntoAttrs (
    callPackage ./tcl-packages.nix {
      tcl = tcl-8_6;
      tk = tk-8_6;
    }
  );

  tcl9Packages = recurseIntoAttrs (
    callPackage ./tcl-packages.nix {
      tcl = tcl-9_0;
      tk = tk-9_0;
    }
  );

  tclPackages = dontRecurseIntoAttrs tcl8Packages;
  tclap = tclap_1_2;
  tclap_1_2 = callPackage ../development/libraries/tclap/1.2.nix { };
  tclap_1_4 = callPackage ../development/libraries/tclap/1.4.nix { };
  tclreadline = tclPackages.tclreadline;
  tdarr-node = tdarrPackages.node;
  tdarr-server = tdarrPackages.server;
  tdarrPackages = callPackage ../tools/misc/tdarr { };

  teensyduino = arduino-core.override {
    withGui = true;
    withTeensyduino = true;
  };

  teeworlds-server = teeworlds.override { buildClient = false; };

  telegram-desktop =
    kdePackages.callPackage ../applications/networking/instant-messengers/telegram/telegram-desktop
      {
        stdenv = if stdenv.hostPlatform.isDarwin then llvmPackages_19.stdenv else stdenv;
      };

  telepresence = callPackage ../tools/networking/telepresence {
    pythonPackages = python3Packages;
  };

  temurin-bin = temurin-bin-21;
  temurin-bin-11 = javaPackages.compiler.temurin-bin.jdk-11;
  temurin-bin-17 = javaPackages.compiler.temurin-bin.jdk-17;
  temurin-bin-21 = javaPackages.compiler.temurin-bin.jdk-21;
  temurin-bin-25 = javaPackages.compiler.temurin-bin.jdk-25;
  ### DEVELOPMENT / COMPILERS
  temurin-bin-26 = javaPackages.compiler.temurin-bin.jdk-26;
  temurin-bin-8 = javaPackages.compiler.temurin-bin.jdk-8;
  temurin-jre-bin = temurin-jre-bin-21;
  temurin-jre-bin-11 = javaPackages.compiler.temurin-bin.jre-11;
  temurin-jre-bin-17 = javaPackages.compiler.temurin-bin.jre-17;
  temurin-jre-bin-21 = javaPackages.compiler.temurin-bin.jre-21;
  temurin-jre-bin-25 = javaPackages.compiler.temurin-bin.jre-25;
  temurin-jre-bin-26 = javaPackages.compiler.temurin-bin.jre-26;
  temurin-jre-bin-8 = javaPackages.compiler.temurin-bin.jre-8;

  tengine = callPackage ../servers/http/tengine {
    modules = with nginxModules; [
      rtmp
      dav
      moreheaders
      modsecurity
    ];
  };

  terminaltexteffects = with python3Packages; toPythonApplication terminaltexteffects;
  terraform = terraform_1;

  terraform-providers = recurseIntoAttrs (
    callPackage ../applications/networking/cluster/terraform-providers { }
  );

  tesseract = tesseract5;
  testdisk = libsForQt5.callPackage ../tools/system/testdisk { };
  testdisk-qt = testdisk.override { enableQt = true; };
  testers = callPackage ../build-support/testers { };
  # Tests should not appear in search results
  tests = recurseIntoAttrsWith { search = false; } (callPackages ../test { });
  tex-gyre = recurseIntoAttrs (callPackages ../data/fonts/tex-gyre { });
  tex-gyre-math = recurseIntoAttrs (callPackages ../data/fonts/tex-gyre-math { });
  texFunctions = callPackage ../tools/typesetting/tex/nix pkgs;
  texinfo = texinfo7;
  texinfoInteractive = texinfo.override { interactive = true; };
  texinfoPackages = callPackages ../development/tools/misc/texinfo/packages.nix { };
  # TeX Live; see https://nixos.org/nixpkgs/manual/#sec-language-texlive
  texlive = callPackage ../tools/typesetting/tex/texlive { };
  texliveFullWithDocs = texliveFull.overrideAttrs { withDocs = true; };
  texlivePackages = recurseIntoAttrs (lib.mapAttrs (_: v: v.build) texlive.pkgs);

  texmacs = callPackage ../applications/editors/texmacs {
    extraFonts = true;
  };

  teyjus = callPackage ../development/compilers/teyjus {
    inherit (ocaml-ng.ocamlPackages_4_14) buildDunePackage;
    stdenv = gcc14Stdenv;
  };

  tflint-plugins = recurseIntoAttrs (callPackage ../development/tools/analysis/tflint-plugins { });
  themes = name: callPackage (../data/misc/themes + ("/" + name + ".nix")) { };

  threads =
    lib.optionalAttrs (stdenv.hostPlatform.isMinGW && !(stdenv.hostPlatform.useLLVM or false))
      {
        # other possible values: win32 or posix
        model = "mcf";
        # For win32 or posix set this to null
        package = windows.mcfgthreads;
      };

  thunderbird = wrapThunderbird thunderbird-unwrapped { };
  thunderbird-140 = wrapThunderbird thunderbirdPackages.thunderbird-140 { };
  thunderbird-140-unwrapped = thunderbirdPackages.thunderbird-140;
  thunderbird-bin = thunderbird-latest-bin;
  thunderbird-esr = wrapThunderbird thunderbird-esr-unwrapped { };

  thunderbird-esr-bin = wrapThunderbird thunderbird-esr-bin-unwrapped {
    pname = "thunderbird-esr-bin";
    libName = "thunderbird-bin-${thunderbird-esr-bin-unwrapped.version}";
  };

  thunderbird-esr-bin-unwrapped = callPackage ../applications/networking/mailreaders/thunderbird-bin {
    generated = import ../applications/networking/mailreaders/thunderbird-bin/release_esr_sources.nix;
    versionSuffix = "esr";
  };

  thunderbird-esr-unwrapped = thunderbirdPackages.thunderbird-esr;
  thunderbird-latest = wrapThunderbird thunderbird-latest-unwrapped { };

  thunderbird-latest-bin = wrapThunderbird thunderbird-latest-bin-unwrapped {
    pname = "thunderbird-bin";
    libName = "thunderbird-bin-${thunderbird-latest-bin-unwrapped.version}";
  };

  thunderbird-latest-bin-unwrapped =
    callPackage ../applications/networking/mailreaders/thunderbird-bin
      {
        generated = import ../applications/networking/mailreaders/thunderbird-bin/release_sources.nix;
      };

  thunderbird-latest-unwrapped = thunderbirdPackages.thunderbird-latest;
  thunderbird-unwrapped = thunderbirdPackages.thunderbird;

  thunderbirdPackages = recurseIntoAttrs (
    callPackage ../applications/networking/mailreaders/thunderbird/packages.nix {
      callPackage = newScope {
        inherit (rustPackages) cargo rustc;
      };
    }
  );

  tinywl = callPackage ../applications/window-managers/tinywl {
    wlroots = wlroots_0_20;
  };

  tinyxml = callPackage ../development/libraries/tinyxml/2.6.2.nix { };
  tk = tk-8_6;
  tk-8_5 = callPackage ../development/libraries/tk/8.5.nix { tcl = tcl-8_5; };
  tk-8_6 = callPackage ../development/libraries/tk/8.6.nix { };
  tk-9_0 = callPackage ../development/libraries/tk/9.0.nix { tcl = tcl-9_0; };

  tlaps = callPackage ../applications/science/logic/tlaplus/tlaps.nix {
    inherit (ocaml-ng.ocamlPackages_4_14_unsafe_string) ocaml;
  };

  tldr-hs = haskellPackages.tldr;

  tlp = callPackage ../tools/misc/tlp {
    inherit (linuxPackages) x86_energy_perf_policy;
  };

  tmuxPlugins = recurseIntoAttrs (callPackage ../misc/tmux-plugins { });
  tomcat = tomcat11;
  tomcat-native = callPackage ../servers/http/tomcat/tomcat-native.nix { };
  torcs-without-data = callPackage ../by-name/to/torcs/without-data.nix { };
  tower-pixel-dungeon = callPackage ../by-name/sh/shattered-pixel-dungeon/tower-pixel-dungeon { };

  tpm2-totp-with-plymouth = tpm2-totp.override {
    withPlymouth = true;
  };

  tpm2-tss = callPackage ../development/libraries/tpm2-tss {
    autoreconfHook = buildPackages.autoreconfHook269;
  };

  trackma-curses = trackma.override { withCurses = true; };
  trackma-gtk = trackma.override { withGTK = true; };
  trackma-qt = trackma.override { withQT = true; };
  translatelocally-models = recurseIntoAttrs (callPackages ../misc/translatelocally-models { });
  translatepy = with python3.pkgs; toPythonApplication translatepy;
  tree-sitter-grammars = recurseIntoAttrs tree-sitter.grammarsScope;
  trezor-agent = with python3Packages; toPythonApplication trezor-agent;

  trezorctl =
    with python3Packages;
    toPythonApplication (
      trezor.overridePythonAttrs (oldAttrs: {
        dependencies = oldAttrs.dependencies ++ oldAttrs.optional-dependencies.full;
      })
    );

  trilinos-mpi = trilinos.override { withMPI = true; };
  troveclient = with python313Packages; toPythonApplication python-troveclient;
  truecrack-cuda = truecrack.override { cudaSupport = true; };
  trustedqsl = tqsl; # Alias added 2019-02-10
  trytond = with python3Packages; toPythonApplication trytond;
  tshark = wireshark-cli;
  tsm-client-withGui = callPackage ../by-name/ts/tsm-client/package.nix { enableGui = true; };
  ttfautohint-nox = ttfautohint.override { enableGUI = false; };
  ttp = with python3.pkgs; toPythonApplication ttp;

  tuxclocker = libsForQt5.callPackage ../applications/misc/tuxclocker {
    tuxclocker-plugins = tuxclocker-plugins-with-unfree;
  };

  tuxclocker-without-unfree = libsForQt5.callPackage ../applications/misc/tuxclocker { };
  tw = ocamlPackages.tw.bin;
  tweet-hs = haskell.lib.compose.justStaticExecutables haskellPackages.tweet-hs;
  twine = with python3Packages; toPythonApplication twine;
  typstPackages = recurseIntoAttrs typst.packages;
  udev = if lib.meta.availableOn stdenv.hostPlatform systemdLibs then systemdLibs else libudev-zero;
  ueberzug = with python3Packages; toPythonApplication ueberzug;
  uefitool = uefitoolPackages.new-engine;
  uefitoolPackages = recurseIntoAttrs (callPackage ../tools/system/uefitool/variants.nix { });
  ufolint = with python3Packages; toPythonApplication ufolint;

  uftraceFull = uftrace.override {
    withLuaJIT = true;
    withPython = true;
  };

  uhdMinimal = uhd.override {
    enablePythonApi = false;
    enableUtils = false;
  };

  uiua-unstable = callPackage ../by-name/ui/uiua/package.nix { uiua_versionType = "unstable"; };
  ultrastar-creator = callPackage ../tools/misc/ultrastar-creator { };
  ultrastar-manager = libsForQt5.callPackage ../tools/misc/ultrastar-manager { };

  unbound-full = unbound.override {
    python = python3;
    withDNSCrypt = true;
    withDNSTAP = true;
    withDoH = true;
    withDoQ = true;
    withDynlibModule = true;
    withECS = true;
    withPythonModule = true;
    withRedis = true;
    withSystemd = true;
    withTFO = true;
  };

  unbound-with-systemd = unbound.override {
    withSystemd = true;
  };

  ungoogled-chromium = callPackage ../applications/networking/browsers/chromium (
    (config.chromium or { })
    // {
      ungoogled = true;
    }
  );

  unify = with python3Packages; toPythonApplication unify;
  unigine-sanctuary = pkgsi686Linux.callPackage ../applications/graphics/unigine-sanctuary { };
  unigine-tropics = pkgsi686Linux.callPackage ../applications/graphics/unigine-tropics { };
  uniscribe = callPackage ../tools/text/uniscribe { };
  unixodbcDrivers = recurseIntoAttrs (callPackages ../development/libraries/unixODBCDrivers { });
  # Unix tools
  unixtools = recurseIntoAttrs (callPackages ./unixtools.nix { });
  unqlite = lowPrio (callPackage ../development/libraries/unqlite { });
  unrpa = with python3Packages; toPythonApplication unrpa;
  unstableGitUpdater = callPackage ../common-updater/unstable-updater.nix { };
  unused_deps = bazel-buildtools;
  unzipNLS = lowPrio (unzip.override { enableNLS = true; });
  update-dotdee = with python3Packages; toPythonApplication update-dotdee;
  update-nix-fetchgit = haskell.lib.compose.justStaticExecutables haskellPackages.update-nix-fetchgit;
  update-resolv-conf = callPackage ../tools/networking/openvpn/update-resolv-conf.nix { };
  update-systemd-resolved = callPackage ../tools/networking/openvpn/update-systemd-resolved.nix { };

  updateAutotoolsGnuConfigScriptsHook = makeSetupHook {
    name = "update-autotools-gnu-config-scripts-hook";

    substitutions = {
      gnu_config = gnu-config.override {
        runtimeShell = if stdenv.buildPlatform == stdenv.hostPlatform then stdenv.shell else runtimeShell;
      };
    };

    meta.license = lib.licenses.mit;
  } ../build-support/setup-hooks/update-autotools-gnu-config-scripts.sh;

  usbrelay = callPackage ../os-specific/linux/usbrelay { };
  usbrelayd = callPackage ../os-specific/linux/usbrelay/daemon.nix { };

  useOldCXXAbi = makeSetupHook {
    name = "use-old-cxx-abi-hook";
    meta.license = lib.licenses.mit;
  } ../build-support/setup-hooks/use-old-cxx-abi.sh;

  usort = with python3Packages; toPythonApplication usort;
  ustream-ssl = callPackage ../development/libraries/ustream-ssl { ssl_implementation = openssl; };

  ustream-ssl-mbedtls = callPackage ../development/libraries/ustream-ssl {
    ssl_implementation = mbedtls;
  };

  util-linuxMinimal = util-linux.override {
    cryptsetupSupport = false;
    fetchurl = stdenv.fetchurlBoot;
    ncursesSupport = false;
    nlsSupport = false;
    pamSupport = false;
    shadowSupport = false;
    systemdSupport = false;
    translateManpages = false;
    withLastlog = false;
  };

  uuagc = haskell.lib.compose.justStaticExecutables haskellPackages.uuagc;
  uusi = haskell.lib.compose.justStaticExecutables haskellPackages.uusi;
  uutils-coreutils-noprefix = uutils-coreutils.override { prefix = null; };
  valeStyles = recurseIntoAttrs (callPackages ../by-name/va/vale/styles.nix { });

  valgrind-light = (valgrind.override { gdb = null; }).overrideAttrs (oldAttrs: {
    meta = oldAttrs.meta // {
      description = "${oldAttrs.meta.description} (without GDB)";
    };
  });

  valhalla = callPackage ../development/libraries/valhalla {
    boost = boost.override {
      enablePython = true;
      python = python3;
    };

    protobuf = protobuf_21.override {
      abseil-cpp = abseil-cpp_202103.override {
        cxxStandard = "17";
      };
    };
  };

  validatePkgConfig = makeSetupHook {
    propagatedBuildInputs = [
      findutils
      pkg-config
    ];

    name = "validate-pkg-config";
    meta.license = lib.licenses.mit;
  } ../build-support/setup-hooks/validate-pkg-config.sh;

  vanillara = vanillatd.override { appName = "vanillara"; };
  vapoursynth-editor = libsForQt5.callPackage ../by-name/va/vapoursynth/editor.nix { };
  varnish = varnishPackages.varnish;
  varnishPackages = varnish80Packages;
  vaultenv = haskell.lib.justStaticExecutables haskellPackages.vaultenv;
  vaultwarden-mysql = vaultwarden.override { dbBackend = "mysql"; };
  vaultwarden-postgresql = vaultwarden.override { dbBackend = "postgresql"; };
  vaultwarden-sqlite = vaultwarden;
  vaultwarden-webvault = vaultwarden.webvault;
  vc4-newlib = callPackage ../development/misc/vc4/newlib.nix { };
  vcard = python3Packages.toPythonApplication python3Packages.vcard;
  vcpkg-tool-unwrapped = vcpkg-tool.override { doWrap = false; };
  vdr = callPackage ../applications/video/vdr { };
  vdrPlugins = recurseIntoAttrs (callPackage ../applications/video/vdr/plugins.nix { });
  # To ensure vdrift's code is built on hydra
  vdrift-bin = vdrift.bin;
  vencord-web-extension = callPackage ../by-name/ve/vencord/package.nix { buildWebExtension = true; };

  ventoy-full = ventoy.override {
    withCryptsetup = true;
    withExt4 = true;
    withNtfs = true;
    withXfs = true;
  };

  ventoy-full-gtk = ventoy-full.override {
    defaultGuiType = "gtk3";
  };

  ventoy-full-qt = ventoy-full.override {
    defaultGuiType = "qt5";
  };

  vertcoind = vertcoin.override {
    withGui = false;
  };

  vessel = pkgsi686Linux.callPackage ../games/vessel { };

  vid-stab = callPackage ../development/libraries/vid-stab {
    inherit (llvmPackages) openmp;
  };

  ### APPLICATIONS/FILE-MANAGERS
  vifm-full = vifm.override {
    inherit lib udisks python3;
    mediaSupport = true;
  };

  vigra = callPackage ../development/libraries/vigra {
    hdf5 = hdf5.override { apiVersion = "v110"; };
  };

  vim = vimUtils.makeCustomizable (
    callPackage ../applications/editors/vim {
    }
  );

  vim-darwin =
    (vim-full.override {
      config = {
        vim = {
          darwin = true;
          gui = "none";
        };
      };
    }).overrideAttrs
      (old: {
        pname = "vim-darwin";

        meta = {
          inherit (old.meta)
            description
            homepage
            license
            mainProgram
            outputsToInstall
            ;

          platforms = lib.platforms.darwin;
        };
      });

  vim-full = vimUtils.makeCustomizable (callPackage ../applications/editors/vim/full.nix { });
  vimPlugins = recurseIntoAttrs (callPackage ../applications/editors/vim/plugins { });

  vimPluginsUpdater = callPackage ../applications/editors/vim/plugins/utils/updater.nix {
    inherit (python3Packages) buildPythonApplication;
  };

  vimUtils = callPackage ../applications/editors/vim/plugins/utils/vim-utils.nix { };
  vimb = wrapFirefox vimb-unwrapped { };
  vimpager = callPackage ../tools/misc/vimpager { };
  vimpager-latest = callPackage ../tools/misc/vimpager/latest.nix { };
  vinyl-cache = vinyl-cache_9;

  virt-top = callPackage ../applications/virtualization/virt-top {
    ocamlPackages = ocaml-ng.ocamlPackages_4_14;
  };

  virtualbox = libsForQt5.callPackage ../applications/virtualization/virtualbox {
    # VirtualBox uses wsimport, which was removed after JDK 8.
    jdk = jdk8;
    # Opt out of building the guest BIOS sources with the problematic Open Watcom
    # toolchain. People who need to build the BIOS from sources (for example to
    # apply patches) can override this.
    open-watcom-bin = null;
    stdenv = stdenv_32bit;
  };

  virtualboxExtpack = callPackage ../applications/virtualization/virtualbox/extpack.nix { };

  virtualboxHardened = lowPrio (
    virtualbox.override {
      enableHardening = true;
    }
  );

  virtualboxHeadless = lowPrio (
    virtualbox.override {
      enableHardening = true;
      headless = true;
    }
  );

  virtualboxKvm = lowPrio (
    virtualbox.override {
      enableKvm = true;
    }
  );

  virtualboxWithExtpack = lowPrio (
    virtualbox.override {
      extensionPack = virtualboxExtpack;
    }
  );

  virtualenv = with python3Packages; toPythonApplication virtualenv;
  virtualenv-clone = with python3Packages; toPythonApplication virtualenv-clone;

  vivisect =
    with python3Packages;
    toPythonApplication (
      vivisect.override {
        # https://github.com/vivisect/vivisect/issues/683
        # gui currently requires qt5 webengine, which has been removed
        # withGui = true;
      }
    );

  vlc-bin-universal = vlc-bin.override { variant = "universal"; };
  vmTools = callPackage ../build-support/vm { };
  vncdo = with python3Packages; toPythonApplication vncdo;
  voxtype-onnx = callPackage ../by-name/vo/voxtype/package.nix { onnxSupport = true; };
  voxtype-vulkan = callPackage ../by-name/vo/voxtype/package.nix { vulkanSupport = true; };
  vprof = with python3Packages; toPythonApplication vprof;
  vscode = callPackage ../applications/editors/vscode/vscode.nix { };

  vscode-extension-update-script =
    callPackage ../by-name/vs/vscode-extension-update/vscode-extension-update-script.nix
      { };

  vscode-extensions = recurseIntoAttrs (callPackage ../applications/editors/vscode/extensions { });
  vscode-fhs = vscode.fhs;
  vscode-fhsWithPackages = vscode.fhsWithPackages;
  vscode-utils = callPackage ../applications/editors/vscode/extensions/vscode-utils.nix { };
  vscode-with-extensions = callPackage ../applications/editors/vscode/with-extensions.nix { };
  vscodium = callPackage ../applications/editors/vscode/vscodium.nix { };
  vscodium-fhs = vscodium.fhs;
  vscodium-fhsWithPackages = vscodium.fhsWithPackages;

  vte-gtk4 = vte.override {
    gtkVersion = "4";
  };

  vtk = vtk_9_5;

  vtk-full = vtk.override {
    mpiSupport = true;
    pythonSupport = true;
    withQt6 = true;
  };

  vtkWithQt6 = vtk.override { withQt6 = true; };
  vyper = with python3Packages; toPythonApplication vyper;

  # Version for batch text processing, not a good browser
  w3m-batch = w3m.override {
    graphicsSupport = false;
    imlib2 = imlib2-nox;
    mouseSupport = false;
    x11Support = false;
  };

  # Should always be the version with the most features
  w3m-full = w3m;

  # Version without X11 or graphics
  w3m-nographics = w3m.override {
    graphicsSupport = false;
    x11Support = false;
  };

  # Version without X11
  w3m-nox = w3m.override {
    imlib2 = imlib2-nox;
    x11Support = false;
  };

  # An alias to work around the splicing incidents
  # Related:
  # https://github.com/NixOS/nixpkgs/issues/204303
  # https://github.com/NixOS/nixpkgs/issues/211340
  # https://github.com/NixOS/nixpkgs/issues/227327
  wafHook = waf.hook;
  wasm = ocamlPackages.wasm;
  watcherclient = with python313Packages; toPythonApplication python-watcherclient;
  watson-ruby = callPackage ../development/tools/misc/watson-ruby { };
  waydroid-nftables = waydroid.override { withNftables = true; };
  wayfire = callPackage ../applications/window-managers/wayfire/default.nix { };

  wayfire-with-plugins = callPackage ../applications/window-managers/wayfire/wrapper.nix {
    plugins = with wayfirePlugins; [
      wcm
      wf-shell
    ];
  };

  wayfirePlugins = recurseIntoAttrs (
    callPackage ../applications/window-managers/wayfire/plugins.nix { }
  );

  wayland = callPackage ../development/libraries/wayland { };
  wayland-protocols = callPackage ../development/libraries/wayland/protocols.nix { };
  wayland-scanner = callPackage ../development/libraries/wayland/scanner.nix { };

  waylandpp = callPackage ../development/libraries/waylandpp {
    graphviz = graphviz-nox;
  };

  webkitgtk_4_1 = webkitgtk_6_0.override {
    gtk4 = gtk3;
  };

  webkitgtk_6_0 = callPackage ../development/libraries/webkitgtk {
    inherit (gst_all_1) gst-plugins-base gst-plugins-bad;
    harfbuzz = harfbuzzFull;
  };

  webos = recurseIntoAttrs {
    cmake-modules = callPackage ../development/mobile/webos/cmake-modules.nix { };
    novacom = callPackage ../development/mobile/webos/novacom.nix { };
    novacomd = callPackage ../development/mobile/webos/novacomd.nix { };
  };

  webssh = with python3Packages; toPythonApplication webssh;
  weechat = wrapWeechat weechat-unwrapped { };

  weechat-unwrapped = callPackage ../applications/networking/irc/weechat {
    inherit (darwin) libresolv;
    guile = guile_3_0;
  };

  weechatScripts = recurseIntoAttrs (callPackage ../applications/networking/irc/weechat/scripts { });
  wesnoth-devel = callPackage ../by-name/we/wesnoth/package.nix { enableDevel = true; };

  westonLite = weston.override {
    demoSupport = false;
    jpegSupport = false;
    lcmsSupport = false;
    luaSupport = false;
    pangoSupport = false;
    pipewireSupport = false;
    rdpSupport = false;
    remotingSupport = false;
    vaapiSupport = false;
    vncSupport = false;
    vulkanSupport = false;
    webpSupport = false;
    xwaylandSupport = false;
  };

  wf-config = callPackage ../applications/window-managers/wayfire/wf-config.nix { };
  wfuzz = with python3Packages; toPythonApplication wfuzz;

  whisper-cpp-vulkan = whisper-cpp.override {
    vulkanSupport = true;
  };

  whispers = with python3Packages; toPythonApplication whispers;
  why3 = callPackage ../applications/science/logic/why3 { coqPackages = coqPackages_8_20; };
  wibo = pkgsi686Linux.callPackage ../applications/emulators/wibo { };

  wild =
    let
      ldWrapper = ../build-support/bintools-wrapper/ld-wrapper.sh;
    in
    wrapBintoolsWith {
      bintools = wild-unwrapped;

      extraBuildCommands = ''
        wrap wild ${ldWrapper} ${lib.getExe buildPackages.wild-unwrapped}
        wrap ld.wild ${ldWrapper} ${lib.getExe buildPackages.wild-unwrapped}
        wrap ${stdenv.cc.bintools.targetPrefix}ld.wild ${ldWrapper} ${lib.getExe buildPackages.wild-unwrapped}
        wrap ${stdenv.cc.bintools.targetPrefix}ld ${ldWrapper} ${lib.getExe buildPackages.wild-unwrapped}
      '';
    };

  winbox = winbox4;
  windows = recurseIntoAttrs (callPackages ../os-specific/windows { });
  wine = winePackages.full;
  wine-staging = lowPrio winePackages.stagingFull;
  wine-wayland = lowPrio winePackages.waylandFull;
  wine64 = wine64Packages.full;
  wine64Packages = recurseIntoAttrs (winePackagesFor "wine64");
  winePackages = recurseIntoAttrs (winePackagesFor (config.wine.build or "wine32"));
  winePackagesFor = wineBuild: callPackage ./wine-packages.nix { inherit wineBuild; };
  wineWow64Packages = recurseIntoAttrs (winePackagesFor "wineWow64");
  winetricks = callPackage ../applications/emulators/wine/winetricks.nix { };
  wireshark-cli = wireshark.override { withQt = false; };
  wlr-protocols = callPackage ../development/libraries/wlroots/protocols.nix { };
  wofi-pass = callPackage ../../pkgs/tools/security/pass/wofi-pass.nix { };
  wolfram-for-jupyter-kernel = callPackage ../applications/editors/jupyter-kernels/wolfram { };
  woodpecker-agent = callPackage ../development/tools/continuous-integration/woodpecker/agent.nix { };
  woodpecker-cli = callPackage ../development/tools/continuous-integration/woodpecker/cli.nix { };

  woodpecker-server =
    callPackage ../development/tools/continuous-integration/woodpecker/server.nix
      { };

  wordpressPackages = recurseIntoAttrs (
    callPackage ../servers/web-apps/wordpress/packages {
      languages = lib.importJSON ../servers/web-apps/wordpress/packages/languages.json;
      plugins = lib.importJSON ../servers/web-apps/wordpress/packages/plugins.json;
      themes = lib.importJSON ../servers/web-apps/wordpress/packages/themes.json;
    }
  );

  wrapBintoolsWith =
    {
      bintools,
      libc ? targetPackages.libc or pkgs.libc,
      ...
    }@extraArgs:
    callPackage ../build-support/bintools-wrapper (
      let
        self = {
          inherit bintools libc;
          nativeLibc = stdenv.targetPlatform == stdenv.hostPlatform && stdenv.cc.nativeLibc or false;
          nativePrefix = stdenv.cc.nativePrefix or "";
          nativeTools = stdenv.targetPlatform == stdenv.hostPlatform && stdenv.cc.nativeTools or false;
          noLibc = (self.libc == null);
        }
        // extraArgs;
      in
      self
    );

  wrapCC =
    cc:
    wrapCCWith {
      inherit cc;
    };

  wrapCCMulti =
    cc:
    let
      # Binutils with glibc multi
      bintools = cc.bintools.override {
        libc = glibc_multi;
      };
    in
    lowPrio (wrapCCWith {
      inherit bintools;

      cc = cc.cc.override {
        enableMultilib = true;
        profiledCompiler = false;

        stdenv = overrideCC stdenv (wrapCCWith {
          inherit bintools;
          cc = cc.cc;
          libc = glibc_multi;
        });
      };

      extraBuildCommands = ''
        echo "dontMoveLib64=1" >> $out/nix-support/setup-hook
      '';

      libc = glibc_multi;
    });

  wrapCCWith =
    {
      cc,
      # This should be the only bintools runtime dep with this sort of logic. The
      # Others should instead delegate to the next stage's choice with
      # `targetPackages.stdenv.cc.bintools`. This one is different just to
      # provide the default choice, avoiding infinite recursion.
      # See the bintools attribute for the logic and reasoning. We need to provide
      # a default here, since eval will hit this function when bootstrapping
      # stdenv where the bintools attribute doesn't exist, but will never actually
      # be evaluated -- callPackage ends up being too eager.
      bintools ? pkgs.bintools,
      extraPackages ? lib.optional (
        cc.isGNU or false && stdenv.targetPlatform.isMinGW
      ) targetPackages.threads.package,
      libc ? bintools.libc,
      # libc++ from the default LLVM version is bound at the top level, but we
      # want the C++ library to be explicitly chosen by the caller, and null by
      # default.
      libcxx ? null,
      nixSupport ? { },
      ...
    }@extraArgs:
    callPackage ../build-support/cc-wrapper (
      let
        self = {
          inherit
            cc
            bintools
            libc
            libcxx
            extraPackages
            nixSupport
            ;

          isArocc = cc.isArocc or false;
          isClang = cc.isClang or false;
          isGNU = cc.isGNU or false;
          isZig = cc.isZig or false;
          nativeLibc = stdenv.targetPlatform == stdenv.hostPlatform && stdenv.cc.nativeLibc or false;
          nativePrefix = stdenv.cc.nativePrefix or "";
          nativeTools = stdenv.targetPlatform == stdenv.hostPlatform && stdenv.cc.nativeTools or false;
          noLibc = !self.nativeLibc && (self.libc == null);
        }
        // extraArgs;
      in
      self
    );

  wrapClangMulti =
    clang:
    callPackage ../development/compilers/llvm/multi.nix {
      inherit clang;
      gcc32 = pkgsi686Linux.gcc;
      gcc64 = pkgs.gcc;
    };

  wrapFirefox = callPackage ../applications/networking/browsers/firefox/wrapper.nix { };
  wrapFish = callPackage ../shells/fish/wrapper.nix { };

  wrapGAppsHook3 = wrapGAppsNoGuiHook.override {
    isGraphical = true;
  };

  wrapGAppsHook4 = wrapGAppsNoGuiHook.override {
    gtk3 = __splicedPackages.gtk4;
    isGraphical = true;
  };

  wrapGAppsNoGuiHook = callPackage ../build-support/setup-hooks/wrap-gapps-hook {
    makeWrapper = makeBinaryWrapper;
  };

  wrapHelm = callPackage ../applications/networking/cluster/helm/wrapper.nix { };

  wrapKakoune =
    kakoune: attrs:
    callPackage ../applications/editors/kakoune/wrapper.nix (attrs // { inherit kakoune; });

  wrapLisp = callPackage ../development/lisp-modules/nix-cl.nix { };
  wrapLispi686Linux = pkgsi686Linux.callPackage ../development/lisp-modules/nix-cl.nix { };
  wrapNeovim = neovim-unwrapped: lib.makeOverridable (neovimUtils.legacyWrapper neovim-unwrapped);
  # this is a lower-level alternative to wrapNeovim conceived to handle
  # more usecases when wrapping neovim. The interface is being actively worked on
  # so expect breakage. use wrapNeovim instead if you want a stable alternative
  wrapNeovimUnstable = callPackage ../applications/editors/neovim/wrapper.nix { };

  wrapNonDeterministicGcc =
    stdenv: ccWrapper:
    if ccWrapper.isGNU then
      ccWrapper.override (prev: {
        cc = prev.cc.override {
          profiledCompiler = with stdenv; (!isDarwin && hostPlatform.isx86);
          reproducibleBuild = false;
        };
      })
    else
      ccWrapper;

  wrapOBS = callPackage ../applications/video/obs-studio/wrapper.nix { };
  wrapQemuBinfmtP = callPackage ../by-name/qe/qemu/binfmt-p-wrapper.nix { };
  wrapRetroArch = retroarch-bare.wrapper;
  wrapRustc = rustc-unwrapped: wrapRustcWith { inherit rustc-unwrapped; };
  wrapRustcWith = { rustc-unwrapped, ... }@args: callPackage ../build-support/rust/rustc-wrapper args;
  wrapThunderbird = callPackage ../applications/networking/mailreaders/thunderbird/wrapper.nix { };
  wrapVdr = callPackage ../applications/video/vdr/wrapper.nix { };
  wrapWatcom = callPackage ../development/compilers/open-watcom/wrapper.nix { };
  wrapWeechat = callPackage ../applications/networking/irc/weechat/wrapper.nix { };

  writableTmpDirAsHomeHook = callPackage (
    { makeSetupHook }:
    makeSetupHook {
      name = "writable-tmpdir-as-home-hook";
      meta.license = lib.licenses.mit;
    } ../build-support/setup-hooks/writable-tmpdir-as-home.sh
  ) { };

  writeDarwinBundle = callPackage ../build-support/make-darwin-bundle/write-darwin-bundle.nix { };
  #package writers
  writers = callPackage ../build-support/writers { };
  wt = wt4;

  wyrd = callPackage ../tools/misc/wyrd {
    ocamlPackages = ocaml-ng.ocamlPackages_4_14;
  };

  # Aliases kept here because they are easier to use
  x16-emulator = x16.emulator;
  x16-rom = x16.rom;
  x16-run = x16.run;
  x32edit = callPackage ../applications/audio/midas/x32edit.nix { };
  xapian = xapian_1_4;

  xapian-omega = callPackage ../development/libraries/xapian/tools/omega {
    libmagic = file;
  };

  # A minimal xar is needed to break an infinite recursion between macfuse-stubs and xar.
  # It is also needed to reduce the amount of unnecessary stuff in the Darwin bootstrap.
  xarMinimal = callPackage ../by-name/xa/xar/package.nix { e2fsprogs = null; };
  xash-dedicated = callPackage ../by-name/xa/xash3d-fwgs/package.nix { buildServer = true; };
  xcbproto = xcb-proto;

  xcbuildHook = makeSetupHook {
    propagatedBuildInputs = [ xcbuild ];
    name = "xcbuild-hook";
    meta.license = lib.licenses.mit;
  } ../by-name/xc/xcbuild/setup-hook.sh;

  xcodebuild = xcbuild;
  xcodeenv = callPackage ../development/mobile/xcodeenv { };

  xdg-desktop-portal-hyprland =
    callPackage ../applications/window-managers/hyprwm/xdg-desktop-portal-hyprland
      {
        inherit (qt6)
          qtbase
          qttools
          qtwayland
          wrapQtAppsHook
          ;

        stdenv = gcc15Stdenv;
      };

  xdot = with python3Packages; toPythonApplication xdot;
  xfce = recurseIntoAttrs (callPackage ../desktops/xfce { });
  xgboostWithCuda = xgboost.override { cudaSupport = true; };
  xkcdpass = with python3Packages; toPythonApplication xkcdpass;
  xkeyboard-config_custom = callPackage ../by-name/xk/xkeyboard-config/custom.nix { };
  xkeyboard_config = xkeyboard-config;
  xlsx2csv = with python3Packages; toPythonApplication xlsx2csv;
  xml2rfc = with python3Packages; toPythonApplication xml2rfc;
  xmlsort = perlPackages.XMLFilterSort;
  xmobar = haskellPackages.xmobar.bin;

  xmonad-with-packages = callPackage ../applications/window-managers/xmonad/wrapper.nix {
    inherit (haskellPackages) ghcWithPackages;
    packages = _: [ haskellPackages.xmonad-contrib ];
  };

  xmonad_log_applet_mate = xmonad_log_applet.override {
    desktopSupport = "mate";
  };

  xmonad_log_applet_xfce = xmonad_log_applet.override {
    desktopSupport = "xfce4";
  };

  xmonadctl = callPackage ../applications/window-managers/xmonad/xmonadctl.nix {
    inherit (haskellPackages) ghcWithPackages;
  };

  xonotic-dedicated =
    (callPackage ../games/xonotic {
      withDedicated = true;
      withSDL = false;
    }).xonotic;

  xonotic-dedicated-unwrapped = xonotic-dedicated.xonotic-unwrapped;

  xonotic-glx =
    (callPackage ../games/xonotic {
      withGLX = true;
      withSDL = false;
    }).xonotic;

  xonotic-glx-unwrapped = xonotic-glx.xonotic-unwrapped;
  xonotic-sdl = xonotic;
  xonotic-sdl-unwrapped = xonotic-sdl.xonotic-unwrapped;
  xorriso = libisoburn;
  xpdf = libsForQt5.callPackage ../applications/misc/xpdf { };

  xvfb-run = callPackage ../tools/misc/xvfb-run {
    inherit (texFunctions) fontsConf;
  };

  xxdiff-tip = xxdiff;

  xyce-parallel = callPackage ../by-name/xy/xyce/package.nix {
    trilinos = trilinos-mpi;
    withMPI = true;
  };

  xz = callPackage ../tools/compression/xz { };
  yamale = with python3Packages; toPythonApplication yamale;
  yamllint = with python3Packages; toPythonApplication yamllint;
  yapf = with python3Packages; toPythonApplication yapf;
  yarn-berry_3 = yarn-berry.override { berryVersion = 3; };

  yarn-berry_3-fetcher = callPackage ../by-name/ya/yarn-berry/fetcher {
    yarn-berry = yarn-berry_3;
  };

  yarn-berry_4 = yarn-berry.override { berryVersion = 4; };

  yarn-berry_4-fetcher = callPackage ../by-name/ya/yarn-berry/fetcher {
    yarn-berry = yarn-berry_4;
  };

  yaziPlugins = recurseIntoAttrs (callPackage ../by-name/ya/yazi/plugins { });
  ydiff = with python3.pkgs; toPythonApplication ydiff;
  # To expose more packages for Yi, override the extraPackages arg.
  yi = callPackage ../applications/editors/yi/wrapper.nix { };

  yoda-with-root = lowPrio (
    yoda.override {
      withRootSupport = true;
    }
  );

  # prolog
  yosys-bluespec = callPackage ../development/compilers/yosys/plugins/bluespec.nix { };
  yosys-ghdl = callPackage ../development/compilers/yosys/plugins/ghdl.nix { };
  yosys-symbiflow = callPackage ../development/compilers/yosys/plugins/symbiflow.nix { };
  your-editor = callPackage ../applications/editors/your-editor { stdenv = gccStdenv; };
  youtube-dl = with python3Packages; toPythonApplication youtube-dl;
  youtube-dl-light = with python3Packages; toPythonApplication youtube-dl-light;
  youtube-viewer = perlPackages.WWWYoutubeViewer;
  yq = python3.pkgs.toPythonApplication python3.pkgs.yq;

  yt-dlp-light = yt-dlp.override {
    atomicparsleySupport = false;
    ffmpegSupport = false;
    javascriptSupport = false;
    rtmpSupport = false;
  };

  zabbix = zabbix60;
  zabbix60 = recurseIntoAttrs (zabbixFor "v60");
  zabbix70 = recurseIntoAttrs (zabbixFor "v70");
  zabbix74 = recurseIntoAttrs (zabbixFor "v74");

  zabbixFor = version: rec {
    agent = (callPackages ../servers/monitoring/zabbix/agent.nix { }).${version};
    agent2 = (callPackages ../servers/monitoring/zabbix/agent2.nix { }).${version};

    proxy-mysql =
      (callPackages ../servers/monitoring/zabbix/proxy.nix { mysqlSupport = true; }).${version};

    proxy-pgsql =
      (callPackages ../servers/monitoring/zabbix/proxy.nix { postgresqlSupport = true; }).${version};

    proxy-sqlite =
      (callPackages ../servers/monitoring/zabbix/proxy.nix { sqliteSupport = true; }).${version};

    # backwards compatibility
    server = server-pgsql;

    server-mysql =
      (callPackages ../servers/monitoring/zabbix/server.nix { mysqlSupport = true; }).${version};

    server-pgsql =
      (callPackages ../servers/monitoring/zabbix/server.nix { postgresqlSupport = true; }).${version};

    web = (callPackages ../servers/monitoring/zabbix/web.nix { }).${version};
  };

  zathura = zathuraPkgs.zathuraWrapper;
  zathuraPkgs = recurseIntoAttrs (callPackage ../applications/misc/zathura { });
  zed-editor-fhs = zed-editor.fhs;
  zef = callPackage ../development/interpreters/rakudo/zef.nix { };
  zellijPlugins = recurseIntoAttrs (callPackage ../by-name/ze/zellij/plugins { });

  # Nvidia support does not require any proprietary libraries, so CI can build it.
  # Note that when enabling this unconditionally, non-nvidia users will always have an empty "GPU" section.
  zenith-nvidia = zenith.override {
    nvidiaSupport = true;
  };

  zeroc-ice-cpp11 = zeroc-ice.override { cpp11 = true; };
  zfs = zfs_2_4;
  # If this is updated, the default zls version should also be updated to match the default zig version.
  zig = zig_0_16;
  zigStdenv = if stdenv.cc.isZig then stdenv else lowPrio zig.passthru.stdenv;

  zlib = callPackage ../development/libraries/zlib {
    stdenv =
      # zlib is a dependency of xcbuild. Avoid an infinite recursion by using a bootstrap stdenv
      # that does not propagate xcrun.
      if stdenv.hostPlatform.isDarwin then darwin.bootstrapStdenv else stdenv;
  };

  # This should be kept updated to ensure the default zls version matches the default zig version.
  zls = zls_0_16;
  znc = callPackage ../applications/networking/znc { };
  zncModules = recurseIntoAttrs (callPackage ../applications/networking/znc/modules.nix { });
  zonemaster-cli = perlPackages.ZonemasterCLI;

  zstd = callPackage ../tools/compression/zstd {
    cmake = buildPackages.cmakeMinimal;
  };

  zulu = zulu21;
  zunclient = with python313Packages; toPythonApplication python-zunclient;

  zynaddsubfx-fltk = zynaddsubfx.override {
    guiModule = "fltk";
  };

  zynaddsubfx-ntk = zynaddsubfx.override {
    guiModule = "ntk";
  };
}
