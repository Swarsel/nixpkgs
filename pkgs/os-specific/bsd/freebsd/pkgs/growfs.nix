{
  lib,
  libufs,
  libutil,
  mkDerivation,
}:
mkDerivation {
  outputs = [
    "out"
    "man"
    "debug"
  ];

  buildInputs = [
    libufs
    libutil
  ];

  MK_TESTS = "no";

  extraPaths = [
    "sbin/mount"
  ];

  path = "sbin/growfs";
  meta.mainProgram = "growfs";
  meta.platforms = lib.platforms.freebsd;
}
