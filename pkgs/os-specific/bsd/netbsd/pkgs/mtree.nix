{ mkDerivation, mknod }:

mkDerivation {
  extraPaths = [ mknod.path ];
  path = "usr.sbin/mtree";
}
