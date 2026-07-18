{
  callPackage,
  nixosTests,
  ...
}@args:

callPackage ./generic.nix args {
  # this package should point to a version / git revision compatible with the latest kernel release
  # IMPORTANT: Always use a tagged release candidate or commits from the
  # zfs-<version>-staging branch, because this is tested by the OpenZFS
  # maintainers.
  version = "2.4.3";

  extraLongDescription = ''
    This is "unstable" ZFS, and will usually be a pre-release version of ZFS.
    It may be less well-tested and have critical bugs.
  '';

  hash = "sha256-I1wLbstr0cFiGsyynP9kJ9ATRp/2b+fnnsdz0up+IzM=";
  kernelMaxSupportedMajorMinor = "7.0";
  kernelMinSupportedMajorMinor = "4.18";
  # You have to ensure that in `pkgs/top-level/linux-kernels.nix`
  # this attribute is the correct one for this package.
  kernelModuleAttribute = "zfs_unstable";

  # rev = "";
  tests = {
    inherit (nixosTests.zfs) unstable;
  };
}
