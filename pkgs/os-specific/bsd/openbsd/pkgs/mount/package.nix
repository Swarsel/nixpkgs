{
  mkDerivation,
}:

mkDerivation {
  patches = [ ./search-path.patch ];
  path = "sbin/mount";
  meta.mainProgram = "mount";
}
