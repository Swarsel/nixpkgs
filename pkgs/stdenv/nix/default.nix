{
  lib,
  bootStages,
  config,
  crossSystem,
  localSystem,
  overlays,
}:

assert crossSystem == localSystem;
let
  genericStdenv = import ../generic { defaultConfig = config; };
in
bootStages
++ [
  (prevStage: {
    inherit config overlays;

    stdenv = genericStdenv rec {
      inherit (prevStage.stdenv) buildPlatform hostPlatform targetPlatform;

      cc = import ../../build-support/cc-wrapper {
        inherit lib;

        inherit (prevStage)
          stdenvNoCC
          binutils
          coreutils
          gnugrep
          ;

        cc = prevStage.gcc.cc;
        isGNU = true;
        nativeLibc = true;
        nativePrefix = lib.optionalString hostPlatform.isSunOS "/usr";
        nativeTools = false;
        shell = prevStage.bash + "/bin/sh";
      };

      fetchurlBoot = prevStage.stdenv.fetchurlBoot;
      initialPath = (import ../generic/common-path.nix) { pkgs = prevStage; };

      overrides = self: super: {
        inherit cc;
        inherit (cc) binutils;

        inherit (prevStage)
          gzip
          bzip2
          xz
          bash
          coreutils
          diffutils
          findutils
          gawk
          gnumake
          gnused
          gnutar
          gnugrep
          gnupatch
          perl
          ;
      };

      preHook = ''
        export NIX_ENFORCE_PURITY="''${NIX_ENFORCE_PURITY-1}"
        export NIX_ENFORCE_NO_NATIVE="''${NIX_ENFORCE_NO_NATIVE-1}"
        export NIX_IGNORE_LD_THROUGH_GCC=1
      '';

      shell = prevStage.bash + "/bin/sh";
    };
  })
]
