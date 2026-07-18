{
  lib,
  mandoc,
  mkDerivation,
}:
mkDerivation {
  extraNativeBuildInputs = [ mandoc ];
  path = "sbin/fdisk";
  meta.mainProgram = "fdisk";
  meta.platforms = lib.platforms.openbsd;
}
