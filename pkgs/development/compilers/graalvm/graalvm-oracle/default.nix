{
  lib,
  stdenv,
  fetchurl,
  graalvmPackages,
  useMusl ? false,
  version ? "25",
}:

graalvmPackages.buildGraalvm {
  inherit useMusl version;
  pname = "graalvm-oracle";
  src = fetchurl (import ./hashes.nix).${version}.${stdenv.system};
  meta.license = lib.licenses.unfree;
  meta.platforms = builtins.attrNames (import ./hashes.nix).${version};
}
