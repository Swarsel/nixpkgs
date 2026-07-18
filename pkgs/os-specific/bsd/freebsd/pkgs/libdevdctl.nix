{
  lib,
  mkDerivation,
}:
mkDerivation {
  outputs = [
    "out"
    "debug"
  ];

  env.NIX_CFLAGS_COMPILE = "-std=c++23 -Wno-nullability-completeness";
  clangFixup = false;
  path = "lib/libdevdctl";
  meta.platforms = lib.platforms.freebsd;
}
