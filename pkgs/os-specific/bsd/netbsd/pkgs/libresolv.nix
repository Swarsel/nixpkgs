{
  lib,
  libcMinimal,
  mkDerivation,
}:

mkDerivation {
  extraPaths = [ libcMinimal.path ];
  libcMinimal = true;
  path = "lib/libresolv";
  meta.platforms = lib.platforms.netbsd;
}
