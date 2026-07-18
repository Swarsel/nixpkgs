{ mkDerivation }:
mkDerivation {
  extraPaths = [
    "sbin/fsck"
    "sys/ufs/ffs"
  ];

  path = "sbin/fsck_ffs";
}
