{
  lib,
  licenseAccepted ? pkgs.callPackage ./license.nix { },
  pkgs ? import <nixpkgs> { },
}:

lib.recurseIntoAttrs rec {
  inherit (test-suite) passthru;

  androidPkgs = composeAndroidPackages {
    includeEmulator = "if-supported";
    includeNDK = "if-supported";
    includeSystemImages = "if-supported";
    # Support roughly the last 5 years of Android packages and system images by default in nixpkgs.
    numLatestPlatformVersions = 5;
  };

  buildApp = pkgs.callPackage ./build-app.nix {
    inherit composeAndroidPackages meta;
  };

  composeAndroidPackages = pkgs.callPackage ./compose-android-packages.nix {
    inherit licenseAccepted meta;
  };

  emulateApp = pkgs.callPackage ./emulate-app.nix {
    inherit composeAndroidPackages meta;
  };

  test-suite = pkgs.callPackage ./test-suite.nix {
    inherit meta;
  };

  meta = {
    description = "Android SDK tools, packaged in Nixpkgs";
    homepage = "https://developer.android.com/tools";
    license = lib.licenses.unfree;
    platforms = lib.platforms.all;
    teams = [ lib.teams.android ];
  };
}
