{ mkDerivation }:
mkDerivation {
  extraPaths = [ "lib/libc/Versions.def" ];
  path = "lib/libstdthreads";
}
