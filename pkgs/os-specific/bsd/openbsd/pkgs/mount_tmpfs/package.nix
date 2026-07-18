{
  mkDerivation,
}:

mkDerivation {
  extraPaths = [ "sbin/mount" ];
  path = "sbin/mount_tmpfs";
}
