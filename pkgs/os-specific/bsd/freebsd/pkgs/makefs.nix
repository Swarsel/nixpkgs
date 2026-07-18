{
  compatIfNeeded,
  libnetbsd,
  libsbuf,
  mkDerivation,
}:
mkDerivation {
  buildInputs = compatIfNeeded ++ [
    libnetbsd
    libsbuf
  ];

  MK_PIE = "no";
  MK_TESTS = "no";

  extraPaths = [
    "stand/libsa"
    "sys/cddl/boot"
    "sys/ufs/ffs"
    "sbin/newfs_msdos"
    "contrib/mtree"
    "contrib/mknod"
    "sys/fs/cd9660"
  ];

  path = "usr.sbin/makefs";
}
