{
  lib,
  # Staging native build deps
  autoconf,
  callPackage,
  gitMinimal,
  hexdump,
  moltenvk,
  perl,
  pkgs,
  pkgsCross,
  pkgsi686Linux,
  python3,
  replaceVars,
  src,
  stdenv_32bit,
  pnameSuffix ? "",
  useStaging ? false,
  ...
}@args:

let
  inherit (src)
    version
    patches
    gecko32
    gecko64
    mono
    ;

  llvm-mingw = callPackage ./llvm-mingw.nix { };

  # Args to pass through to base.nix (support flags, etc.)
  baseArgs = removeAttrs args [
    "stdenv_32bit"
    "lib"
    "pkgs"
    "pkgsi686Linux"
    "pkgsCross"
    "callPackage"
    "replaceVars"
  ];
in
{
  wine32 = pkgsi686Linux.callPackage ./base.nix (
    baseArgs
    // {
      inherit version patches;

      # Forcing these `nativeBuildInputs` used in the `staging` to come
      # from ambient `pkgs`, rather than being provided by
      # `pkgsi686Linux.callPackage` for that platform.
      inherit
        autoconf
        hexdump
        perl
        python3
        gitMinimal
        ;

      pname = "wine";
      geckos = [ gecko32 ];
      mingwGccs = with pkgsCross; [ mingw32.buildPackages.gcc ];
      monos = [ mono ];
      pkgArches = [ pkgsi686Linux ];

      platforms = [
        "i686-linux"
        "x86_64-linux"
      ];
    }
  );

  wine64 = callPackage ./base.nix (
    baseArgs
    // {
      inherit version patches;
      pname = "wine64";

      configureFlags =
        if pkgs.stdenv.hostPlatform.isAarch64 then [ "--enable-archs=aarch64" ] else [ "--enable-win64" ];

      geckos = [ gecko64 ];
      mainProgram = "wine";

      mingwGccs =
        if pkgs.stdenv.hostPlatform.isAarch64 then
          [ llvm-mingw ]
        else
          with pkgsCross; [ mingwW64.buildPackages.gcc ];

      monos = [ mono ];
      pkgArches = [ pkgs ];

      platforms = [
        "x86_64-linux"
        "aarch64-linux"
      ];
    }
  );

  wineWow = callPackage ./base.nix (
    baseArgs
    // {
      inherit version patches;
      pname = "wine-wow";

      buildScript = replaceVars ./builder-wow.sh {
        # pkgconfig has trouble picking the right architecture
        pkgconfig64remove = lib.makeSearchPathOutput "dev" "lib/pkgconfig" [
          pkgs.glib
          pkgs.gst_all_1.gstreamer
        ];
      };

      geckos = [
        gecko32
        gecko64
      ];

      mainProgram = "wine";

      mingwGccs = with pkgsCross; [
        mingw32.buildPackages.gcc
        mingwW64.buildPackages.gcc
      ];

      monos = [ mono ];

      pkgArches = [
        pkgs
        pkgsi686Linux
      ];

      platforms = [ "x86_64-linux" ];
      stdenv = stdenv_32bit;
    }
  );

  wineWow64 = callPackage ./base.nix (
    baseArgs
    // {
      inherit version patches;
      pname = "wine-wow64";

      configureFlags =
        if pkgs.stdenv.hostPlatform.isAarch64 then
          [ "--enable-archs=aarch64,x86_64,i386" ]
        else
          [ "--enable-archs=x86_64,i386" ];

      geckos = [ gecko64 ];
      mainProgram = "wine";

      mingwGccs =
        if pkgs.stdenv.hostPlatform.isAarch64 then
          [ llvm-mingw ]
        else
          with pkgsCross;
          [
            mingw32.buildPackages.gcc
            mingwW64.buildPackages.gcc
          ];

      mingwSupport = true; # Required because we request "--enable-archs=x86_64"
      monos = [ mono ];
      pkgArches = [ pkgs ];

      platforms = [
        "x86_64-linux"
        "aarch64-linux"
      ];
    }
  );
}
