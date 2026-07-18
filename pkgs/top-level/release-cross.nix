/*
  This file defines some basic smoke tests for cross compilation.
  Individual jobs can be tested by running:

  $ nix-build pkgs/top-level/release-cross.nix -A <jobname>.<package> --arg supportedSystems '[builtins.currentSystem]'

  e.g.

  $ nix-build pkgs/top-level/release-cross.nix -A crossMingw32.nix --arg supportedSystems '[builtins.currentSystem]'

  To build all of the bootstrapFiles bundles on every enabled platform, use:

  $ nix-build --expr 'with import ./pkgs/top-level/release-cross.nix {supportedSystems = [builtins.currentSystem];}; builtins.mapAttrs (k: v: v.build) bootstrapTools'
*/

{
  # Attributes passed to nixpkgs. Don't build packages marked as unfree.
  nixpkgsArgs ? {
    __allowFileset = false;

    config = {
      allowAliases = false;
      allowUnfree = false;
      inHydra = true;
    };
  },
  # Strip most of attributes when evaluating to spare memory usage
  scrubJobs ? true,
  # The platforms *from* which we cross compile.
  supportedSystems ? [
    "x86_64-linux"
    "aarch64-linux"
    "aarch64-darwin"
  ],
}:

let
  release-lib = import ./release-lib.nix {
    inherit supportedSystems scrubJobs nixpkgsArgs;
  };

  inherit (release-lib)
    all
    assertTrue
    darwin
    forMatchingSystems
    hydraJob'
    linux
    mapTestOnCross
    pkgsForCross
    ;

  inherit (release-lib.lib)
    mapAttrs
    addMetaAttrs
    elem
    getAttrFromPath
    isDerivation
    maintainers
    mapAttrsRecursive
    mapAttrsRecursiveCond
    recursiveUpdate
    systems
    ;

  inherit (release-lib.lib.attrsets)
    removeAttrs
    ;

  nativePlatforms = all;

  embedded = {
    buildPackages.binutils = nativePlatforms;
    buildPackages.gcc = nativePlatforms;
    libc = nativePlatforms;
  };

  common = {
    buildPackages.binutils = nativePlatforms;
    cargo = nativePlatforms;
    fd = nativePlatforms;
    gmp = nativePlatforms;
    libc = nativePlatforms;
    mesa = nativePlatforms;
    nix = nativePlatforms;
    nixVersions.git = nativePlatforms;
    rustc = nativePlatforms;
  };

  gnuCommon = recursiveUpdate common {
    buildPackages.gcc = nativePlatforms;
    coreutils = nativePlatforms;
    haskell.packages.ghcHEAD.hello = nativePlatforms;
    haskellPackages.hello = nativePlatforms;
  };

  linuxCommon = recursiveUpdate gnuCommon {
    bison = nativePlatforms;
    buildPackages.gdb = nativePlatforms;
    busybox = nativePlatforms;
    dropbear = nativePlatforms;
    ed = nativePlatforms;
    ncurses = nativePlatforms;
    patch = nativePlatforms;
  };

  windowsCommon = recursiveUpdate gnuCommon {
    boehmgc = nativePlatforms;
    libffi = nativePlatforms;
    libtool = nativePlatforms;
    libunistring = nativePlatforms;
    windows.pthreads = nativePlatforms;
  };

  cygwinCommon = {
    hello = nativePlatforms;
    nixVersions.git = nativePlatforms;
  };

  wasiCommon = {
    boehmgc = nativePlatforms;
    gmp = nativePlatforms;
    hello = nativePlatforms;

    tree-sitter.builtGrammars =
      mapAttrs (_: _: nativePlatforms)
        (pkgsForCross systems.examples.wasi32 (builtins.head supportedSystems)).tree-sitter.builtGrammars;

    zlib = nativePlatforms;
  };

  darwinCommon = {
    buildPackages.binutils = darwin;
  };

  rpiCommon = linuxCommon // {
    buildPackages.binutils = nativePlatforms;
    ddrescue = nativePlatforms;
    lynx = nativePlatforms;
    mpg123 = nativePlatforms;
    patchelf = nativePlatforms;
    unzip = nativePlatforms;
    vim = nativePlatforms;
  };

  # Enabled-but-unsupported platforms for which nix is known to build.
  # We provide Hydra-built `nixStatic` for these platforms.  This
  # allows users to bootstrap their own system without either (a)
  # trusting binaries from a non-Hydra source or (b) having to fight
  # with their host distribution's versions of nix's numerous
  # build dependencies.
  nixCrossStatic = {
    nixStatic = linux; # no need for buildPlatform=*-darwin
  };

in

{
  # Linux on aarch64
  aarch64 = mapTestOnCross systems.examples.aarch64-multiplatform linuxCommon;
  aarch64-embedded = mapTestOnCross systems.examples.aarch64-embedded embedded;
  aarch64-musl = mapTestOnCross systems.examples.aarch64-multiplatform-musl linuxCommon;
  aarch64be-embedded = mapTestOnCross systems.examples.aarch64be-embedded embedded;
  android32 = mapTestOnCross systems.examples.armv7a-android-prebuilt linuxCommon;
  android64 = mapTestOnCross systems.examples.aarch64-android-prebuilt linuxCommon;
  arc = mapTestOnCross systems.examples.arc linuxCommon;
  arm-embedded = mapTestOnCross systems.examples.arm-embedded embedded;
  arm-embedded-nano = mapTestOnCross systems.examples.arm-embedded-nano embedded;
  armhf-embedded = mapTestOnCross systems.examples.armhf-embedded embedded;

  # Test some cross builds to ARMv5
  armv5tel = mapTestOnCross systems.examples.armv5tel-multiplatform (
    linuxCommon
    // {
      ubootSheevaplug = nativePlatforms;
    }
  );

  # Linux on armv7l-hf
  armv7l-hf = mapTestOnCross systems.examples.armv7l-hf-multiplatform linuxCommon;
  avr = mapTestOnCross systems.examples.avr embedded;
  ben-nanonote = mapTestOnCross systems.examples.ben-nanonote linuxCommon;

  # Cross-built bootstrap tools for every supported platform
  bootstrapTools =
    let
      linuxTools = import ../stdenv/linux/make-bootstrap-tools-cross.nix { system = "x86_64-linux"; };
      freebsdTools = import ../stdenv/freebsd/make-bootstrap-tools-cross.nix { system = "x86_64-linux"; };
      cygwinTools = import ../stdenv/cygwin/make-bootstrap-tools-cross.nix { system = "x86_64-linux"; };
      linuxMeta = {
        maintainers = [ ];
      };
      freebsdMeta = {
        maintainers = [ maintainers.rhelmot ];
      };
      cygwinMeta = {
        maintainers = [ maintainers.corngood ];
      };
      mkBootstrapToolsJob =
        meta: drv:
        assert elem drv.system supportedSystems;
        hydraJob' (addMetaAttrs meta drv);
      linux =
        mapAttrsRecursiveCond (as: !isDerivation as) (name: mkBootstrapToolsJob linuxMeta)
          # The `bootstrapTools.${platform}.bootstrapTools` derivation
          # *unpacks* the bootstrap-files using their own `busybox` binary,
          # so it will fail unless buildPlatform.canExecute hostPlatform.
          # Unfortunately `bootstrapTools` also clobbers its own `system`
          # attribute, so there is no way to detect this -- we must add it
          # as a special case.  We filter the "test" attribute (only from
          # *cross*-built bootstrapTools) for the same reason.
          (
            mapAttrs (
              _: v:
              removeAttrs v [
                "bootstrapTools"
                "test"
              ]
            ) linuxTools
          );
      freebsd = mapAttrsRecursiveCond (as: !isDerivation as) (
        name: mkBootstrapToolsJob freebsdMeta
      ) freebsdTools;
      cygwin = mapAttrsRecursiveCond (as: !isDerivation as) (
        name: mkBootstrapToolsJob cygwinMeta
      ) cygwinTools;
    in
    linux // freebsd // cygwin;

  cross-mingw-msvcrt-x86_64 = mapTestOnCross systems.examples.mingw-msvcrt-x86_64 windowsCommon;
  cross-mingw-ucrt-aarch64 = mapTestOnCross systems.examples.mingw-ucrt-aarch64 windowsCommon;
  cross-mingw-ucrt-x86_64 = mapTestOnCross systems.examples.mingw-ucrt-x86_64 windowsCommon;
  cross-mingw-ucrt-x86_64-llvm = mapTestOnCross systems.examples.mingw-ucrt-x86_64-llvm windowsCommon;
  crossIphone32 = mapTestOnCross systems.examples.iphone32 darwinCommon;
  crossIphone64 = mapTestOnCross systems.examples.iphone64 darwinCommon;
  # Test some cross builds on various mingw-w64 platforms
  crossMingw32 = mapTestOnCross systems.examples.mingw-msvcrt-i686 windowsCommon;

  # These derivations from a cross package set's `buildPackages` should be
  # identical to their vanilla equivalents --- none of these package should
  # observe the target platform which is the only difference between those
  # package sets.
  ensureUnaffected =
    let
      # Absurd values are fine here, as we are not building anything. In fact,
      # there probably a good idea to try to be "more parametric" --- i.e. avoid
      # any special casing.
      crossSystem = {
        config = "mips64el-apple-windows-gnu";
        libc = "glibc";
      };

      # Converting to a string (drv path) before checking equality is probably a
      # good idea lest there be some irrelevant pass-through debug attrs that
      # cause false negatives.
      testEqualOne =
        path: system:
        let
          f =
            path: crossSystem: system:
            toString (getAttrFromPath path (pkgsForCross crossSystem system));
        in
        assertTrue (f path null system == f ([ "buildPackages" ] ++ path) crossSystem system);

      testEqual = path: systems: forMatchingSystems systems (testEqualOne path);

      mapTestEqual = mapAttrsRecursive testEqual;

    in
    mapTestEqual {
      boehmgc = nativePlatforms;
      guile = nativePlatforms;
      libffi = nativePlatforms;
      libiconv = nativePlatforms;
      libtool = nativePlatforms;
      libxml2 = nativePlatforms;
      readline = nativePlatforms;
      zlib = nativePlatforms;
    };

  # Linux on mipsel
  fuloongminipc = mapTestOnCross systems.examples.fuloongminipc linuxCommon;

  # Javascript
  ghcjs = mapTestOnCross systems.examples.ghcjs {
    haskell.packages.native-bignum.ghcHEAD.hello = nativePlatforms;
    haskellPackages.hello = nativePlatforms;
  };

  i686-embedded = mapTestOnCross systems.examples.i686-embedded embedded;
  i686-gnu = mapTestOnCross systems.examples.gnu32 linuxCommon;
  i686-musl = mapTestOnCross systems.examples.musl32 linuxCommon;
  # Linux on LoongArch
  loongarch64-linux = mapTestOnCross systems.examples.loongarch64-linux linuxCommon;
  m68k = mapTestOnCross systems.examples.m68k linuxCommon;
  # Cross-built nixStatic for platforms for enabled-but-unsupported platforms
  mips64el-nixCrossStatic = mapTestOnCross systems.examples.mips64el-linux-gnuabi64 nixCrossStatic;
  mmix = mapTestOnCross systems.examples.mmix embedded;
  msp430 = mapTestOnCross systems.examples.msp430 embedded;
  or1k = mapTestOnCross systems.examples.or1k embedded;
  powerpc-embedded = mapTestOnCross systems.examples.ppc-embedded embedded;
  powerpc64le-nixCrossStatic = mapTestOnCross systems.examples.powernv nixCrossStatic;
  powerpcle-embedded = mapTestOnCross systems.examples.ppcle-embedded embedded;
  # Linux on POWER
  ppc64-elfv1 = mapTestOnCross systems.examples.ppc64-elfv1 linuxCommon;
  ppc64-elfv2 = mapTestOnCross systems.examples.ppc64-elfv2 linuxCommon;
  ppc64-musl = mapTestOnCross systems.examples.ppc64-musl linuxCommon;
  ppc64le = mapTestOnCross systems.examples.powernv linuxCommon;
  ppc64le-musl = mapTestOnCross systems.examples.musl-power linuxCommon;
  # Linux on the Remarkable
  remarkable1 = mapTestOnCross systems.examples.remarkable1 linuxCommon;
  remarkable2 = mapTestOnCross systems.examples.remarkable2 linuxCommon;
  riscv32 = mapTestOnCross systems.examples.riscv32 linuxCommon;
  riscv32-embedded = mapTestOnCross systems.examples.riscv32-embedded embedded;
  # Linux on RISCV
  riscv64 = mapTestOnCross systems.examples.riscv64 linuxCommon;
  riscv64-embedded = mapTestOnCross systems.examples.riscv64-embedded embedded;
  # Linux on Raspberrypi
  rpi = mapTestOnCross systems.examples.raspberryPi rpiCommon;
  rpi-musl = mapTestOnCross systems.examples.muslpi rpiCommon;
  rx-embedded = mapTestOnCross systems.examples.rx-embedded embedded;
  s390x = mapTestOnCross systems.examples.s390x linuxCommon;
  vc4 = mapTestOnCross systems.examples.vc4 embedded;
  wasi32 = mapTestOnCross systems.examples.wasi32 wasiCommon;
  x86_64-cygwin = mapTestOnCross systems.examples.x86_64-cygwin cygwinCommon;
  x86_64-embedded = mapTestOnCross systems.examples.x86_64-embedded embedded;
  x86_64-freebsd = mapTestOnCross systems.examples.x86_64-freebsd common;
  x86_64-gnu = mapTestOnCross systems.examples.gnu64 linuxCommon;
  # (Cross-compiled) Linux on x86
  x86_64-musl = mapTestOnCross systems.examples.musl64 linuxCommon;
  x86_64-netbsd = mapTestOnCross systems.examples.x86_64-netbsd common;
  x86_64-openbsd = mapTestOnCross systems.examples.x86_64-openbsd common;
}
