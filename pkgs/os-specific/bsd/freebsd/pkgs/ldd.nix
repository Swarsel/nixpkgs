{
  lib,
  stdenv,
  mkDerivation,
}:
mkDerivation {
  env = {
    NIX_CFLAGS_COMPILE = "-D_RTLD_PATH=${lib.getLib stdenv.cc.libc}/libexec/ld-elf.so.1";
  };

  extraPaths = [
    "libexec/rtld-elf"
    "contrib/elftoolchain/libelf"
  ];

  path = "usr.bin/ldd";
  meta.platforms = lib.platforms.freebsd;
}
