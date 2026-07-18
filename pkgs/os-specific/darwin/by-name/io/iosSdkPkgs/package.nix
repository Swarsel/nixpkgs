{
  lib,
  stdenv,
  binutils-unwrapped,
  buildPackages,
  clang-unwrapped,
  iosSdkPkgs,
  runCommand,
  targetPackages,
  wrapBintoolsWith,
  wrapCCWith,
  xcode,
  buildIosSdk ? buildPackages.darwin.iosSdkPkgs.sdk,
  targetIosSdkPkgs ? targetPackages.darwin.iosSdkPkgs or iosSdkPkgs,
}:

let

  minSdkVersion = stdenv.targetPlatform.minSdkVersion or "9.0";

in

rec {
  binutils = wrapBintoolsWith {
    bintools = binutils-unwrapped;
    libc = targetIosSdkPkgs.libraries;
  };

  clang =
    (wrapCCWith {
      bintools = binutils;
      cc = clang-unwrapped;

      extraBuildCommands = ''
        tr '\n' ' ' < $out/nix-support/cc-cflags > cc-cflags.tmp
        mv cc-cflags.tmp $out/nix-support/cc-cflags
        echo "-target ${stdenv.targetPlatform.config}" >> $out/nix-support/cc-cflags
        echo "-isystem ${sdk}/usr/include${lib.optionalString (lib.versionAtLeast "10" sdk.version) " -isystem ${sdk}/usr/include/c++/4.2.1/ -stdlib=libstdc++"}" >> $out/nix-support/cc-cflags
        ${lib.optionalString (lib.versionAtLeast sdk.version "14") "echo -isystem ${xcode}/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/include/c++/v1 >> $out/nix-support/cc-cflags"}
      '';

      extraPackages = [ "${sdk}/System" ];
      libc = targetIosSdkPkgs.libraries;
    })
    // {
      inherit sdk;
    };

  libraries =
    let
      sdk = buildIosSdk;
    in
    runCommand "libSystem-prebuilt"
      {
        passthru = {
          inherit sdk;
        };
      }
      ''
        if ! [ -d ${sdk} ]; then
            echo "You must have version ${sdk.version} of the ${sdk.platform} sdk installed at ${sdk}" >&2
            exit 1
        fi
        ln -s ${sdk}/usr $out
      '';

  sdk = rec {
    version = stdenv.targetPlatform.sdkVer or "";
    name = "ios-sdk";

    outPath =
      xcode
      + "/Contents/Developer/Platforms/${platform}.platform/Developer/SDKs/${platform}${version}.sdk";

    platform = stdenv.targetPlatform.xcodePlatform or "";
    type = "derivation";
  };
}
