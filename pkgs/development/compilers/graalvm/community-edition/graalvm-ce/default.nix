{
  stdenv,
  fetchurl,
  graalvmPackages,
  useMusl ? false,
}:

graalvmPackages.buildGraalvm {
  inherit useMusl;
  version = (import ./hashes.nix).version;
  src = fetchurl (import ./hashes.nix).hashes.${stdenv.system};
  meta.platforms = builtins.attrNames (import ./hashes.nix).hashes;
}
