{ mkDerivation }:
mkDerivation {
  patches = [ ./fsck-path.patch ];
  path = "sbin/fsck";
}
