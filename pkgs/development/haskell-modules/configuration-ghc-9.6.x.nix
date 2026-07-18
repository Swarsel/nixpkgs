{ haskellLib, pkgs }:

self: super:

with haskellLib;

let
  inherit (pkgs) lib;

  warnAfterVersion =
    ver: pkg:
    lib.warnIf (lib.versionOlder ver
      super.${pkg.pname}.version
    ) "override for haskell.packages.ghc96.${pkg.pname} may no longer be needed" pkg;

in

{
  inherit (pkgs.lib.mapAttrs (_: doJailbreak) super)
    ghc-trace-events
    gi-cairo-connector # mtl <2.3
    ghc-prof # base <4.18
    env-guard # doctest <0.21
    package-version # doctest <0.21, tasty-hedgehog <1.4
    ;

  # This runs into the following GHC bug currently affecting 9.6.* and 9.8.* as
  # well as 9.10.1: https://gitlab.haskell.org/ghc/ghc/-/issues/24432
  inherit
    (lib.mapAttrs (
      _:
      overrideCabal (drv: {
        badPlatforms = drv.badPlatforms or [ ] ++ [ "aarch64-linux" ];
      })
    ) super)
    mueval
    lambdabot
    lambdabot-haskell-plugins
    ;

  inherit
    (
      let
        hls_overlay = lself: lsuper: {
          Cabal = lself.Cabal_3_10_3_0;
          Cabal-syntax = lself.Cabal-syntax_3_10_3_0;
          extensions = dontCheck (doJailbreak lself.extensions_0_1_0_1);
        };
      in
      lib.mapAttrs (_: pkg: doDistribute (pkg.overrideScope hls_overlay)) {
        apply-refact = addBuildDepend self.data-default-class super.apply-refact;
        floskell = doJailbreak super.floskell;
        fourmolu = dontCheck (doJailbreak self.fourmolu_0_15_0_0);
        ghcide = super.ghcide;

        haskell-language-server = addBuildDepends [
          self.retrie
          self.floskell
          self.markdown-unlit
        ] super.haskell-language-server;

        hlint = self.hlint_3_8;
        hls-plugin-api = super.hls-plugin-api;
        lsp-types = super.lsp-types;
        ormolu = self.ormolu_0_7_4_0;
        retrie = doJailbreak (unmarkBroken super.retrie);
        stylish-haskell = self.stylish-haskell_0_14_6_0;
      }
    )
    apply-refact
    floskell
    fourmolu
    ghcide
    haskell-language-server
    hls-plugin-api
    hlint
    lsp-types
    ormolu
    retrie
    stylish-haskell
    ;

  Cabal = null;
  Cabal-syntax = null;
  # Forbids mtl >= 2.3
  ChasingBottoms = doJailbreak super.ChasingBottoms;

  # Apply patch from PR with mtl-2.3 fix.
  ConfigFile = overrideCabal (drv: {
    patches = [
      (pkgs.fetchpatch {
        # https://github.com/jgoerzen/configfile/pull/12
        name = "ConfigFile-pr-12.patch";
        sha256 = "sha256-b7u9GiIAd2xpOrM0MfILHNb6Nt7070lNRIadn2l3DfQ=";
        url = "https://github.com/jgoerzen/configfile/compare/d0a2e654be0b73eadbf2a50661d00574ad7b6f87...83ee30b43f74d2b6781269072cf5ed0f0e00012f.patch";
      })
    ];

    buildDepends = drv.buildDepends or [ ] ++ [ self.HUnit ];
    editedCabalFile = null;
  }) super.ConfigFile;

  Win32 = null;
  # Tests require nothunks < 0.3 (conflicting with Stackage) for GHC < 9.8
  aeson = dontCheck super.aeson;
  # Disable GHC core libraries
  array = null;

  # This can be removed once https://github.com/typeclasses/ascii-numbers/pull/1
  # is merged and in a release that's being tracked.
  ascii-numbers = appendPatch (pkgs.fetchpatch {
    name = "ascii-numbers-pull-1.patch";
    relative = "ascii-numbers";
    sha256 = "sha256-buw1UeW57CFefEfqdDUraSyQ+H/NvCZOv6WF2ORiYQg=";
    url = "https://github.com/typeclasses/ascii-numbers/commit/e9474ad91bc997891f1a46afd5d0bdf9b9f7d768.patch";
  }) super.ascii-numbers;

  # This can be removed once https://github.com/typeclasses/ascii-predicates/pull/1
  # is merged and in a release that's being tracked.
  ascii-predicates = appendPatch (pkgs.fetchpatch {
    name = "ascii-predicates-pull-1.patch";
    relative = "ascii-predicates";
    sha256 = "sha256-4JguQFZNRQpjZThLrAo13jNeypvLfqFp6o7c1bnkmZo=";
    url = "https://github.com/typeclasses/ascii-predicates/commit/2e6d9ed45987a8566f3a77eedf7836055c076d1a.patch";
  }) super.ascii-predicates;

  base = null;
  binary = null;
  # https://github.com/Gabriella439/Haskell-Break-Library/pull/3
  break = doJailbreak super.break;
  bytestring = null;
  cabal-install = doJailbreak super.cabal-install;
  # Forbids base >= 4.18
  cabal-install-solver = doJailbreak super.cabal-install-solver;
  containers = null;
  deepseq = null;
  directory = null;
  exceptions = null;
  filepath = null;
  ghc-bignum = null;
  ghc-boot = null;
  ghc-boot-th = null;
  ghc-compact = null;
  # A given major version of ghc-exactprint only supports one version of GHC.
  ghc-exactprint = addBuildDepend self.extra super.ghc-exactprint_1_7_1_0;
  # Become core packages in GHC >= 9.10, no release compatible with GHC < 9.10 is available
  ghc-experimental = null;
  ghc-heap = null;
  ghc-internal = null;
  ghc-lib = doDistribute self.ghc-lib_9_8_5_20250214;
  ghc-lib-parser = doDistribute self.ghc-lib-parser_9_8_5_20250214;
  ghc-lib-parser-ex = doDistribute self.ghc-lib-parser-ex_9_8_0_2;
  ghc-platform = null;
  ghc-prim = null;
  # not in Stackage, needs to match ghc-lib
  # since expression is generated for 9.8, ghc-lib dep needs to be added manually
  ghc-tags = doDistribute (addBuildDepends [ self.ghc-lib ] self.ghc-tags_1_8);
  # Become core packages in GHC >= 9.10, but aren't uploaded to Hackage
  ghc-toolchain = null;
  ghci = null;
  # Pending text-2.0 support https://github.com/gtk2hs/gtk2hs/issues/327
  gtk = doJailbreak super.gtk;
  haddock-library = doJailbreak super.haddock-library;
  haskeline = null;
  hiedb = dontCheck super.hiedb;
  # 2023-12-23: It needs this to build under ghc-9.6.3.
  #   A factor of 100 is insufficient, 200 seems seems to work.
  hip = appendConfigureFlag "--ghc-options=-fsimpl-tick-factor=200" super.hip;
  hpc = null;
  integer-gmp = null;
  iserv-proxy = addBuildDepend self.libiserv super.iserv-proxy;

  # Compatibility with core libs of GHC 9.6
  # Jailbreak to lift bound on time
  kqueue = doJailbreak (
    appendPatches [
      (pkgs.fetchpatch {
        excludes = [ ".gitignore" ];
        name = "kqueue-ghc-9.6.patch";
        sha256 = "18rilz4nrwcmlvll3acjx2lp7s129pviggb8fy3hdb0z34ls5j84";
        url = "https://github.com/hesselink/kqueue/pull/10/commits/a2735e807d761410e776482ec04515d9cf76a7f5.patch";
      })
    ] super.kqueue
  );

  libiserv = doJailbreak (markUnbroken (doDistribute super.libiserv)); # ghci ==9.6.6
  # https://github.com/NixOS/nixpkgs/pull/367998#issuecomment-2598941240
  libtorch-ffi-helper = unmarkBroken (doDistribute super.libtorch-ffi-helper);
  mtl = null;
  # Forbids base >= 4.18, fix proposed: https://github.com/sjakobi/newtype-generics/pull/25
  newtype-generics = warnAfterVersion "0.6.2" (doJailbreak super.newtype-generics);
  # Becomes a core package in GHC >= 9.10
  os-string = doDistribute self.os-string_2_0_10;
  parsec = null;
  pretty = null;
  process = null;
  #
  # Too strict bounds without upstream fix
  #
  # Forbids transformers >= 0.6
  quickcheck-classes-base = doJailbreak super.quickcheck-classes-base;
  regex-tdfa = dontCheck super.regex-tdfa;
  # https://github.com/kowainik/relude/issues/436
  relude = dontCheck (doJailbreak super.relude);
  rts = null;
  # Becomes a core package in GHC >= 9.8
  semaphore-compat = doDistribute self.semaphore-compat_1_0_0;
  # Jailbreaks for servant <0.20
  servant-lucid = doJailbreak super.servant-lucid;
  singletons-base = dontCheck super.singletons-base;
  # Needs base-orphans for GHC < 9.8 / base < 4.19
  some = addBuildDepend self.base-orphans super.some;
  stm = null;
  stm-containers = dontCheck super.stm-containers;
  system-cxx-std-lib = null;
  template-haskell = null;

  # terminfo is not built if GHC is a cross compiler
  terminfo =
    if pkgs.stdenv.hostPlatform == pkgs.stdenv.buildPlatform then
      null
    else
      doDistribute self.terminfo_0_4_1_7;

  text = null;
  #
  # Version deviations from Stackage LTS
  #
  # Too strict upper bound on template-haskell
  # https://github.com/mokus0/th-extras/pull/21
  th-extras = doJailbreak super.th-extras;
  time = null;
  # Tests require skeletest which no longer supports GHC 9.6
  toml-reader = dontCheck super.toml-reader;
  transformers = null;
  unix = null;
  xhtml = null;
}
