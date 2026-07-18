{
  lib,
  mkDerivation,
  sys,
}:

mkDerivation {
  pname = "libpci";
  env.NIX_CFLAGS_COMPILE = toString [ "-I." ];
  extraPaths = [ sys.path ];
  path = "lib/libpci";
  meta.platforms = lib.platforms.netbsd;
}
