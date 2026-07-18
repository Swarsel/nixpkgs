# Schema:
# ${flutterVersion}.${targetPlatform}.${hostPlatform}
#
# aarch64-darwin as a host is not yet supported.
# https://github.com/flutter/flutter/issues/60118
{
  lib,
  cacert,
  flutter,
  flutterPlatform,
  hash,
  lndir,
  runCommand,
  systemPlatform,
  unzip,
}:

let
  flutterPlatforms = [
    "android"
    "ios"
    "web"
    "linux"
    "windows"
    "macos"
    "fuchsia"
    "universal"
  ];

  flutter' = flutter.override {
    # Modify flutter-tool's system platform in order to get the desired platform's hashes.
    flutter = flutter.unwrapped.override {
      flutterTools = flutter.unwrapped.tools.override {
        inherit systemPlatform;
      };
    };

    # Use a version of Flutter with just enough capabilities to download
    # artifacts.
    supportedTargetFlutterPlatforms = [ ];
  };
in
runCommand "flutter-artifacts-${flutterPlatform}-${systemPlatform}"
  {
    nativeBuildInputs = [
      lndir
      flutter'
      unzip
    ];

    NIX_FLUTTER_OPERATING_SYSTEM =
      {
        "aarch64-darwin" = "macos";
        "aarch64-linux" = "linux";
        "x86_64-linux" = "linux";
      }
      .${systemPlatform};

    NIX_FLUTTER_TOOLS_VM_OPTIONS = "--root-certs-file=${cacert}/etc/ssl/certs/ca-bundle.crt";
    outputHash = hash;
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";

    passthru = {
      inherit flutterPlatform;
    };
  }
  (
    ''
      export FLUTTER_ROOT="$NIX_BUILD_TOP"
      lndir -silent '${flutter'}' "$FLUTTER_ROOT"
      rm --recursive --force "$FLUTTER_ROOT/bin/cache"
      mkdir "$FLUTTER_ROOT/bin/cache"
      mkdir "$FLUTTER_ROOT/bin/cache/dart-sdk"
      lndir -silent '${flutter'}/bin/cache/dart-sdk' "$FLUTTER_ROOT/bin/cache/dart-sdk"
    ''
    # Could not determine engine revision
    + lib.optionalString (lib.versionAtLeast flutter'.version "3.32") ''
      cp '${flutter'}/bin/internal/engine.version' "$FLUTTER_ROOT/bin/cache/engine.stamp"
    ''
    + ''

      HOME="$(mktemp -d)" flutter precache ${
        lib.optionalString (
          flutter ? engine && flutter.engine.meta.available
        ) "--local-engine ${flutter.engine.outName}"
      } \
        --verbose '--${flutterPlatform}' ${
          builtins.concatStringsSep " " (map (p: "'--no-${p}'") (lib.remove flutterPlatform flutterPlatforms))
        }

      rm --recursive --force "$FLUTTER_ROOT/bin/cache/lockfile"
      rm --recursive --force "$FLUTTER_ROOT/bin/cache/dart-sdk"
    ''
    + ''
      find "$FLUTTER_ROOT" -type l -lname '${flutter'}/*' -delete

      cp --recursive bin/cache "$out"
    ''
  )
