{
  lib,
  mandoc,
  mkDerivation,
}:
mkDerivation {
  extraNativeBuildInputs = [
    mandoc
  ];

  path = "sbin/disklabel";
  meta.mainProgram = "disklabel";
  meta.platforms = lib.platforms.openbsd;
}
