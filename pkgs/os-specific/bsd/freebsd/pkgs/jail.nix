{
  lib,
  byacc,
  flex,
  libjail,
  mkDerivation,
}:
mkDerivation {
  buildInputs = [
    libjail
  ];

  MK_TESTS = "no";

  extraNativeBuildInputs = [
    flex
    byacc
  ];

  path = "usr.sbin/jail";
  meta.mainProgram = "jail";
  meta.platforms = lib.platforms.freebsd;
}
