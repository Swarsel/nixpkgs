{
  lib,
  stdenv,
  mkDerivation,
}:
mkDerivation {
  MK_TESTS = "no";
  extraPaths = [ "sbin/mount" ];
  path = "sbin/init";

  meta = {
    platforms = lib.platforms.freebsd;
    mainProgram = "init";
    broken = !stdenv.hostPlatform.isStatic;
  };
}
