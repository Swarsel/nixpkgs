{
  pkgs ? import ../../.. { },
}:

let
  inherit (pkgs)
    lib
    stdenv
    config
    libc
    ;

  patchelf = pkgs.patchelf.overrideAttrs (previousAttrs: {
    NIX_CFLAGS_COMPILE = (previousAttrs.NIX_CFLAGS_COMPILE or [ ]) ++ [
      "-static-libgcc"
      "-static-libstdc++"
    ];

    NIX_CFLAGS_LINK = (previousAttrs.NIX_CFLAGS_LINK or [ ]) ++ [
      "-static-libgcc"
      "-static-libstdc++"
    ];
  });
in
rec {
  inherit (build) bootstrapFiles;

  bootBinutils = pkgs.binutils.bintools.override {
    # Don't need two linkers, disable whatever's not primary/default.
    enableGold = false;
    # bootstrap is easier w/static
    enableShared = false;
    withAllTargets = false;
  };

  bootGCC = pkgs.gcc.cc.override {
    enableLTO = false;
    isl = null;
  };

  bootstrapTools = import ./bootstrap-tools {
    inherit (stdenv.buildPlatform) system; # Used to determine where to build
    inherit (stdenv.hostPlatform) libc;
    inherit lib bootstrapFiles config;
  };

  build = pkgs.callPackage ./stdenv-bootstrap-tools.nix {
    inherit
      bootBinutils
      coreutilsMinimal
      tarMinimal
      busyboxMinimal
      bootGCC
      libc
      patchelf
      ;
  };

  busyboxMinimal = pkgs.busybox.override {
    enableMinimal = true;
    enableStatic = true;

    extraConfig = ''
      CONFIG_ASH y
      CONFIG_ASH_ECHO y
      CONFIG_ASH_TEST y
      CONFIG_ASH_OPTIMIZE_FOR_SIZE y
      CONFIG_MKDIR y
      CONFIG_TAR y
      CONFIG_UNXZ y
    '';

    useMusl = lib.meta.availableOn stdenv.hostPlatform pkgs.musl;
  };

  coreutilsMinimal = pkgs.coreutils.override (args: {
    # We want coreutils without ACL/attr support.
    aclSupport = false;
    attrSupport = false;
    # Our tooling currently can't handle scripts in bin/, only ELFs and symlinks.
    singleBinary = "symlinks";
  });

  tarMinimal = pkgs.gnutar.override { acl = null; };

  test = pkgs.callPackage ./test-bootstrap-tools.nix {
    inherit bootstrapTools;
    inherit (bootstrapFiles) busybox;
  };
}
