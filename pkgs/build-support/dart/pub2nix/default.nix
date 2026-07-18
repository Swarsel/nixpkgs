{ callPackage }:

{
  generatePackageConfig = callPackage ./package-config.nix { };
  readPubspecLock = callPackage ./pubspec-lock.nix { };
}
