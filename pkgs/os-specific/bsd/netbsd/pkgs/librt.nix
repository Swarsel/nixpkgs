{
  lib,
  libcMinimal,
  mkDerivation,
}:

mkDerivation {
  inherit (libcMinimal) postPatch;

  outputs = [
    "out"
    "man"
  ];

  extraPaths = [ libcMinimal.path ] ++ libcMinimal.extraPaths;
  libcMinimal = true;
  path = "lib/librt";
  meta.platforms = lib.platforms.netbsd;
}
