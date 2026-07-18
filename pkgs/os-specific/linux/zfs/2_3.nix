{
  lib,
  stdenv,
  callPackage,
  fetchpatch,
  nixosTests,
  ...
}@args:

callPackage ./generic.nix args {
  # this package should point to the latest release.
  version = "2.3.8";
  hash = "sha256-qNBInNRpWrmImcermSHC0emYmnnjNvxWj3QnGtA6SUg=";
  kernelMaxSupportedMajorMinor = "7.0";
  kernelMinSupportedMajorMinor = "4.18";
  # You have to ensure that in `pkgs/top-level/linux-kernels.nix`
  # this attribute is the correct one for this package.
  kernelModuleAttribute = "zfs_2_3";

  maintainers = with lib.maintainers; [
    adamcstephens
    amarshall
  ];

  tests = {
    inherit (nixosTests.zfs) series_2_3;
  }
  // lib.optionalAttrs stdenv.hostPlatform.isx86_64 {
    inherit (nixosTests.zfs) installer;
  };
}
