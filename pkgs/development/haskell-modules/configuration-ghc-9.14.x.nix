{ haskellLib, pkgs }:

self: super:

let
  inherit (pkgs) lib;

  warnAfterVersion =
    ver: pkg:
    lib.warnIf (lib.versionOlder ver
      super.${pkg.pname}.version
    ) "override for haskell.packages.ghc912.${pkg.pname} may no longer be needed" pkg;

in

with haskellLib;

{
  Cabal = null;
  Cabal-syntax = null;
  HTTP = doDistribute self.HTTP_4000_5_0;
  Win32 = null;
  aeson = doJailbreak super.aeson;
  # Disable GHC core libraries
  array = null;
  base = null;
  binary = null;
  # https://github.com/jaspervdj/blaze-html/issues/151
  blaze-html = doJailbreak super.blaze-html;
  # Too strict bound on containers in test suite
  # https://github.com/jaspervdj/blaze-markup/issues/69
  blaze-markup = doJailbreak super.blaze-markup;
  # https://github.com/phadej/boring/issues/48
  boring = doJailbreak super.boring;
  bytestring = null;
  # https://github.com/well-typed/cborg/issues/373
  cborg = doJailbreak super.cborg;
  containers = null;
  deepseq = null;
  directory = null;
  exceptions = null;
  # https://github.com/haskell-party/feed/issues/76
  feed = doJailbreak super.feed; # time<1.15, base<4.22
  file-io = null;
  filepath = null;
  ghc-bignum = null;
  ghc-boot = null;
  ghc-boot-th = null;
  ghc-compact = null;
  #
  # Version upgrades
  #
  ghc-exactprint = doDistribute self.ghc-exactprint_1_14_0_0;

  ghc-exactprint_1_14_0_0 = addBuildDepends [
    # cabal2nix drops conditional block: impl (ghc >= 9.14)
    self.Diff
    self.extra
    self.ghc-paths
    self.silently
    self.syb
    self.HUnit
  ] super.ghc-exactprint_1_14_0_0;

  ghc-experimental = null;
  ghc-heap = null;
  ghc-internal = null;
  ghc-platform = null;
  ghc-prim = null;
  ghc-toolchain = null;
  ghci = null;
  haddock-api = null;
  haddock-library = null;
  haskeline = null;
  haskell-debugger = doDistribute (doJailbreak super.haskell-debugger); # hie-bios < 0.18, random >=1.3.1
  # haskell-debugger only works with ghc 9.14+
  haskell-debugger-view = doDistribute (unmarkBroken super.haskell-debugger-view);
  hedgehog = doDistribute self.hedgehog_1_7;
  hie-bios = doDistribute (dontCheck self.hie-bios_0_19_0); # Tests access homeless-shelter.
  hpc = null;
  # https://github.com/haskellari/indexed-traversable/issues/49
  indexed-traversable = doJailbreak super.indexed-traversable;
  # https://github.com/haskellari/indexed-traversable/issues/50
  indexed-traversable-instances = doJailbreak super.indexed-traversable-instances;
  integer-gmp = null;
  lifted-async = doDistribute self.lifted-async_0_11_0;
  #
  # Test suite issues
  #
  # Fails to compile with GHC 9.14 https://github.com/snoyberg/mono-traversable/pull/261
  mono-traversable = dontCheck super.mono-traversable;
  mtl = null;
  # https://github.com/sjakobi/newtype-generics/pull/28/files
  newtype-generics = warnAfterVersion "0.6.2" (doJailbreak super.newtype-generics);
  os-string = null;
  parallel = doDistribute self.parallel_3_3_0_0;
  parsec = null;
  pretty = null;
  #
  # Jailbreaks
  #
  primitive = doJailbreak (dontCheck super.primitive); # base <4.22 and a lot of dependencies on packages not yet working.
  process = null;
  # https://github.com/haskellari/qc-instances/issues/110
  quickcheck-instances = doJailbreak super.quickcheck-instances;
  rts = null;
  #
  # Only support GHC 9.14
  #
  scrod = doDistribute (unmarkBroken super.scrod);
  semaphore-compat = null;
  # https://github.com/haskellari/these/issues/207
  semialign = doJailbreak super.semialign;

  serialise = doJailbreak (
    appendPatches [
      # This removes support for older versions of time (think GHC 8.6) and, in doing so,
      # drops a Cabal flag that prevents jailbreak from working
      (pkgs.fetchpatch {
        hash = "sha256-Gutu9c+houcwAvq2Z+ZQUQbNK+u+OCJRZfKBtx8/V4c=";
        name = "serialise-no-old-time.patch";
        relative = "serialise";
        url = "https://github.com/well-typed/cborg/commit/308afc2795062f847171463958e5e1bbd9c03381.patch";
      })
    ] super.serialise
  );

  splitmix = doJailbreak super.splitmix; # base <4.22
  stm = null;
  system-cxx-std-lib = null;
  tagged = doDistribute self.tagged_0_8_10;
  template-haskell = null;
  template-haskell-lift = null;
  template-haskell-quasiquoter = null;

  # GHC only builds terminfo if it is a native compiler
  terminfo =
    if pkgs.stdenv.hostPlatform == pkgs.stdenv.buildPlatform then
      null
    else
      haskellLib.doDistribute self.terminfo_0_4_1_7;

  text = null;
  # https://github.com/haskell/aeson/issues/1155
  text-iso8601 = doJailbreak super.text-iso8601;
  # https://github.com/haskellari/these/issues/211
  these = doJailbreak super.these;
  time = null;
  # https://github.com/haskellari/time-compat/issues/48
  time-compat = doJailbreak super.time-compat;
  transformers = null;
  unix = null;
  unordered-containers = doDistribute self.unordered-containers_0_2_21;
  # https://github.com/haskell-hvr/uuid/issues/95
  uuid-types = doJailbreak super.uuid-types;
  xhtml = null;

}
