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
  Win32 = null;

  # Cabal 3.14 regression (incorrect datadir in tests): https://github.com/haskell/cabal/issues/10717
  alex = overrideCabal (drv: {
    preCheck = drv.preCheck or "" + ''
      export alex_datadir="$(pwd)/data"
    '';
  }) super.alex;

  # Disable GHC core libraries
  array = null;
  base = null;
  binary = null;
  bytestring = null;
  cabal-install-parsers = doJailbreak super.cabal-install-parsers; # base, Cabal-syntax, etc.
  cabal-plan = doJailbreak super.cabal-plan; # base <4.21
  containers = null;

  cpphs = overrideCabal (drv: {
    # jail break manually the conditional dependencies
    postPatch = ''
      sed -i 's/time >=1.5 \&\& <1.13/time >=1.5 \&\& <=1.14/g' cpphs.cabal
    '';
  }) super.cpphs;

  dbus = doJailbreak super.dbus; # template-haskell <2.23
  decimal-literals = doJailbreak super.decimal-literals; # base <4.21
  deepseq = null;
  directory = null;
  exceptions = null;
  #
  # Hand pick versions that are compatible with ghc 9.12 and base 4.21
  #
  extensions = doDistribute self.extensions_0_1_1_0;
  file-io = null;
  filepath = null;
  # https://gitlab.haskell.org/ghc/ghc/-/issues/25930
  generic-lens = dontCheck super.generic-lens;
  ghc-bignum = null;
  ghc-boot = null;
  ghc-boot-th = null;
  ghc-compact = null;
  ghc-exactprint = doDistribute self.ghc-exactprint_1_12_0_0;

  ghc-exactprint_1_12_0_0 = addBuildDepends [
    # cabal2nix drops conditional block: impl (ghc >= 9.12)
    self.Diff
    self.extra
    self.ghc-paths
    self.silently
    self.syb
    self.HUnit
  ] super.ghc-exactprint_1_12_0_0;

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
  hpc = null;
  integer-gmp = null;
  # Test failure because of GHC bug:
  #   https://gitlab.haskell.org/ghc/ghc/-/issues/25937
  #   https://github.com/sol/interpolate/issues/20
  interpolate = dontCheckIf (lib.versionOlder self.ghc.version "9.12.3") super.interpolate;
  #
  # Jailbreaks
  #
  large-generics = doJailbreak super.large-generics; # base <4.20
  matrix-client = doJailbreak super.matrix-client; # time <1.13
  mtl = null;
  # https://github.com/sjakobi/newtype-generics/pull/28/files
  newtype-generics = warnAfterVersion "0.6.2" (doJailbreak super.newtype-generics);
  os-string = null;
  parsec = null;
  patat = doJailbreak super.patat; # time <1.13
  pretty = null;
  process = null;
  puresat = doJailbreak super.puresat; # base <4.21
  #
  # Test suite issues
  #
  relude = dontCheck super.relude;
  rts = null;
  semaphore-compat = null;
  stm = null;
  system-cxx-std-lib = null;
  template-haskell = null;

  # GHC only builds terminfo if it is a native compiler
  terminfo =
    if pkgs.stdenv.hostPlatform == pkgs.stdenv.buildPlatform then
      null
    else
      haskellLib.doDistribute self.terminfo_0_4_1_7;

  text = null;
  time = null;
  timezone-olson = doJailbreak super.timezone-olson; # time <1.14
  timezone-series = doJailbreak super.timezone-series; # time <1.14
  transformers = null;
  unix = null;
  xhtml = null;
  xmobar = doJailbreak super.xmobar; # base <4.21
}
